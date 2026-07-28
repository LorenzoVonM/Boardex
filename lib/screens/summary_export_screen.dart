import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:intl/intl.dart';

import '../models/summary_export.dart';
import '../utils/theme_utils.dart';

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

  void _toggleSection(SummaryExportSection section, bool selected) {
    final sections = Set<SummaryExportSection>.from(_options.sections);
    if (selected) {
      sections.add(section);
    } else {
      if (sections.length == 1) {
        return;
      }
      sections.remove(section);
    }

    setState(() {
      _options = _options.copyWith(sections: sections);
    });
  }

  void _selectTemplate(SummaryExportTemplate template) {
    if (_options.template == template) {
      return;
    }

    setState(() {
      _options = _options.copyWith(template: template);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Summary Export')),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _saveImage,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded),
          label: Text(_isSaving ? 'Saving...' : 'Save Image'),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                _ExportOptionsPanel(
                  options: _options,
                  onTemplateChanged: _selectTemplate,
                  onSectionChanged: _toggleSection,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  color: colorScheme.surfaceContainerLowest,
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportOptionsPanel extends StatelessWidget {
  final SummaryExportOptions options;
  final ValueChanged<SummaryExportTemplate> onTemplateChanged;
  final void Function(SummaryExportSection section, bool selected)
  onSectionChanged;

  const _ExportOptionsPanel({
    required this.options,
    required this.onTemplateChanged,
    required this.onSectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export template',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final template in SummaryExportTemplate.values)
                  ChoiceChip(
                    label: Text(template.shortLabel),
                    selected: options.template == template,
                    onSelected: (_) => onTemplateChanged(template),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              options.template.description,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (options.template.supportsSectionToggles) ...[
              const SizedBox(height: 16),
              Text(
                'Include in image',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Each template uses the same summary data but arranges it with a different visual language.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in _sectionLabels.entries)
                    FilterChip(
                      label: Text(entry.value),
                      selected: options.includes(entry.key),
                      onSelected: (selected) =>
                          onSectionChanged(entry.key, selected),
                    ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'This template always includes its full layout and does not support section toggles.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
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
    return switch (options.template) {
      SummaryExportTemplate.landscapeDashboard => _LandscapeDashboardExport(
        data: data,
        options: options,
      ),
      SummaryExportTemplate.summaryResultsPortrait =>
        _SummaryResultsPortraitExport(data: data),
    };
  }
}

class _LandscapeDashboardExport extends StatelessWidget {
  final SummaryExportData data;
  final SummaryExportOptions options;

  static const double _posterWidth = 960;
  static const double _outerPadding = 24;
  static const double _columnGap = 16;
  static const double _panelChromeHeight = 68;
  static const double _topGamesRowHeight = 84;
  static const double _topGamesGap = 10;
  static const double _heatmapPanelHeight = 188;
  static const double _gridGap = 8;
  static const int _gridColumns = 4;

  const _LandscapeDashboardExport({required this.data, required this.options});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topGames = data.topGames();
    final dashboardChips = _buildDashboardChips();
    final hasDashboardChips = dashboardChips.isNotEmpty;
    final showHeader = options.includes(SummaryExportSection.header);
    final showStats = options.includes(SummaryExportSection.stats);
    final showFilters = options.includes(SummaryExportSection.filters);
    final showActivity = options.includes(SummaryExportSection.activity);
    final showTopGames = options.includes(SummaryExportSection.topGames);
    final heatmapSubtitle = 'ending ${DateFormat('MMM d').format(data.toDate)}';
    final allMatchesPanelHeight = _buildAllMatchesPanelHeight(
      summaryCount: data.summaries.length,
    );
    final topGamesPanelHeight =
        (_topGamesRowHeight * summaryExportTopGamesCount) +
        (_topGamesGap * (summaryExportTopGamesCount - 1)) +
        _panelChromeHeight;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: _posterWidth,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
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
            borderRadius: BorderRadius.circular(30),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showHeader)
                                  _DashboardSummaryHeader(data: data),
                                if (showHeader &&
                                    showFilters &&
                                    hasDashboardChips)
                                  const SizedBox(height: 14),
                                if (showFilters && hasDashboardChips)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: dashboardChips,
                                  ),
                                if ((showHeader ||
                                        (showFilters && hasDashboardChips)) &&
                                    showStats)
                                  const SizedBox(height: 16),
                                if (showStats) _DashboardStatsBand(data: data),
                                if ((showHeader || showFilters || showStats) &&
                                    showTopGames)
                                  const SizedBox(height: 16),
                                if (showTopGames)
                                  SizedBox(
                                    height: topGamesPanelHeight,
                                    child: _LandscapePanel(
                                      title: 'Top games',
                                      subtitle:
                                          'Always shows your 3 most-played games',
                                      child: _DashboardTopGamesList(
                                        summaries: topGames,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 11,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showActivity)
                                  SizedBox(
                                    height: _heatmapPanelHeight,
                                    child: _LandscapePanel(
                                      title: 'Heat map',
                                      subtitle: heatmapSubtitle,
                                      child: _SummaryExportHeatmap(
                                        data: data,
                                        compact: true,
                                      ),
                                    ),
                                  ),
                                if (showActivity) const SizedBox(height: 16),
                                SizedBox(
                                  height: allMatchesPanelHeight,
                                  child: _LandscapePanel(
                                    title: 'All matches',
                                    subtitle:
                                        '${data.totalGames} games in range',
                                    child: _DashboardSummaryGamesGrid(
                                      summaries: data.summaries,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Generated ${DateFormat('MMM d, yyyy • HH:mm').format(DateTime.now())}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
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

  double _buildAllMatchesPanelHeight({required int summaryCount}) {
    final rowCount = math.max(1, (summaryCount / _gridColumns).ceil());
    final cellSize = _dashboardGridCellSize();
    final gridHeight = (rowCount * cellSize) + ((rowCount - 1) * _gridGap);
    return gridHeight + _panelChromeHeight;
  }

  double _dashboardGridCellSize() {
    final contentWidth = _posterWidth - (_outerPadding * 2);
    final columnsWidth = contentWidth - _columnGap;
    final rightColumnWidth = columnsWidth * (11 / 20);
    final panelInnerWidth = rightColumnWidth - (16 * 2);
    return (panelInnerWidth - ((_gridColumns - 1) * _gridGap)) / _gridColumns;
  }

  List<Widget> _buildDashboardChips() {
    final chips = <Widget>[];

    if (data.resultFilter != null) {
      chips.add(
        _InfoChip(
          icon: data.resultFilter!.icon,
          label: data.resultFilter!.label,
          color: data.resultFilter!.color,
        ),
      );
    }

    if (data.players.isNotEmpty) {
      for (final player in data.players.take(3)) {
        chips.add(_InfoChip(icon: Icons.person_rounded, label: player));
      }
      if (data.players.length > 3) {
        chips.add(
          _InfoChip(
            icon: Icons.more_horiz_rounded,
            label: '+${data.players.length - 3} more',
          ),
        );
      }
    }

    return chips;
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
  static const double _statsToDividerGap = 18;
  static const double _dividerToGridGap = 18;
  static const double _dividerHeight = 1.4;
  static const int _gridColumns = 5;
  static const double _gridGap = 4;
  static const double _gridHeightSafety = 14;

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
        (gridRowCount * gridCellSize) +
        ((gridRowCount - 1) * _gridGap) +
        _gridHeightSafety;
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
            borderRadius: BorderRadius.circular(30),
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
            borderRadius: BorderRadius.circular(30),
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
                      SizedBox(
                        height: gridHeight,
                        child: _SummaryResultsExportGameGrid(
                          summaries: visibleSummaries,
                        ),
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

  const _SummaryResultsExportGameGrid({required this.summaries});

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

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemBuilder: (context, index) {
        return _DashboardSummaryGameCard(
          summary: summaries[index],
          compact: true,
        );
      },
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

  String get shortLabel {
    switch (this) {
      case SummaryExportTemplate.landscapeDashboard:
        return 'Dashboard';
      case SummaryExportTemplate.summaryResultsPortrait:
        return 'Summary';
    }
  }

  String get description {
    switch (this) {
      case SummaryExportTemplate.landscapeDashboard:
        return 'A flexible dashboard export with optional sections.';
      case SummaryExportTemplate.summaryResultsPortrait:
        return 'A fixed portrait export based closely on SummaryResultsScreen with stats, heat map, and per-game cards.';
    }
  }

  bool get supportsSectionToggles {
    switch (this) {
      case SummaryExportTemplate.landscapeDashboard:
        return true;
      case SummaryExportTemplate.summaryResultsPortrait:
        return false;
    }
  }
}

class _DashboardSummaryHeader extends StatelessWidget {
  final SummaryExportData data;

  const _DashboardSummaryHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topGame = data.summaries.isEmpty ? null : data.summaries.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primaryContainer, colorScheme.surface],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Board Game Summary',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('MMM d').format(data.fromDate)} - ${DateFormat('MMM d').format(data.toDate)}',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (topGame != null) ...[
            const SizedBox(height: 10),
            Text(
              'Most played so far: ${topGame.gameName}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardStatsBand extends StatelessWidget {
  final SummaryExportData data;

  const _DashboardStatsBand({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164,
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _DashboardStatTile(
                          label: 'Matches',
                          value: '${data.totalMatches}',
                          accentColor: AppColors.headerCoral,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DashboardStatTile(
                          label: 'Games',
                          value: '${data.totalGames}',
                          accentColor: AppColors.brandBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _DashboardStatTile(
                          label: 'Losses',
                          value: '${data.totalLosses}',
                          accentColor: AppColors.resultLost,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DashboardStatTile(
                          label: 'Wins',
                          value: '${data.totalWins}',
                          accentColor: AppColors.resultWon,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 4, child: _DashboardRatioCard(data: data)),
        ],
      ),
    );
  }
}

class _DashboardStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _DashboardStatTile({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardRatioCard extends StatelessWidget {
  final SummaryExportData data;

  const _DashboardRatioCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final winPercent = (data.winRate * 100).round();
    final ratio = data.winLossRatio;
    final detail = ratio == null
        ? 'No win/loss ratio yet'
        : '${ratio.toStringAsFixed(ratio >= 10 ? 0 : 1)} W/L';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Win ratio',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '$winPercent%',
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.resultWon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.totalWins} wins • ${data.totalLosses} losses • ${data.totalTies} draws',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandscapePanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _LandscapePanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chipColor = color ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: chipColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DashboardTopGamesList extends StatelessWidget {
  final List<SummaryGameSummary> summaries;

  const _DashboardTopGamesList({required this.summaries});

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Text(
          'No top games available',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 84,
          child: _LandscapeGameTile(summary: summaries[index]),
        );
      },
    );
  }
}

class _DashboardSummaryGamesGrid extends StatelessWidget {
  final List<SummaryGameSummary> summaries;

  static const double _gap = 8;
  static const int _crossAxisCount = 4;

  const _DashboardSummaryGamesGrid({required this.summaries});

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

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        crossAxisSpacing: _gap,
        mainAxisSpacing: _gap,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return _DashboardSummaryGameCard(summary: summaries[index]);
      },
    );
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

class _LandscapeGameTile extends StatelessWidget {
  final SummaryGameSummary summary;

  const _LandscapeGameTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: summary.dominantResult.color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: summary.photoPath != null && summary.photoPath!.isNotEmpty
                  ? Image.file(
                      File(summary.photoPath!),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) =>
                          _PosterPhotoPlaceholder(colorScheme: colorScheme),
                    )
                  : _PosterPhotoPlaceholder(colorScheme: colorScheme),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    summary.gameName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${summary.timesPlayed} plays • ${summary.wins}W ${summary.ties}D ${summary.losses}L',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (summary.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          summary.rating!.toStringAsFixed(1),
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
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

const Map<SummaryExportSection, String> _sectionLabels = {
  SummaryExportSection.header: 'Header',
  SummaryExportSection.stats: 'Stats',
  SummaryExportSection.filters: 'Filters',
  SummaryExportSection.activity: 'Heatmap',
  SummaryExportSection.topGames: 'Top games',
};
