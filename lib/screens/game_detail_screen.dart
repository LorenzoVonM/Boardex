import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/board_game.dart';
import '../repositories/board_game_repository.dart';
import '../repositories/match_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';
import 'add_game_screen.dart';

class GameDetailScreen extends StatelessWidget {
  final BoardGame game;

  const GameDetailScreen({super.key, required this.game});

  Future<void> _deleteGame(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: Text('Are you sure you want to delete "${game.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && game.id != null) {
      await BoardGameRepository.instance.delete(game.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game deleted'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weightColor = getWeightColor(game.weight);

    final topBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Game Details',
        titleColor: AppColors.headerCoral,
        titleIcon: Icons.grid_view_rounded,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: topBarHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo / Placeholder - 1:1 square starting below AppBar, slides behind on scroll
            Stack(
              children: [
                Hero(
                  tag: 'game-photo-${game.id}',
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: game.photoPath != null
                        ? Image.file(
                            File(game.photoPath!),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(context);
                            },
                          )
                        : _buildPlaceholder(context),
                  ),
                ),
                // Gradient overlay for title readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Title overlay on photo
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: Text(
                    game.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF0F0F0),
                      letterSpacing: -0.5,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                ),
              ],
            ),

            // Info cards row — all 4 in a single row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      Icons.people,
                      '${game.minPlayers}-${game.maxPlayers}',
                      'Players',
                      iconColor: AppColors.metricPlayers,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      Icons.timer,
                      '${game.duration}m',
                      'Duration',
                      iconColor: AppColors.metricDuration,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      Icons.star_rounded,
                      game.rating.toStringAsFixed(1),
                      'Rating',
                      iconColor: getRatingColor(game.rating),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      Icons.fitness_center,
                      game.weight.toStringAsFixed(1),
                      'Weight',
                      iconColor: weightColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      Icons.casino,
                      game.timesPlayed.toString(),
                      'Played',
                      iconColor: AppColors.metricPlayed,
                    ),
                  ),
                ],
              ),
            ),

            // Ownership & Marketplace Badges
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  // Ownership Badge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: game.isOwned
                            ? AppColors.ownedTealBg
                            : AppColors.notOwnedSlateBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: game.isOwned
                              ? AppColors.ownedTealBorder
                              : AppColors.notOwnedSlateBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            game.isOwned
                                ? Icons.check_circle_rounded
                                : Icons.cancel_outlined,
                            size: 18,
                            color: game.isOwned
                                ? AppColors.ownedTeal
                                : AppColors.notOwnedSlate,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            game.isOwned ? 'Owned' : 'Not Owned',
                            style: TextStyle(
                              color: game.isOwned
                                  ? AppColors.ownedTeal
                                  : AppColors.notOwnedSlate,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // For Sale Badge
                  if (game.markForSell) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.sellGreenBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.sellGreenBorder,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sell,
                              size: 18,
                              color: AppColors.sellGreen,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'For Sale',
                              style: TextStyle(
                                color: AppColors.sellGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // For Trade Badge
                  if (game.markForTrade) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.tradeBlueBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.tradeBlueBorder,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              size: 18,
                              color: AppColors.tradeBlue,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'For Trade',
                              style: TextStyle(
                                color: AppColors.tradeBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Sell Price Chip
            if (game.sellPrice != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sell Price',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Chip(
                          label: Text('\$${game.sellPrice!.toStringAsFixed(2)}'),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sellGreen,
                          ),
                          backgroundColor: AppColors.sellGreenBg,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Last Played Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Played',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<DateTime?>(
                    future: MatchRepository.instance.getLastPlayedDate(game.name),
                    builder: (context, snapshot) {
                      final date = snapshot.data;
                      final String labelText;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        labelText = '...';
                      } else if (date != null) {
                        labelText = DateFormat('MMM d, yyyy').format(date);
                      } else {
                        labelText = 'Never';
                      }

                      final bool hasDate = date != null;

                      return Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text(labelText),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: hasDate
                                  ? AppColors.tradeBlue
                                  : colorScheme.onSurfaceVariant,
                            ),
                            backgroundColor: hasDate
                                ? AppColors.tradeBlueBg
                                : colorScheme.surfaceContainerHighest,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Mechanics chips
            if (game.mechanics.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mechanics',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: game.mechanics.map((m) {
                        return Chip(
                          label: Text(m),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          backgroundColor: colorScheme.primaryContainer,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Category chips
            if (game.categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: game.categories.map((c) {
                        return Chip(
                          label: Text(c),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          backgroundColor: colorScheme.secondaryContainer,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Bottom padding for floating toolbar
            const SizedBox(height: 16),
          ],
        ),
      ),

      // Floating bottom toolbar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(80, 0, 80, 12),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(24),
            color: colorScheme.primaryContainer,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit Game',
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddGameScreen(gameToEdit: game),
                        ),
                      );
                      if (result == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: Icon(
                      Icons.edit_rounded,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 20,
                    width: 1,
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Delete Game',
                    onPressed: () => _deleteGame(context),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.casino,
        size: 80,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String value,
    String label, {
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor ?? colorScheme.primary),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
