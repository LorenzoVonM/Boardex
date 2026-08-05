import 'dart:io';
import 'package:flutter/material.dart';
import '../models/board_game.dart';
import '../repositories/board_game_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';
import 'game_detail_screen.dart';
import 'marketplace_export_screen.dart';

class ForSellGamesScreen extends StatefulWidget {
  const ForSellGamesScreen({super.key});

  @override
  State<ForSellGamesScreen> createState() => _ForSellGamesScreenState();
}

class _ForSellGamesScreenState extends State<ForSellGamesScreen> {
  late Future<List<BoardGame>> _forSellGamesFuture;
  final Set<int> _selectedGameIds = {};
  List<BoardGame> _loadedGames = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  void _loadGames() {
    setState(() {
      _forSellGamesFuture = BoardGameRepository.instance
          .search(markForSell: true)
          .then((games) {
        _loadedGames = games;
        // By default all games are selected
        _selectedGameIds.clear();
        for (final g in games) {
          if (g.id != null) {
            _selectedGameIds.add(g.id!);
          }
        }
        return games;
      });
    });
  }

  void _toggleSelection(int gameId) {
    setState(() {
      if (_selectedGameIds.contains(gameId)) {
        _selectedGameIds.remove(gameId);
      } else {
        _selectedGameIds.add(gameId);
      }
    });
  }

  void _exportCatalog() {
    final selectedGames =
        _loadedGames.where((g) => _selectedGameIds.contains(g.id)).toList();

    if (selectedGames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one game to export.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketplaceExportScreen(games: selectedGames),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 12;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Marketplace',
        titleColor: const Color(0xFFEAB308),
        titleIcon: Icons.storefront_rounded,
        actions: [
          IconButton(
            tooltip: 'Export Catalog',
            icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
            onPressed: _exportCatalog,
          ),
        ],
      ),
      body: FutureBuilder<List<BoardGame>>(
        future: _forSellGamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final games = snapshot.data ?? [];
          if (games.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No games marked for sale',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.fromLTRB(
              12,
              topPadding,
              12,
              24 + MediaQuery.of(context).viewPadding.bottom,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.76,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              final isSelected =
                  game.id != null && _selectedGameIds.contains(game.id);

              return _MarketplaceGameCard(
                game: game,
                isSelected: isSelected,
                onToggleSelect: () {
                  if (game.id != null) {
                    _toggleSelection(game.id!);
                  }
                },
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameDetailScreen(game: game),
                    ),
                  );
                  if (result == true) {
                    _loadGames();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MarketplaceGameCard extends StatelessWidget {
  final BoardGame game;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onTap;

  const _MarketplaceGameCard({
    required this.game,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.headerCoral
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area with Checkbox overlay and Price Tag (NO gradient overlay)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  game.photoPath != null
                      ? Image.file(
                          File(game.photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(colorScheme),
                        )
                      : _buildPlaceholder(colorScheme),

                  // Checkbox overlay (Top-Left)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: InkWell(
                      onTap: onToggleSelect,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? AppColors.headerCoral
                              : Colors.white70,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Badges (Bottom-Right): Trade icon tag + Price tag badge
                  if (game.markForTrade || game.sellPrice != null)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (game.markForTrade)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tradeBlueBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.tradeBlue.withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: const Icon(
                                Icons.swap_horiz_rounded,
                                size: 14,
                                color: AppColors.tradeBlue,
                              ),
                            ),
                          if (game.markForTrade && game.sellPrice != null)
                            const SizedBox(width: 4),
                          if (game.sellPrice != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.sellGreenBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.sellGreen.withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '\$${game.sellPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.sellGreen,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Game Title section (tall enough for 2 lines)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: SizedBox(
                height: 34,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    game.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.casino,
          color: colorScheme.onSurfaceVariant,
          size: 32,
        ),
      ),
    );
  }
}
