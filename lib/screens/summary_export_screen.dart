import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:intl/intl.dart';

import '../models/summary_export.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';

class SummaryExportScreen extends StatefulWidget {
  final SummaryExportData exportData;

  const SummaryExportScreen({super.key, required this.exportData});

  @override
  State<SummaryExportScreen> createState() => _SummaryExportScreenState();
}

class _SummaryExportScreenState extends State<SummaryExportScreen> {
  final GlobalKey _captureKey = GlobalKey();
  late SummaryExportOptions _options;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _options = SummaryExportOptions.defaults();
  }

  Future<void> _saveImage() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      FocusManager.instance.primaryFocus?.unfocus();
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 16));

      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Export preview is not ready yet.');
      }

      final image = await boundary.toImage(pixelRatio: _options.pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Could not encode the export image.');
      }

      final pngBytes = byteData.buffer.asUint8List();
      await ImageGallerySaver().saveImage(pngBytes);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_options.template.displayName} saved to gallery.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save summary export: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: 'Export Summary',
        titleColor: Color(0xFF7C3AED),
        titleIcon: Icons.insights_rounded,
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            topPadding,
            16,
            24 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: RepaintBoundary(
                      key: _captureKey,
                      child: SizedBox(
                        width: _options.canvasWidth,
                        child: SummaryExportPoster(
                          data: widget.exportData,
                          options: _options,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveImage,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Image',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryExportPoster extends StatelessWidget {
  final SummaryExportData data;
  final SummaryExportOptions options;

  const SummaryExportPoster({
    super.key,
    required this.data,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return _SummaryResultsPortraitExport(data: data);
  }
}

class _SummaryResultsPortraitExport extends StatelessWidget {
  final SummaryExportData data;

  static const double _posterWidth = 480;
  static const double _horizontalPadding = 18;
  static const double _topPadding = 18;
  static const double _bottomPadding = 24;
  static const double _titleBlockHeight = 64;
  static const double _statsSectionHeight = 130;
  static const double _titleToStatsGap = 14;
  static const double _statsToDividerGap = 8;
  static const double _dividerToGridGap = 8;
  static const double _dividerHeight = 1.4;
  static const int _gridColumns = 5;
  static const double _gridGap = 4;

  const _SummaryResultsPortraitExport({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateRange =
        '${DateFormat('MMM d').format(data.fromDate)} - ${DateFormat('MMM d').format(data.toDate)}';
    final visibleSummaries = data.summaries;
    final gridRowCount = math.max(
      1,
      (visibleSummaries.length / _gridColumns).ceil(),
    );
    final gridCellSize =
        ((_posterWidth - (_horizontalPadding * 2)) -
            ((_gridColumns - 1) * _gridGap)) /
        _gridColumns;
    final gridHeight =
        (gridRowCount * gridCellSize) + ((gridRowCount - 1) * _gridGap);
    final posterHeight =
        _topPadding +
        _titleBlockHeight +
        _titleToStatsGap +
        _statsSectionHeight +
        _statsToDividerGap +
        _dividerHeight +
        _dividerToGridGap +
        gridHeight +
        _bottomPadding;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: _posterWidth,
        height: posterHeight,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerLow,
                colorScheme.surfaceContainerLowest,
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 28,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  left: -80,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.09),
                    ),
                    child: const SizedBox(width: 260, height: 260),
                  ),
                ),
                Positioned(
                  bottom: -110,
                  right: -70,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.resultTie.withValues(alpha: 0.08),
                    ),
                    child: const SizedBox(width: 220, height: 220),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _horizontalPadding,
                    _topPadding,
                    _horizontalPadding,
                    _bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: _titleBlockHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Board Game Recap',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateRange,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: _titleToStatsGap),
                      SizedBox(
                        height: _statsSectionHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _SummaryResultsExportStatGrid(data: data),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: _SummaryResultsExportHeatmapCard(
                                      data: data,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: _statsToDividerGap),
                      Divider(
                        height: 1,
                        thickness: 1.4,
                        color: colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: _dividerToGridGap),
                      _SummaryResultsExportGameGrid(
                        summaries: visibleSummaries,
                        itemSize: gridCellSize,
                        gap: _gridGap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryResultsExportStatGrid extends StatelessWidget {
  final SummaryExportData data;

  const _SummaryResultsExportStatGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final winRate = '${(data.winRate * 100).round()}%';

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _SummaryResultsMetricCard(
                  label: 'Matches',
                  value: '${data.totalMatches}',
                  accentColor: AppColors.headerCoral,
                  compact: true,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _SummaryResultsMetricCard(
                  label: 'Games',
                  value: '${data.totalGames}',
                  accentColor: AppColors.brandBlue,
                  compact: true,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _SummaryResultsMetricCard(
                  label: 'Win Rate',
                  value: winRate,
                  accentColor: AppColors.brandTeal,
                  compact: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _SummaryResultsMetricCard(
                  label: 'Wins',
                  value: '${data.totalWins}',
                  accentColor: AppColors.resultWon,
                  compact: true,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _SummaryResultsMetricCard(
                  label: 'Draws',
                  value: '${data.totalTies}',
                  accentColor: AppColors.resultTie,
                  compact: true,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _SummaryResultsMetricCard(
                  label: 'Losses',
                  value: '${data.totalLosses}',
                  accentColor: AppColors.resultLost,
                  compact: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryResultsExportHeatmapCard extends StatelessWidget {
  final SummaryExportData data;

  const _SummaryResultsExportHeatmapCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: _SummaryExportHeatmap(data: data, compact: true),
    );
  }
}

class _SummaryResultsExportGameGrid extends StatelessWidget {
  final List<SummaryGameSummary> summaries;
  final double itemSize;
  final double gap;

  const _SummaryResultsExportGameGrid({
    required this.summaries,
    required this.itemSize,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Text(
          'No games available',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: summaries.map((s) {
        return SizedBox(
          width: itemSize,
          height: itemSize,
          child: _DashboardSummaryGameCard(
            summary: s,
            compact: true,
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryResultsMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final bool compact;

  const _SummaryResultsMetricCard({
    required this.label,
    required this.value,
    required this.accentColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: compact ? 0.14 : 0.1),
        borderRadius: BorderRadius.circular(compact ? 14 : 16),
        border: Border.all(color: accentColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact ? textTheme.bodySmall : textTheme.titleSmall)
                    ?.copyWith(fontWeight: FontWeight.w800, color: accentColor),
              ),
            ),
          ),
          SizedBox(height: compact ? 1.5 : 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact ? textTheme.bodyLarge : textTheme.headlineSmall)
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on SummaryExportTemplate {
  String get displayName {
    switch (this) {
      case SummaryExportTemplate.landscapeDashboard:
        return 'Dashboard Summary';
      case SummaryExportTemplate.summaryResultsPortrait:
        return 'Summary Results Export';
    }
  }
}

class _DashboardSummaryGameCard extends StatelessWidget {
  final SummaryGameSummary summary;
  final bool compact;

  const _DashboardSummaryGameCard({
    required this.summary,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        side: BorderSide(color: summary.dominantResult.color, width: 2.5),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (summary.photoPath != null && summary.photoPath!.isNotEmpty)
            Image.file(
              File(summary.photoPath!),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) =>
                  _PosterPhotoPlaceholder(colorScheme: colorScheme),
            )
          else
            _PosterPhotoPlaceholder(colorScheme: colorScheme),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: compact ? 32 : 48,
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
          Positioned(
            left: compact ? 4 : 6,
            right: compact ? 4 : 6,
            bottom: compact ? 4 : 6,
            child: Text(
              summary.gameName,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.bold,
                height: 1.05,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
              maxLines: compact ? 2 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            top: compact ? 4 : 5,
            left: compact ? 4 : 5,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 4 : 6,
                vertical: compact ? 1 : 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(compact ? 6 : 8),
              ),
              child: Text(
                '${summary.timesPlayed}',
                style: TextStyle(
                  fontSize: compact ? 9 : 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterPhotoPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;

  const _PosterPhotoPlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.casino_rounded,
          size: 36,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _SummaryExportHeatmap extends StatelessWidget {
  final SummaryExportData data;
  final bool compact;

  const _SummaryExportHeatmap({required this.data, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelColor = colorScheme.onSurfaceVariant;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    Color colorForCount(int count) {
      if (count == 0) {
        return colorScheme.surfaceContainerHighest;
      }
      if (count == 1) {
        return AppColors.resultWon.withValues(alpha: 0.25);
      }
      if (count == 2) {
        return AppColors.resultWon.withValues(alpha: 0.45);
      }
      if (count == 3) {
        return AppColors.resultWon.withValues(alpha: 0.65);
      }
      if (count == 4) {
        return AppColors.resultWon.withValues(alpha: 0.82);
      }
      return AppColors.resultWon;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const footerSpacing = 6.0;
        final labelWidth = compact ? 14.0 : 16.0;
        final gap = compact ? 1.5 : 2.0;
        final estimatedCellSize = compact ? 10.0 : 12.0;
        const rows = 7;
        final endWeekdayIndex = data.toDate.weekday - 1;
        final usableWidth = math.max(0.0, constraints.maxWidth - labelWidth);
        final columns = math.max(
          1,
          ((usableWidth + gap) / (estimatedCellSize + gap)).floor(),
        );
        final cellSize = columns == 0
            ? estimatedCellSize
            : (usableWidth - ((columns - 1) * gap)) / columns;
        final gridHeight = (rows * cellSize) + ((rows - 1) * gap);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: labelWidth,
                  height: gridHeight,
                  child: Column(
                    children: List.generate(rows, (rowIndex) {
                      return SizedBox(
                        height: cellSize + (rowIndex < rows - 1 ? gap : 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dayLabels[rowIndex],
                            style: TextStyle(
                              fontSize: compact ? 8 : 9,
                              color: labelColor,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: gridHeight,
                    child: Row(
                      children: List.generate(columns, (columnIndex) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: columnIndex < columns - 1 ? gap : 0,
                          ),
                          child: Column(
                            children: List.generate(rows, (rowIndex) {
                              final weeksFromEnd = columns - 1 - columnIndex;
                              final offsetFromEnd =
                                  (weeksFromEnd * rows) +
                                  (endWeekdayIndex - rowIndex);
                              final date = data.toDate.subtract(
                                Duration(days: offsetFromEnd),
                              );
                              final isAfterEnd = date.isAfter(data.toDate);
                              final inRange =
                                  !isAfterEnd &&
                                  !date.isBefore(data.fromDate) &&
                                  !date.isAfter(data.toDate);
                              final key = DateFormat('yyyy-MM-dd').format(date);
                              final count = inRange
                                  ? data.matchCountByDay[key] ?? 0
                                  : 0;

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: rowIndex < rows - 1 ? gap : 0,
                                ),
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  decoration: BoxDecoration(
                                    color: inRange
                                        ? colorForCount(count)
                                        : colorScheme.surfaceContainerHighest
                                              .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(2),
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
            SizedBox(height: compact ? 8 : footerSpacing),
            Row(
              children: [
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: compact ? 10 : 12,
                    color: labelColor,
                  ),
                ),
                SizedBox(width: compact ? 6 : 8),
                for (var i = 0; i <= 5; i++)
                  Container(
                    width: compact ? 8 : 10,
                    height: compact ? 8 : 10,
                    margin: EdgeInsets.only(right: compact ? 3 : 4),
                    decoration: BoxDecoration(
                      color: colorForCount(i),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Text(
                  '5+',
                  style: TextStyle(
                    fontSize: compact ? 10 : 12,
                    color: labelColor,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d').format(data.toDate),
                  style: TextStyle(
                    fontSize: compact ? 10 : 12,
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
