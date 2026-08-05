import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';

import '../models/board_game.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';

class MarketplaceExportScreen extends StatefulWidget {
  final List<BoardGame> games;

  const MarketplaceExportScreen({super.key, required this.games});

  @override
  State<MarketplaceExportScreen> createState() =>
      _MarketplaceExportScreenState();
}

class _MarketplaceExportScreenState extends State<MarketplaceExportScreen> {
  final GlobalKey _captureKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 32));

      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Export image preview is not ready.');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Could not encode PNG image.');
      }

      final pngBytes = byteData.buffer.asUint8List();
      await ImageGallerySaver().saveImage(pngBytes);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marketplace catalog saved to gallery!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 12;

    final containerWidth = MediaQuery.of(context).size.width - 28;
    final cardWidth = ((containerWidth - 20 - 16) / 3).floorToDouble() - 0.5;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: 'Export Catalog',
        titleColor: Color(0xFFEAB308),
        titleIcon: Icons.ios_share_rounded,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          14,
          topPadding,
          14,
          24 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          children: [
            // Repaint boundary container for export image capture (Solid Opaque Light Coral background)
            RepaintBoundary(
              key: _captureKey,
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0ED), // Solid 100% Opaque Light Coral
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF8BDB7),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.games.map((game) {
                    return SizedBox(
                      width: cardWidth,
                      child: _ExportGameCard(game: game),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Save Image Button (AppColors.headerCoral)
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveImage,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(_isSaving ? 'Saving...' : 'Save Image'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.headerCoral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportGameCard extends StatelessWidget {
  final BoardGame game;

  const _ExportGameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD4), // Solid Opaque Coral Theme Container
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF6ACA3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area with Price Tag badge (1:1 Square, NO photo gradient)
          AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                game.photoPath != null
                    ? Image.file(
                        File(game.photoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),

                // Badges (Bottom-Right): Trade icon tag + Price tag badge
                if (game.markForTrade || game.sellPrice != null)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (game.markForTrade)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tradeBlueBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.tradeBlue.withValues(alpha: 0.6),
                                width: 0.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              size: 11,
                              color: AppColors.tradeBlue,
                            ),
                          ),
                        if (game.markForTrade && game.sellPrice != null)
                          const SizedBox(width: 3),
                        if (game.sellPrice != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sellGreenBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.sellGreen.withValues(alpha: 0.6),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '\$${game.sellPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 10,
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

          // 2-line Game Title area with Coral Theme Info Background
          Padding(
            padding: const EdgeInsets.all(6),
            child: SizedBox(
              height: 30,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  game.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A1510), // Dark Coral Readable Text
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFFBE3DF),
      child: const Center(
        child: Icon(Icons.casino, color: AppColors.headerCoral, size: 28),
      ),
    );
  }
}
