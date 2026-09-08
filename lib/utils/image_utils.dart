import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  /// Generates a JPEG thumbnail (max 300px wide, quality 85) for [originalPath].
  /// Returns the thumbnail path, or [originalPath] on failure.
  static Future<String?> generateThumbnail(
    String? originalPath, {
    int maxWidth = 300,
  }) async {
    if (originalPath == null || originalPath.trim().isEmpty) return null;

    final originalFile = File(originalPath);
    if (!await originalFile.exists()) return null;

    try {
      final String thumbPath = originalPath.replaceAll(
        RegExp(r'\.[^.]+$'),
        '_thumb.jpg',
      );
      final thumbFile = File(thumbPath);

      if (await thumbFile.exists() && (await thumbFile.length()) > 0) {
        return thumbPath;
      }

      final result = await FlutterImageCompress.compressAndGetFile(
        originalPath,
        thumbPath,
        minWidth: maxWidth,
        minHeight: 0,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      return result != null ? thumbPath : originalPath;
    } catch (_) {
      return originalPath;
    }
  }

  /// Deletes photo and thumbnail files from disk. Safe to call with null paths.
  static Future<void> deletePhotoFiles(
    String? photoPath,
    String? thumbnailPath,
  ) async {
    for (final path in [photoPath, thumbnailPath]) {
      if (path == null) continue;
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }
}
