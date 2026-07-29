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

enum StoryBackgroundStyle { coral, sand, moss, lightPurple, twilight }

extension StoryBackgroundStyleUi on StoryBackgroundStyle {
  String get label => switch (this) {
    StoryBackgroundStyle.coral => 'Coral',
    StoryBackgroundStyle.sand => 'Sand',
    StoryBackgroundStyle.moss => 'Moss',
    StoryBackgroundStyle.lightPurple => 'Light Purple',
    StoryBackgroundStyle.twilight => 'Twilight',
  };

  Color get backgroundColor => switch (this) {
    StoryBackgroundStyle.coral => const Color(0xFFF48B82),
    StoryBackgroundStyle.sand => const Color(0xFFE7D5B7),
    StoryBackgroundStyle.moss => const Color(0xFF627A5B),
    StoryBackgroundStyle.lightPurple => const Color(0xFFC084FC),
    StoryBackgroundStyle.twilight => const Color(0xFF6B78A8),
  };
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
  static const double _storyExportTargetWidth = 1080;
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

  Future<String> _captureStickerImage() async {
    await WidgetsBinding.instance.endOfFrame;

    final boundary =
        _stickerKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Could not capture story sticker.');
    }

    final pixelRatio = math.max(
      1.0,
      _storyExportTargetWidth / boundary.size.width,
    );
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Could not encode story image.');
    }

    final bytes = byteData.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'match_story_sticker_${widget.match.id ?? DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = p.join(tempDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  Future<void> _shareStory() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    try {
      final imagePath = await _captureStickerImage();
      await FlutterSocialShare.shareToInstagram(
        stickerAssetUri: Uri.file(imagePath),
        topColor: _selectedBackground.backgroundColor,
        bottomColor: _selectedBackground.backgroundColor,
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

    return Scaffold(
      appBar: AppBar(title: const Text('Story Export')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
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
                                          () => _selectedBackground = background,
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
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
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
        borderRadius: BorderRadius.circular(24),
        color: backgroundStyle.backgroundColor,
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
                  color: background.backgroundColor,
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

  Widget _buildClassicLayout() {
    final dateText = DateFormat('dd-MM-yy').format(match.playedAt);
    final timeText = DateFormat('HH:mm').format(match.playedAt);
    final resultColor = _classicResultColor();
    final cardBorderColor = backgroundStyle.backgroundColor;

    return SizedBox(
      width: width,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          final horizontalInset = width * 0.03;
          final titleTop = maxHeight * 0.006;
          final titleHeight = (maxHeight * 0.095).clamp(50.0, 82.0);
          final titleGap = (maxHeight * 0.006).clamp(3.0, 6.0);
          final metaHeight = (maxHeight * 0.096).clamp(58.0, 76.0);
          final metaOverlap = metaHeight * 0.64;
          final bottomSafe = (maxHeight * 0.022).clamp(10.0, 16.0);
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
                      color: const ui.Color.fromARGB(255, 243, 243, 243),
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: const ui.Color.fromARGB(
                            255,
                            35,
                            35,
                            35,
                          ).withValues(alpha: 0.48),
                        ),
                      ],
                      fontSize: maxHeight < 430 ? 21.5 : 24.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.55,
                      height: 1.04,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: horizontalInset,
                right: horizontalInset,
                top: photoTop,
                height: photoHeight,
                child: _classicPhotoCard(borderColor: resultColor),
              ),
              Positioned(
                left: horizontalInset + 14,
                top: photoTop + 14,
                child: _overlayMetrics(),
              ),
              Positioned(
                right: horizontalInset + 14,
                top: photoTop + 14,
                child: _classicResultTag(),
              ),
              Positioned(
                right: horizontalInset + 14,
                top: photoTop + 52,
                child: _playersOverlay(),
              ),
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

  Widget _playersOverlay() {
    if (!showPlayers || match.players.isEmpty) return const SizedBox.shrink();

    final winnerName = match.winner?.trim().toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: match.players.map((player) {
        final isWinner = winnerName != null &&
            winnerName.isNotEmpty &&
            player.trim().toLowerCase() == winnerName;

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: const ui.Color.fromARGB(160, 18, 18, 18),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
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
                  fontSize: 10.0,
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

  Widget _metricPill({
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const ui.Color.fromARGB(160, 18, 18, 18),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const ui.Color.fromARGB(70, 255, 255, 255),
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
              fontSize: 10.5,
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

  Widget _storyPhotoPlaceholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD5CA), Color(0xFFF88379)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.casino, color: Colors.white, size: 78),
      ),
    );
  }

  Widget _classicPhotoCard({required Color borderColor}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A1E24), width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.8),
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

  Widget _classicResultTag() {
    return Transform.scale(
      scale: 1.092,
      alignment: Alignment.topRight,
      child: buildMatchResultTag(match.result, uppercase: true),
    );
  }

  Widget _classicInfoCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const ui.Color.fromARGB(215, 254, 253, 253),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 3),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ui.Color.fromARGB(255, 25, 25, 25),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    height: 1.0,
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
