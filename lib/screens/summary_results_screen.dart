import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../models/summary_export.dart';
import '../repositories/board_game_repository.dart';
import '../repositories/match_repository.dart';
import '../utils/theme_utils.dart';
import 'summary_export_screen.dart';
import 'match_detail_screen.dart';

class SummaryResultsScreen extends StatefulWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final MatchResult? resultFilter;
  final List<String>? players;

  const SummaryResultsScreen({
    super.key,
    required this.fromDate,
    required this.toDate,
    this.resultFilter,
    this.players,
  });

  @override
  State<SummaryResultsScreen> createState() => _SummaryResultsScreenState();
}

/// Holds grouped data for a single game in the summary.
class _SummaryResultsScreenState extends State<SummaryResultsScreen> {
  List<SummaryGameSummary> _summaries = [];
  bool _isLoading = true;
  int _totalMatches = 0;
  Map<String, int> _matchCountByDay = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final matches = await MatchRepository.instance.searchForSummary(
        resultFilter: widget.resultFilter,
        fromDate: widget.fromDate,
        toDate: widget.toDate,
        players: widget.players,
      );

      // Group by game name (case-insensitive)
      final Map<String, List<GameMatch>> grouped = {};
      final Map<String, String> canonicalNames = {};
      for (final match in matches) {
        final key = match.gameName.toLowerCase();
        grouped.putIfAbsent(key, () => []).add(match);
        canonicalNames.putIfAbsent(key, () => match.gameName);
      }

      // Build summaries
      final allGames = await BoardGameRepository.instance.getAll();
      final List<SummaryGameSummary> summaries = [];
      for (final entry in grouped.entries) {
        final gameName = canonicalNames[entry.key]!;
        final gameMatches = entry.value;

        // Get rating from library (case-insensitive)
        double? rating;
        final libraryGame = allGames.where(
          (g) => g.name.toLowerCase() == entry.key,
        );
        if (libraryGame.isNotEmpty) {
          rating = libraryGame.first.rating;
        }

        // Get photo from the most recent match
        final mostRecentMatch = gameMatches.first; // already sorted DESC
        String? photoPath;
        if (mostRecentMatch.useLibraryPhoto) {
          photoPath = await BoardGameRepository.instance.getPhotoPath(gameName);
        } else {
          photoPath = mostRecentMatch.photoPath;
        }

        // If no match photo, try library photo as fallback
        if (photoPath == null || photoPath.isEmpty) {
          photoPath = await BoardGameRepository.instance.getPhotoPath(gameName);
        }

        summaries.add(
          SummaryGameSummary.fromMatches(
            gameName: gameName,
            matches: gameMatches,
            timesPlayed: gameMatches.length,
            rating: rating,
            photoPath: photoPath,
          ),
        );
      }

      // Sort by most played first
      summaries.sort((a, b) => b.timesPlayed.compareTo(a.timesPlayed));

      // Compute daily match counts for the heatmap
      final Map<String, int> dailyCounts = {};
      for (final match in matches) {
        final key = DateFormat('yyyy-MM-dd').format(match.playedAt);
        dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
      }

