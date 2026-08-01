import 'package:flutter/material.dart';
import '../models/board_game.dart';
import '../repositories/board_game_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/expandable_fab_menu.dart';
import '../widgets/empty_state.dart';
import '../widgets/game_card.dart';
import '../widgets/glass_app_bar.dart';
import 'add_game_screen.dart';
import 'add_match_screen.dart';
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
  bool _isFabHidden = false;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    try {
      final games = await BoardGameRepository.instance.getAll();
      if (!mounted) return;
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading games: $e')));
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.maxScrollExtent > 0) {
      final isAtBottom =
          notification.metrics.pixels >= notification.metrics.maxScrollExtent - 40;
      if (isAtBottom != _isFabHidden) {
        setState(() {
          _isFabHidden = isAtBottom;
        });
      }
    }
    return false;
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
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Library',
        titleColor: AppColors.headerCoral,
        titleIcon: Icons.grid_view_rounded,
        actions: [
          IconButton(
            tooltip: 'Search Games',
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _games.isEmpty
            ? _buildEmptyState()
            : _buildGameGrid(),
      ),
      floatingActionButton: ExpandableFabMenu(
        isVisible: !_isFabHidden,
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
              if (result == true) _loadGames();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          topPadding,
          16,
          140 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: const EmptyState(
          icon: Icons.casino_outlined,
          title: 'No board games in library',
          subtitle: 'Tap + to add games',
        ),
      ),
    );
  }

  Widget _buildGameGrid() {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 8;
    return RefreshIndicator(
      onRefresh: _loadGames,
      edgeOffset: topPadding,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(
          8,
          topPadding,
          8,
          140 + MediaQuery.of(context).viewPadding.bottom,
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
