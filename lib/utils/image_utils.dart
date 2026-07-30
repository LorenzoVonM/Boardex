import 'dart:io';
import 'dart:ui' as ui;

class ImageUtils {
  /// Generates a scaled thumbnail image for the specified [originalPath].
  ///
  /// Returns the file path of the thumbnail, or `null` if [originalPath] is null/empty
  /// or if thumbnail generation fails.
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
        '_thumb.png',
      );
      final thumbFile = File(thumbPath);

      // If thumbnail already exists and is not empty, return its path.
      if (await thumbFile.exists() && (await thumbFile.length()) > 0) {
        return thumbPath;
      }

      final bytes = await originalFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxWidth,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      await thumbFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      return thumbPath;
    } catch (_) {
      // Fallback to original image path if thumbnail creation fails
      return originalPath;
    }
  }
}