      setState(() {
        _summaries = summaries;
        _totalMatches = matches.length;
        _matchCountByDay = dailyCounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading summary: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('MMM d');

    final appBarDateFmt = DateFormat('MMM d');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${appBarDateFmt.format(widget.fromDate)} – ${appBarDateFmt.format(widget.toDate)}',
        ),
        actions: _isLoading || _summaries.isEmpty
            ? null
            : [
                IconButton(
                  tooltip: 'Export summary image',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SummaryExportScreen(exportData: _buildExportData()),
                      ),
                    );
                  },
                  icon: const Icon(Icons.ios_share_rounded),
                ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summaries.isEmpty
          ? _buildEmpty(colorScheme, textTheme)
          : _buildContent(colorScheme, textTheme, dateFormat),
    );
  }

  Widget _buildEmpty(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No matches found',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    ColorScheme colorScheme,
    TextTheme textTheme,
    DateFormat dateFormat,
  ) {
    return CustomScrollView(
      slivers: [
        // Stats header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dateFormat.format(widget.fromDate)} – ${dateFormat.format(widget.toDate)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$_totalMatches matches',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'across ${_summaries.length} games',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (widget.resultFilter != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        widget.resultFilter!.icon,
                        size: 14,
                        color: widget.resultFilter!.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filtered by: ${widget.resultFilter!.label}',
                        style: textTheme.bodySmall?.copyWith(
                          color: widget.resultFilter!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.players != null && widget.players!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Players: ${widget.players!.join(', ')}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // Activity heatmap
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _buildActivityHeatmap(colorScheme, textTheme),
          ),
        ),

        const SliverToBoxAdapter(child: Divider(indent: 16, endIndent: 16)),

        // Game summary cards in a grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildGameCard(_summaries[index], colorScheme, textTheme),
              childCount: _summaries.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityHeatmap(ColorScheme colorScheme, TextTheme textTheme) {
    const double cellSize = 10;
    const double cellGap = 2;
    const double cellStep = cellSize + cellGap;
    const double labelWidth = 14;

    // Align fromDate backward to Monday
    final firstMonday = widget.fromDate.subtract(
      Duration(days: (widget.fromDate.weekday - 1)),
    );
    // Align toDate forward to Sunday
    final daysToSunday = (7 - widget.toDate.weekday) % 7;
    final lastSunday = widget.toDate.add(Duration(days: daysToSunday));

    final totalDays = lastSunday.difference(firstMonday).inDays + 1;
    final numWeeks = (totalDays / 7).ceil();

    // Day-of-week labels
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    Color cellColor(int count) {
      if (count == 0) return colorScheme.surfaceContainerHighest;
      if (count == 1) return Colors.green.withValues(alpha: 0.2);
      if (count == 2) return Colors.green.withValues(alpha: 0.4);
      if (count == 3) return Colors.green.withValues(alpha: 0.6);
      if (count == 4) return Colors.green.withValues(alpha: 0.8);
      return Colors.green; // 5+
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day-of-week labels
            SizedBox(
              width: labelWidth,
              child: Column(
                children: List.generate(7, (dayIndex) {
                  return SizedBox(
                    height: cellStep,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Text(
                          dayLabels[dayIndex],
                          style: TextStyle(
                            fontSize: 8,
                            height: 1,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Grid — scrollable if the range is wide
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true, // most recent weeks visible first
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(numWeeks, (weekIndex) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: weekIndex < numWeeks - 1 ? cellGap : 0,
                      ),
                      child: Column(
                        children: List.generate(7, (dayIndex) {
                          final date = firstMonday.add(
                            Duration(days: weekIndex * 7 + dayIndex),
                          );
                          final dateKey = DateFormat('yyyy-MM-dd').format(date);
                          final count = _matchCountByDay[dateKey] ?? 0;
                          final isInRange =
                              !date.isBefore(widget.fromDate) &&
                              !date.isAfter(widget.toDate);

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: dayIndex < 6 ? cellGap : 0,
                            ),
                            child: Tooltip(
                              message: isInRange
                                  ? '$count match${count == 1 ? '' : 'es'} on ${DateFormat('MMM d').format(date)}'
                                  : '',
                              child: Container(
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  color: isInRange
                                      ? cellColor(count)
                                      : colorScheme.surfaceContainerHighest
                                            .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        // Legend
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: labelWidth),
            Text(
              '0',
              style: TextStyle(
                fontSize: 8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 3),
            for (int i = 0; i <= 5; i++)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: cellColor(i),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            Text(
              '5+',
              style: TextStyle(
                fontSize: 8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameCard(
    SummaryGameSummary summary,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final borderColor = summary.dominantResult.color;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: InkWell(
        onTap: () => _showGameMatches(summary),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo or placeholder
            if (summary.photoPath != null && summary.photoPath!.isNotEmpty)
              Image.file(
                File(summary.photoPath!),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPhotoPlaceholder(colorScheme),
              )
            else
              _buildPhotoPlaceholder(colorScheme),

            // Gradient overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 48,
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

            // Game name — bottom
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Text(
                summary.gameName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Match count badge — top left
            Positioned(
              top: 5,
              left: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${summary.timesPlayed}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SummaryExportData _buildExportData() {
    return SummaryExportData(
      fromDate: widget.fromDate,
      toDate: widget.toDate,
      resultFilter: widget.resultFilter,
      players: widget.players ?? const [],
      totalMatches: _totalMatches,
      matchCountByDay: _matchCountByDay,
      summaries: _summaries,
    );
  }

  Widget _buildPhotoPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.casino,
          size: 40,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  void _showGameMatches(SummaryGameSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.casino, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary.gameName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${summary.timesPlayed} matches',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: summary.matches.length,
                    itemBuilder: (context, index) {
                      final match = summary.matches[index];
                      final resultColor = match.result.color;
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: resultColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            match.result.icon,
                            size: 18,
                            color: resultColor,
                          ),
                        ),
                        title: Text(
                          dateFormat.format(match.playedAt),
                          style: textTheme.bodyMedium,
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              '${match.duration} min',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (match.players.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.people,
                                size: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${match.players.length}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (match.winner != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.emoji_events,
                                size: 12,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                match.winner!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.amber[700],
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Container(
                          child: buildMatchResultTag(match.result),
                        ),
                        onTap: () {
                          Navigator.pop(context); // close bottom sheet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MatchDetailScreen(match: match),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
