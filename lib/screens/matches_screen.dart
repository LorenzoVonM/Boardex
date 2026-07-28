import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../repositories/board_game_repository.dart';
import '../repositories/match_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/app_drawer.dart';
import '../widgets/expandable_fab_menu.dart';
import '../widgets/empty_state.dart';
import 'match_detail_screen.dart';
import 'add_game_screen.dart';
import 'add_match_screen.dart';
import 'match_search_screen.dart';
import 'library_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<GameMatch> _matches = [];
  bool _isLoading = true;
  // Cache of resolved library photo paths: gameName -> photoPath
  final Map<String, String?> _libraryPhotoCache = {};

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    try {
      final matches = await MatchRepository.instance.getAll();

      // Pre-resolve library photos for matches that use them
      final gameNames = matches
          .where((m) => m.useLibraryPhoto)
          .map((m) => m.gameName)
          .toSet();
      for (final name in gameNames) {
        if (!_libraryPhotoCache.containsKey(name)) {
          _libraryPhotoCache[name] = await BoardGameRepository.instance
              .getPhotoPath(name);
        }
      }

      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading matches: $e')));
      }
    }
  }

  String? _resolvePhotoPath(GameMatch match) {
    if (match.useLibraryPhoto) {
      return _libraryPhotoCache[match.gameName];
    }
    return match.photoPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      drawer: const AppDrawer(currentRoute: 'matches'),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _matches.isEmpty
              ? _buildEmptyState()
              : _buildMatchList(),
        ],
      ),
      floatingActionButton: ExpandableFabMenu(
        searchItem: FabMenuItem(
          label: 'Search Matches',
          icon: Icons.search,
          heroTag: 'search_matches',
          onTap: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => const MatchSearchScreen(),
              ),
            );
            if (result == true) _loadMatches();
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
              if (result == true && context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LibraryScreen(),
                  ),
                );
              }
            },
          ),
          FabMenuItem(
            label: 'Register Match',
            icon: Icons.sports_esports,
            heroTag: 'register_match',
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const AddMatchScreen()),
              );
              if (result == true) _loadMatches();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.history,
      title: 'No matches recorded',
      subtitle: 'Tap + to register your first match',
    );
  }

  Widget _buildMatchList() {
    return RefreshIndicator(
      onRefresh: _loadMatches,
      child: ListView.builder(
        padding: EdgeInsets.only(
          bottom: 100 + MediaQuery.of(context).viewPadding.bottom,
        ),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return _buildMatchCard(match);
        },
      ),
    );
  }

  Widget _buildMatchCard(GameMatch match) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolvedPhoto = _resolvePhotoPath(match);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailScreen(match: match),
            ),
          );
          if (result == true) {
            _loadMatches();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Photo thumbnail or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: resolvedPhoto != null
                      ? Image.file(
                          File(resolvedPhoto),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),
              // Match details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.gameName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(match.playedAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${match.duration} min',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (match.players.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.people,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${match.players.length}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (match.winner != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.emoji_events,
                            size: 14,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            match.winner!,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Result badge
              buildMatchResultTag(
                match.result,
                size: MatchResultTagSize.regular,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.casino, color: colorScheme.onSurfaceVariant, size: 32),
    );
  }
}
