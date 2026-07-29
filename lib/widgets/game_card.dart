import 'dart:io';
import 'package:flutter/material.dart';
import '../models/board_game.dart';
import '../utils/theme_utils.dart';

/// A reusable game card widget used in grid views (Library, Search Results).
class GameCard extends StatelessWidget {
  final BoardGame game;
  final VoidCallback onTap;

  const GameCard({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'game-photo-${game.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    game.photoPath != null
                        ? Image.file(
                            File(game.photoPath!),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPhotoPlaceholder(context);
                            },
                          )
                        : _buildPhotoPlaceholder(context),
                    if (game.markForSell || game.markForTrade)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (game.markForSell)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.sellGreen,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.sell,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            if (game.markForSell && game.markForTrade)
                              const SizedBox(width: 4),
                            if (game.markForTrade)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.tradeBlue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.swap_horiz,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 13,
                              color: AppColors.metricPlayers,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${game.minPlayers}-${game.maxPlayers}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.timer,
                              size: 13,
                              color: AppColors.metricDuration,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${game.duration}m',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.fitness_center,
                              size: 13,
                              color: getWeightColor(game.weight),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              game.weight.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: getRatingColor(game.rating),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              game.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.casino,
                              size: 13,
                              color: AppColors.metricPlayed,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${game.timesPlayed}x',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primaryContainer,
      child: Icon(
        Icons.casino,
        size: 48,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}
