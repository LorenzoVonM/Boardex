import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_social_share/flutter_social_share.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/board_game.dart';
import '../models/match.dart';
import '../repositories/board_game_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';

// ─── Background Color Themes ──────────────────────────────────────────────────
// Each value is one selectable gradient theme for the story background.
// To add a new theme:
//   1. Add a new value here (e.g. `ocean`).
//   2. Add a matching case in label, gradientStart, gradientEnd, and backgroundColor below.
//   3. Add the two AppColors tokens (light + dark stop) in lib/utils/theme_utils.dart.
enum StoryBackgroundStyle { coral, sand, moss, lightPurple, twilight }

extension StoryBackgroundStyleUi on StoryBackgroundStyle {
  // Human-readable name shown in the tooltip of each color swatch.
  String get label => switch (this) {
    StoryBackgroundStyle.coral => 'Coral',
    StoryBackgroundStyle.sand => 'Sand',
    StoryBackgroundStyle.moss => 'Moss',
    StoryBackgroundStyle.lightPurple => 'Light Purple',
    StoryBackgroundStyle.twilight => 'Twilight',
  };

  // Top-left color stop of the background gradient.
  // Modify the AppColors tokens in theme_utils.dart to change individual theme colors.
  Color get gradientStart => switch (this) {
    StoryBackgroundStyle.coral => AppColors.storyCoralLight,
    StoryBackgroundStyle.sand => AppColors.storySandLight,
    StoryBackgroundStyle.moss => AppColors.storyMossLight,
    StoryBackgroundStyle.lightPurple => AppColors.storyPurpleLight,
    StoryBackgroundStyle.twilight => AppColors.storyBlueLight,
  };

  // Bottom-right color stop of the background gradient.
  Color get gradientEnd => switch (this) {
    StoryBackgroundStyle.coral => AppColors.storyCoralDark,
    StoryBackgroundStyle.sand => AppColors.storySandDark,
    StoryBackgroundStyle.moss => AppColors.storyMossDark,
    StoryBackgroundStyle.lightPurple => AppColors.storyPurpleDark,
    StoryBackgroundStyle.twilight => AppColors.storyBlueDark,
  };

  // The gradient applied to the story background and the on-screen preview.
  // Change begin/end Alignment to rotate the gradient direction.
  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  // Used for card borders and accent elements inside the sticker
  Color get backgroundColor => gradientEnd;
}

class MatchStoryExportScreen extends StatefulWidget {
  final GameMatch match;
  final String? photoPath;

  const MatchStoryExportScreen({
    super.key,
    required this.match,
    this.photoPath,
  });

  @override
  State<MatchStoryExportScreen> createState() => _MatchStoryExportScreenState();
}

class _MatchStoryExportScreenState extends State<MatchStoryExportScreen> {
  // Final export pixel width. Instagram stories are 1080 px wide.
  // Increase for a higher-resolution PNG (uses more memory/time).
  static const double _storyExportTargetWidth = 1080;

  // On-screen preview widget size in logical pixels.
  // This does NOT affect export resolution — the export always scales to _storyExportTargetWidth.
  // Aspect ratio is 9:16 (Instagram story format).
  static const double _stickerCanvasWidth = 320.0;
  static const double _stickerCanvasHeight = 320.0 / (9 / 16);

  final GlobalKey _stickerKey = GlobalKey();
  bool _isSharing = false;
  StoryBackgroundStyle _selectedBackground = StoryBackgroundStyle.coral;

  BoardGame? _game;
  bool _showRating = false;
  bool _showWeight = false;
  bool _showTimesPlayed = false;
  bool _showPlayers = false;

  @override
  void initState() {
    super.initState();
    _loadGameContext();
  }

  Future<void> _loadGameContext() async {
    final game = await BoardGameRepository.instance.getGameByName(
      widget.match.gameName,
    );
    if (mounted) {
      setState(() {
        _game = game;
      });
    }
  }

  // ─── Image Capture & Compositing ────────────────────────────────────────────
  // Composites the gradient background + the sticker widget into one 1080×1920 PNG.
  // The file is written to the system temp directory and its path is returned.
  // Must be passed as backgroundAssetUri so Instagram fills the full story canvas.
  Future<String> _captureStickerImage() async {
    await WidgetsBinding.instance.endOfFrame;

    final boundary =
        _stickerKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Could not capture story sticker.');
    }

    // Final export canvas dimensions — always 1080×1920 (full Instagram story).
    // Do not change unless Instagram changes its story format requirements.
    const double exportWidth = 1080;
    const double exportHeight = 1920;

