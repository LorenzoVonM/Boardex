import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_social_share/flutter_social_share.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/match.dart';
import '../utils/theme_utils.dart';

enum StoryBackgroundStyle { coral, sand, moss, ochre, twilight }

extension StoryBackgroundStyleUi on StoryBackgroundStyle {
  String get label => switch (this) {
    StoryBackgroundStyle.coral => 'Coral',
    StoryBackgroundStyle.sand => 'Sand',
    StoryBackgroundStyle.moss => 'Moss',
    StoryBackgroundStyle.ochre => 'Ochre',
    StoryBackgroundStyle.twilight => 'Twilight',
  };

  Color get backgroundColor => switch (this) {
    StoryBackgroundStyle.coral => const Color(0xFFF48B82),
    StoryBackgroundStyle.sand => const Color(0xFFE7D5B7),
    StoryBackgroundStyle.moss => const Color(0xFF627A5B),
    StoryBackgroundStyle.ochre => const Color(0xFFC7923D),
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

  final GlobalKey _stickerKey = GlobalKey();
  bool _isSharing = false;
  StoryBackgroundStyle _selectedBackground = StoryBackgroundStyle.coral;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Story Export')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Instagram Story Preview',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Exports as a sticker layer. Pick the Instagram background color below.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: StoryBackgroundStyle.values
                    .map(
                      (background) => _StoryBackgroundSwatch(
                        background: background,
                        isSelected: background == _selectedBackground,
                        onTap: () =>
                            setState(() => _selectedBackground = background),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const storyAspect = 9 / 16;
                    final maxWidth = constraints.maxWidth;
                    final maxHeight = constraints.maxHeight;
                    final fittedWidth = (maxHeight * storyAspect).clamp(
                      220.0,
                      maxWidth,
                    );
                    final previewWidth = fittedWidth;
                    final previewHeight = previewWidth / storyAspect;

                    return Center(
                      child: _InstagramStoryPreview(
                        width: previewWidth,
                        height: previewHeight,
                        backgroundStyle: _selectedBackground,
                        child: RepaintBoundary(
                          key: _stickerKey,
                          child: _MatchStorySticker(
                            match: widget.match,
                            photoPath: widget.photoPath,
                            width: previewWidth,
                            height: previewHeight,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
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
  final String? photoPath;
  final double width;
  final double height;

  const _MatchStorySticker({
    required this.match,
    required this.photoPath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) => _buildClassicLayout();

  Widget _buildClassicLayout() {
    final dateText = DateFormat('dd-MM-yy').format(match.playedAt);
    final timeText = DateFormat('HH:mm').format(match.playedAt);
    final resultColor = _classicResultColor();

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
          final metaHeight = (maxHeight * 0.074).clamp(46.0, 60.0);
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
                right: horizontalInset + 14,
                top: photoTop + 14,
                child: _classicResultTag(),
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
                        value: dateText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _classicInfoCard(
                        icon: Icons.schedule_rounded,
                        value: timeText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _classicInfoCard(
                        icon: Icons.timer_outlined,
                        value: '${match.duration} min',
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photoPath != null)
              Image.file(
                File(photoPath!),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) =>
                    _storyPhotoPlaceholder(),
              )
            else
              _storyPhotoPlaceholder(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0xC2000000), Color(0x00000000)],
                  stops: [0.0, 0.45],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classicResultTag() {
    return Transform.scale(
      scale: 0.84,
      alignment: Alignment.topRight,
      child: buildMatchResultTag(match.result, uppercase: true),
    );
  }

  Widget _classicInfoCard({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const ui.Color.fromARGB(215, 254, 253, 253),
        border: Border.all(color: AppColors.headerCoral, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.headerCoral),
          const SizedBox(height: 3),
          Expanded(
            child: Center(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ui.Color.fromARGB(255, 43, 42, 42),
                  fontSize: 8.0,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
