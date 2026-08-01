import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../repositories/board_game_repository.dart';
import '../repositories/match_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/expandable_fab_menu.dart';
import '../widgets/glass_app_bar.dart';
import 'add_game_screen.dart';
import 'add_match_screen.dart';
import 'match_detail_screen.dart';
import 'match_search_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<GameMatch> _matches = [];
  bool _isLoading = true;
  // Cache of resolved library photo paths: gameName -> photoPath
  final Map<String, String?> _libraryThumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    try {
      final matches = await MatchRepository.instance.getAll();

      // Pre-resolve library photo thumbnails for matches that use them
      final gameNames = matches
          .where((m) => m.useLibraryPhoto)
          .map((m) => m.gameName)
          .toSet();
      for (final name in gameNames) {
        if (!_libraryThumbnailCache.containsKey(name)) {
          _libraryThumbnailCache[name] = await BoardGameRepository.instance
              .getThumbnailPath(name);
        }
      }

      if (!mounted) return;
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading matches: $e')));
    }
  }

  String? _resolvePhotoPath(GameMatch match) {
    if (match.useLibraryPhoto) {
      return _libraryThumbnailCache[match.gameName];
    }
    return match.displayPhotoPath;
  }

  bool _isFabHidden = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Matches',
        titleColor: AppColors.brandTeal,
        titleIcon: Icons.sports_esports_rounded,
        actions: [
          IconButton(
            tooltip: 'Search Matches',
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchSearchScreen(),
                ),
              );
              if (result == true) _loadMatches();
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _matches.isEmpty
                ? _buildEmptyState()
                : _buildMatchList(),
          ],
        ),
      ),
      floatingActionButton: ExpandableFabMenu(
        isVisible: !_isFabHidden,
        menuItems: [
          FabMenuItem(
            label: 'Add Game to Library',
            icon: Icons.library_add,
            heroTag: 'addGame',
            onTap: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const AddGameScreen()),
              );
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
          icon: Icons.history,
          title: 'No matches recorded',
          subtitle: 'Tap + to register your first match',
        ),
      ),
    );
  }

  Widget _buildMatchList() {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 8;
    return RefreshIndicator(
      onRefresh: _loadMatches,
      edgeOffset: topPadding,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          10,
          topPadding,
          10,
          140 + MediaQuery.of(context).viewPadding.bottom,
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
      margin: const EdgeInsets.only(bottom: 6),
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
          padding: const EdgeInsets.all(2),
          child: Row(
            children: [
              // Bigger photo thumbnail or placeholder (76x76)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: resolvedPhoto != null
                      ? Image(
                          image: ResizeImage(
                            FileImage(File(resolvedPhoto)),
                            width: 250,
                          ),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
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
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(match.playedAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: AppColors.matchDuration,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${match.duration}m',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (match.players.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Icon(
                            Icons.people,
                            size: 14,
                            color: AppColors.metricPlayers,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${match.players.length}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (match.winner != null) ...[
                          const SizedBox(width: 10),
                          Icon(
                            Icons.emoji_events,
                            size: 14,
                            color: AppColors.winnerGold,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              match.winner!,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.winnerGold,
                                fontWeight: FontWeight.w600,
                                // add a shadow to the text
                                shadows: [
                                  Shadow(
                                    color: AppColors.metricWinnerShadow,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
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