    final pixelRatio = math.max(
      1.0,
      _storyExportTargetWidth / boundary.size.width,
    );
    final stickerImage = await boundary.toImage(pixelRatio: pixelRatio);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      Rect.fromLTWH(0, 0, exportWidth, exportHeight),
    );

    // Draw gradient background filling the full story canvas
    final gradientPaint = Paint()
      ..shader = _selectedBackground.gradient.createShader(
        Rect.fromLTWH(0, 0, exportWidth, exportHeight),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, exportWidth, exportHeight),
      gradientPaint,
    );

    // ── Sticker size relative to the full story canvas ─────────────────────────
    // 0.9 = the sticker fills 90% of the canvas width and height,
    // leaving a thin strip of gradient background visible around all edges.
    // Raise toward 1.0 to fill more of the frame; lower to show more background border.
    const double stickerScale = 0.9;
    final targetW = exportWidth * stickerScale;
    final targetH = exportHeight * stickerScale;
    final offsetX = (exportWidth - targetW) / 2;
    final offsetY = (exportHeight - targetH) / 2;
    canvas.drawImageRect(
      stickerImage,
      Rect.fromLTWH(
        0,
        0,
        stickerImage.width.toDouble(),
        stickerImage.height.toDouble(),
      ),
      Rect.fromLTWH(offsetX, offsetY, targetW, targetH),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final fullImage = await picture.toImage(
      exportWidth.toInt(),
      exportHeight.toInt(),
    );

    final byteData = await fullImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Could not encode story image.');
    }

    final bytes = byteData.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'match_story_${widget.match.id ?? DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = p.join(tempDir.path, fileName);
    await File(filePath).writeAsBytes(bytes, flush: true);

    return filePath;
  }

  Future<void> _shareStory() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    try {
      final imagePath = await _captureStickerImage();
      // backgroundAssetUri fills the full Instagram Story canvas — no user resizing needed
      await FlutterSocialShare.shareToInstagram(
        backgroundAssetUri: Uri.file(imagePath),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Instagram Story...')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().toLowerCase().contains('instagram')
          ? 'Could not open Instagram Story. Check if Instagram is installed.'
          : 'Could not export story: $e';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPlayers = widget.match.players.isNotEmpty;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 12;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: 'Export Story',
        titleColor: Color(0xFF7C3AED),
        titleIcon: Icons.auto_awesome_rounded,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Story Preview - Fixed Canvas Size & Ratio Across All Devices
              Center(
                child: _InstagramStoryPreview(
                  width: _stickerCanvasWidth,
                  height: _stickerCanvasHeight,
                  backgroundStyle: _selectedBackground,
                  child: RepaintBoundary(
                    key: _stickerKey,
                    child: _MatchStorySticker(
                      match: widget.match,
                      game: _game,
                      photoPath: widget.photoPath,
                      backgroundStyle: _selectedBackground,
                      showRating: _showRating,
                      showWeight: _showWeight,
                      showTimesPlayed: _showTimesPlayed,
                      showPlayers: _showPlayers,
                      width: _stickerCanvasWidth,
                      height: _stickerCanvasHeight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Compact Options Panel
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Background Color Swatches Row
                    Row(
                      children: [
                        Text(
                          'Theme',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: StoryBackgroundStyle.values
                                  .map(
                                    (background) => Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: _StoryBackgroundSwatch(
                                        background: background,
                                        isSelected:
                                            background == _selectedBackground,
                                        onTap: () => setState(
                                          () =>
                                              _selectedBackground = background,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Optional Stats Chips Row
                    if (_game != null || hasPlayers) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Stats',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (_game != null) ...[
                                    Tooltip(
                                      message:
                                          'Rating (${_game!.rating.toStringAsFixed(1)})',
                                      child: FilterChip(
                                        visualDensity: VisualDensity.compact,
                                        label: Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: getRatingColor(_game!.rating),
                                        ),
                                        selected: _showRating,
                                        onSelected: (val) =>
                                            setState(() => _showRating = val),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Tooltip(
                                      message:
                                          'Weight (${_game!.weight.toStringAsFixed(1)})',
                                      child: FilterChip(
                                        visualDensity: VisualDensity.compact,
                                        label: Icon(
                                          Icons.fitness_center,
                                          size: 16,
                                          color: getWeightColor(_game!.weight),
                                        ),
                                        selected: _showWeight,
                                        onSelected: (val) =>
                                            setState(() => _showWeight = val),
                                      ),
                                    ),
                                    if (_game!.timesPlayed > 0) ...[
                                      const SizedBox(width: 6),
                                      Tooltip(
                                        message:
                                            'Played (${_game!.timesPlayed}x)',
                                        child: FilterChip(
                                          visualDensity: VisualDensity.compact,
                                          label: const Icon(
                                            Icons.casino,
                                            size: 16,
                                            color: AppColors.metricPlayed,
                                          ),
                                          selected: _showTimesPlayed,
                                          onSelected: (val) => setState(
                                            () => _showTimesPlayed = val,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                  if (hasPlayers) ...[
                                    const SizedBox(width: 6),
                                    Tooltip(
                                      message: 'Players',
                                      child: FilterChip(
                                        visualDensity: VisualDensity.compact,
                                        label: const Icon(
                                          Icons.group,
                                          size: 16,
                                          color: AppColors.metricPlayers,
                                        ),
                                        selected: _showPlayers,
                                        onSelected: (val) =>
                                            setState(() => _showPlayers = val),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Export Button
              FilledButton.icon(
                onPressed: _isSharing ? null : _shareStory,
                icon: _isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isSharing
                      ? 'Preparing Story...'
                      : 'Export to Instagram Story',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── On-Screen Story Preview ──────────────────────────────────────────────────
// A rounded container that mimics the exported Instagram story canvas.
// This is only the in-app preview; the actual export is produced by
// _captureStickerImage(), which always renders at 1080×1920 px.
// Change borderRadius to adjust the preview card's corner rounding.
class _InstagramStoryPreview extends StatelessWidget {
  final double width;
  final double height;
  final StoryBackgroundStyle backgroundStyle;
  final Widget child;

  const _InstagramStoryPreview({
    required this.width,
    required this.height,
    required this.backgroundStyle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // preview card corner rounding
        gradient: backgroundStyle.gradient, // gradient from the selected theme
      ),
      child: Center(child: child),
    );
  }
}

class _StoryBackgroundSwatch extends StatelessWidget {
  final StoryBackgroundStyle background;
  final bool isSelected;
  final VoidCallback onTap;

  const _StoryBackgroundSwatch({
    required this.background,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: background.label,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '${background.label} story background color',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.35),
                  width: isSelected ? 2.2 : 1.2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: background.gradient,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchStorySticker extends StatelessWidget {
  final GameMatch match;
  final BoardGame? game;
  final String? photoPath;
  final StoryBackgroundStyle backgroundStyle;
  final bool showRating;
  final bool showWeight;
  final bool showTimesPlayed;
  final bool showPlayers;
  final double width;
  final double height;

  const _MatchStorySticker({
    required this.match,
    this.game,
    required this.photoPath,
    required this.backgroundStyle,
    this.showRating = false,
    this.showWeight = false,
    this.showTimesPlayed = false,
    this.showPlayers = false,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) => _buildClassicLayout();

  // ─── Sticker Card Layout ────────────────────────────────────────────────────
  // All element positions are derived proportionally from constraints.maxHeight
  // so the layout scales correctly at any preview or export resolution.
  // Tweak the multipliers on titleHeight, metaHeight, etc. to rebalance spacing.
  Widget _buildClassicLayout() {
    // Date/time format strings — see https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
    final dateText = DateFormat('dd-MM-yy').format(match.playedAt);
    final timeText = DateFormat('HH:mm').format(match.playedAt);
    final resultColor = _classicResultColor();
    // cardBorderColor is the darker gradient stop of the selected theme.
    final cardBorderColor = backgroundStyle.backgroundColor;

    return SizedBox(
      width: width,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;

          // Horizontal padding applied to every element on both sides.
          // Increase to narrow the content area and widen the background margin.
          final horizontalInset = width * 0.03;

          // ── Title zone (game name at the top) ───────────────────────────────
          // titleTop:   small gap from the top edge to the title.
          // titleHeight: vertical space reserved for the title text.
          //   clamp(min, max) prevents extreme values at unusual aspect ratios.
          // titleGap:   whitespace between the title and the photo card.
          final titleTop = maxHeight * 0.006;
          final titleHeight = (maxHeight * 0.095).clamp(50.0, 82.0);
          final titleGap = (maxHeight * 0.006).clamp(3.0, 6.0);

          // ── Bottom meta cards (date / time / duration) ──────────────────────
          // metaHeight:  total height of the three info cards.
          // metaOverlap: how far the cards slide up over the photo from its bottom.
          //   Increase metaOverlap to cover more of the photo; decrease to show more.
          final metaHeight = (maxHeight * 0.070).clamp(58.0, 76.0);
          final metaOverlap = metaHeight * 0.50;

          // ── Computed positions (do not change these directly) ───────────────
          final bottomSafe = (maxHeight * 0.022).clamp(
            10.0,
            16.0,
          ); // gap below the meta cards
          final photoTop = titleTop + titleHeight + titleGap;
          final availablePhotoHeight =
              maxHeight - photoTop - bottomSafe - (metaHeight - metaOverlap);
          final photoHeight = math.max(0.0, availablePhotoHeight);
          final metaTop = photoTop + photoHeight - metaOverlap;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 20,
                right: 20,
                top: titleTop,
                height: titleHeight,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    match.gameName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // ── Game title text style ────────────────────────────────
                      // Near-white. Replace with a themed color if the background clashes.
                      color: const ui.Color.fromARGB(255, 243, 243, 243),
                      shadows: <Shadow>[
                        Shadow(
                          // Drop shadow improves readability over bright photo backgrounds.
                          // Increase blurRadius for a softer, wider shadow.
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: const ui.Color.fromARGB(
                            255,
                            35,
                            35,
                            35,
                          ).withValues(alpha: 0.7),
                        ),
                      ],
                      // Font size shrinks slightly for compact preview heights.
                      fontSize: maxHeight < 430 ? 22.5 : 26.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing:
                          -0.55, // tighter spacing for bold display type
                      height:
                          1.04, // line height multiplier (1.0 = no extra leading)
                    ),
                  ),
                ),
              ),
              // ── Photo card: the main image area ─────────────────────────────
              // borderColor drives the colored glow shadow (match result color).
              Positioned(
                left: horizontalInset,
                right: horizontalInset,
                top: photoTop,
                height: photoHeight,
                child: _classicPhotoCard(borderColor: resultColor),
              ),
              // ── Metric pills overlay (rating / weight / plays) — top-left ────
              Positioned(
                left: horizontalInset + 14,
                top: photoTop + 14,
                child: _overlayMetrics(),
              ),
              // ── Result tag (WIN / LOSS / TIE) — top-right corner ─────────────
              Positioned(
                right: horizontalInset + 14,
                top: photoTop + 14,
                child: _classicResultTag(),
              ),
              // ── Player list — right side, below the result tag ────────────────
              // Increase the `top` offset if the list overlaps the result tag.
              Positioned(
                right: horizontalInset + 14,
                top: photoTop + 52,
                child: _playersOverlay(),
              ),
              // ── Bottom info cards row (date / time / duration) ─────────────
              // Each card is equally wide (Expanded). To add a 4th card, append
              // another SizedBox(width: 8) + Expanded(_classicInfoCard(...)).
              // Icon colors are AppColors tokens — change them in theme_utils.dart.
              Positioned(
                left: horizontalInset + 12,
                right: horizontalInset + 12,
                top: metaTop,
                height: metaHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _classicInfoCard(
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.matchDate,
                        value: dateText,
                        borderColor: cardBorderColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _classicInfoCard(
                        icon: Icons.access_time_rounded,
                        iconColor: AppColors.matchTime,
                        value: timeText,
                        borderColor: cardBorderColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _classicInfoCard(
                        icon: Icons.timer_outlined,
                        iconColor: AppColors.matchDuration,
                        value: '${match.duration} min',
                        borderColor: cardBorderColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Players Overlay ──────────────────────────────────────────────────────
  // Column of pill badges, one per player. Winner gets a gold border + trophy icon.
  // Only rendered when showPlayers == true (toggled by the Stats chip in the UI).
  Widget _playersOverlay() {
    if (!showPlayers || match.players.isEmpty) return const SizedBox.shrink();

    final winnerName = match.winner?.trim().toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: match.players.map((player) {
        final isWinner =
            winnerName != null &&
            winnerName.isNotEmpty &&
            player.trim().toLowerCase() == winnerName;

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            // Semi-transparent dark pill. Raise the alpha (0–255) for more opacity.
            color: const ui.Color.fromARGB(160, 18, 18, 18),
            borderRadius: BorderRadius.circular(9), // pill corner radius
            border: Border.all(
              // Winner gets gold border; non-winners get a subtle white border.
              color: isWinner
                  ? AppColors.winnerGold.withValues(alpha: 0.85)
                  : const ui.Color.fromARGB(70, 255, 255, 255),
              width: isWinner ? 1.3 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0, // increase to make player names larger
                  fontWeight: isWinner ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
              if (isWinner) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.emoji_events,
                  size: 12,
                  color: AppColors.winnerGold,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Metric Pills (top-left overlay) ──────────────────────────────────────
  // Builds a column of optional stat pills (rating / weight / play count).
  // To add a new metric pill, append an item to the `items` list following
  // the same _metricPill(...) pattern used below.
  Widget _overlayMetrics() {
    final List<Widget> items = [];

    if (showRating && game != null) {
      items.add(
        _metricPill(
          icon: Icons.star_rounded,
          iconColor: getRatingColor(game!.rating),
          value: game!.rating.toStringAsFixed(1),
        ),
      );
    }

    if (showWeight && game != null) {
      items.add(
        _metricPill(
          icon: Icons.fitness_center,
          iconColor: getWeightColor(game!.weight),
          value: game!.weight.toStringAsFixed(1),
        ),
      );
    }

    if (showTimesPlayed && game != null && game!.timesPlayed > 0) {
      items.add(
        _metricPill(
          icon: Icons.casino,
          iconColor: AppColors.metricPlayed,
          value: '${game!.timesPlayed}x',
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          items[i],
        ],
      ],
    );
  }

  // ─── Single Metric Pill ─────────────────────────────────────────────────────
  // A small icon + value chip for the top-left overlay.
  // Increase padding or fontSize to make pills physically larger.
  Widget _metricPill({
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ), // pill internal padding
      decoration: BoxDecoration(
        color: const ui.Color.fromARGB(
          160,
          18,
          18,
          18,
        ), // semi-transparent dark background
        borderRadius: BorderRadius.circular(9), // pill corner radius
        border: Border.all(
          color: const ui.Color.fromARGB(
            70,
            255,
            255,
            255,
          ), // subtle white border
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5, // increase to make metric values bigger
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Color _classicResultColor() {
    return match.result.color;
  }

  // ─── Photo Placeholder ──────────────────────────────────────────────────────
  // Shown when the match has no photo attached.
  // Change the gradient colors or the icon to customize the fallback appearance.
  Widget _storyPhotoPlaceholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD5CA), Color(0xFFF88379)], // soft coral gradient
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.casino,
          color: Colors.white,
          size: 78,
        ), // icon size — no photo
      ),
    );
  }

  // ─── Photo Card ────────────────────────────────────────────────────────────
  // Rounded card holding the match photo (or placeholder if no photo).
  // borderColor is the match result color — drives the colored glow shadow.
  Widget _classicPhotoCard({required Color borderColor}) {
    // Container supports both decoration (behind child) and foregroundDecoration (on top).
    // The border must be in foregroundDecoration so it renders over the image.
    // The boxShadow stays in decoration because shadows must render behind everything.
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 2, // frame stroke width — increase for a thicker border
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          10,
        ), // must match foregroundDecoration radius
        child: photoPath != null
            ? Image.file(
                File(photoPath!),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) =>
                    _storyPhotoPlaceholder(),
              )
            : _storyPhotoPlaceholder(),
      ),
    );
  }

  // ─── Result Tag (WIN / LOSS / TIE) ──────────────────────────────────────────
  // Badge shown in the top-right corner of the photo.
  // Lower `scale` to shrink it; buildMatchResultTag is defined in theme_utils.dart.
  Widget _classicResultTag() {
    return Transform.scale(
      scale: 1.092, // slightly enlarged relative to its natural size
      alignment: Alignment.topRight,
      child: buildMatchResultTag(match.result, uppercase: true),
    );
  }

  // ─── Bottom Info Card (date / time / duration) ───────────────────────────────
  // Each of the three cards at the bottom of the sticker uses this widget.
  // borderColor is the accent of the selected background theme.
  Widget _classicInfoCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 7,
      ), // internal card padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // card corner radius
        color: const ui.Color.fromARGB(250, 254, 254, 251),
        border: Border.all(
          color: borderColor, // accent color from the selected theme
          width: 2.0, // increase for a thicker card border
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor), // icon size inside each card
          const SizedBox(height: 3),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit
                    .scaleDown, // shrinks text automatically if it would overflow
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ui.Color.fromARGB(
                      255,
                      67,
                      67,
                      67,
                    ), // dark text on light card
                    fontSize: 13.5, // increase to make card values bigger
                    fontWeight: FontWeight.w900,
                    //letterSpacing: -0.2,
                    height: 0.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
