import 'package:flutter/material.dart';
import '../models/board_game.dart';
import '../repositories/board_game_repository.dart';
import '../widgets/app_drawer.dart';
import '../widgets/expandable_fab_menu.dart';
import '../widgets/empty_state.dart';
import '../widgets/game_card.dart';
import 'add_game_screen.dart';
import 'add_match_screen.dart';
import 'matches_screen.dart';
import 'search_screen.dart';
import 'game_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<BoardGame> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    try {
      final games = await BoardGameRepository.instance.getAll();
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading games: $e')));
      }
    }
  }

  Future<void> _navigateToGameDetail(BoardGame game) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => GameDetailScreen(game: game)),
    );

    if (result == true) {
      _loadGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      drawer: const AppDrawer(currentRoute: 'library'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
          ? _buildEmptyState()
          : _buildGameGrid(),
      floatingActionButton: ExpandableFabMenu(
        searchItem: FabMenuItem(
          label: 'Search Games',
          icon: Icons.search,
          heroTag: 'search',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        ),
        menuItems: [
          FabMenuItem(
            label: 'Add Game to Library',
            icon: Icons.library_add,
            heroTag: 'addGame',
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const AddGameScreen()),
              );
              if (result == true) _loadGames();
            },
          ),
          FabMenuItem(
            label: 'Register Match',
            icon: Icons.sports_esports,
            heroTag: 'addMatch',
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const AddMatchScreen()),
              );
              if (result == true && context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchesScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.casino_outlined,
      title: 'No board games in library',
      subtitle: 'Tap + to add games',
    );
  }

  Widget _buildGameGrid() {
    return RefreshIndicator(
      onRefresh: _loadGames,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(
          8,
          8,
          8,
          8 + MediaQuery.of(context).viewPadding.bottom,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return _buildGameCard(game);
        },
      ),
    );
  }

  Widget _buildGameCard(BoardGame game) {
    return GameCard(game: game, onTap: () => _navigateToGameDetail(game));
  }
}
