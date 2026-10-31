import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/match.dart';
import '../repositories/board_game_repository.dart';
import '../repositories/match_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';
import 'add_match_screen.dart';
import 'match_story_export_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final GameMatch match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  String? _resolvedPhotoPath;

  GameMatch get match => widget.match;

  @override
  void initState() {
    super.initState();
    _resolvePhoto();
  }

  Future<void> _resolvePhoto() async {
    String? photoPath;
    if (match.useLibraryPhoto) {
      photoPath = await BoardGameRepository.instance.getPhotoPath(
        match.gameName,
      );
    } else {
      photoPath = match.photoPath;
    }
    if (mounted) {
      setState(() {
        _resolvedPhotoPath = photoPath;
      });
    }
  }

  Future<void> _deleteMatch(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMatchTitle),
        content: Text(l10n.deleteMatchConfirmation(match.gameName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );

    if (confirm == true && match.id != null) {
      await MatchRepository.instance.delete(match.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.matchDeleted),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final topBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: l10n.matchDetailsTitle,
        titleColor: AppColors.brandTeal,
        titleIcon: Icons.sports_esports_rounded,
        actions: [
          IconButton(
            tooltip: l10n.exportStoryTooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchStoryExportScreen(
                    match: match,
                    photoPath: _resolvedPhotoPath,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: topBarHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo with result icon and game name - 1:1 square starting below App Bar, slides behind on scroll
            Stack(
              children: [
                if (_resolvedPhotoPath != null)
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.file(
                      File(_resolvedPhotoPath!),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  )
                else
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.casino,
                        size: 80,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                // Gradient overlay
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
                // Game name overlay on photo (like Game Detail)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: Text(
                    match.gameName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF0F0F0),
                      letterSpacing: -0.5,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                ),
                // Result badge — top right corner
                Positioned(
                  top: 12,
                  right: 12,
                  child: buildMatchResultTag(
                    match.result,
                    size: MatchResultTagSize.regular,
                  ),
                ),
              ],
            ),

            // Info cards row — all 3 in one row, flat style matching game detail
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      Icons.calendar_today,
                      iconColor: AppColors.matchDate,
                      dateFormat.format(match.playedAt),
                      l10n.dateLabel,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      Icons.access_time,
                      iconColor: AppColors.matchTime,
                      timeFormat.format(match.playedAt),
                      l10n.timeLabel,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      Icons.timer,
                      iconColor: AppColors.matchDuration,
                      '${match.duration}m',
                      l10n.durationLabel,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Players with scores
                  if (match.players.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.playersLabel,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...match.players.map((name) {
                              final score = match.playerScores[name];
                              final isWinner = match.winner == name;
                              final playerColor = Color(
                                match.playerColors[name] ??
                                    Colors.black.toARGB32(),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: playerColor,
                                      child: Text(
                                        name[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            name,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: playerColor,
                                                  fontWeight: isWinner
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                          if (isWinner) ...[
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.emoji_events,
                                              size: 14,
                                              color: Colors.amber[700],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (score != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isWinner
                                              ? Colors.amber.withValues(
                                                  alpha: 0.2,
                                                )
                                              : colorScheme
                                                    .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          score.toString(),
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isWinner
                                                ? Colors.amber[800]
                                                : null,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom padding for floating toolbar
            const SizedBox(height: 16),
          ],
        ),
      ),

      // Floating bottom toolbar — matching game detail screen pattern
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
                    tooltip: l10n.editMatchTooltip,
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddMatchScreen(matchToEdit: match),
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
                    tooltip: l10n.deleteMatchTitle,
                    onPressed: () => _deleteMatch(context),
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
              textAlign: TextAlign.center,
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
