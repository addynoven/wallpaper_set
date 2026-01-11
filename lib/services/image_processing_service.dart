import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Defines how the wallpaper should be scaled to fit the screen.
enum WallpaperScaleMode {
  /// Fill the entire screen, cropping if necessary (no black bars).
  fill,

  /// Fit the image within the screen, may have black bars.
  fit,

  /// Stretch the image to exactly match screen dimensions (may distort).
  stretch,

  /// Center the image at original size, cropping if larger, padding if smaller.
  center,
}

class ImageProcessingService {
  /// Process an asset image to fit the screen with the given scale mode.
  static Future<File> processAssetForScreen({
    required String assetPath,
    required int screenWidth,
    required int screenHeight,
    required WallpaperScaleMode scaleMode,
  }) async {
    // Load asset bytes
    final assetBytes = await rootBundle.load(assetPath);
    final imageData = assetBytes.buffer.asUint8List();

    // Decode the image
    final originalImage = img.decodeImage(imageData);
    if (originalImage == null) {
      throw Exception('Failed to decode image: $assetPath');
    }

    // Process based on scale mode
    final processedImage = _applyScaleMode(
      originalImage,
      screenWidth,
      screenHeight,
      scaleMode,
    );

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'processed_${scaleMode.name}_${DateTime.now().millisecondsSinceEpoch}.png';
    final outputFile = File('${tempDir.path}/$fileName');
    await outputFile.writeAsBytes(img.encodePng(processedImage));

    return outputFile;
  }

  static img.Image _applyScaleMode(
    img.Image source,
    int targetWidth,
    int targetHeight,
    WallpaperScaleMode mode,
  ) {
    switch (mode) {
      case WallpaperScaleMode.fill:
        return _fillMode(source, targetWidth, targetHeight);
      case WallpaperScaleMode.fit:
        return _fitMode(source, targetWidth, targetHeight);
      case WallpaperScaleMode.stretch:
        return _stretchMode(source, targetWidth, targetHeight);
      case WallpaperScaleMode.center:
        return _centerMode(source, targetWidth, targetHeight);
    }
  }

  /// Fill: Scale to cover entire screen, crop excess.
  static img.Image _fillMode(
    img.Image source,
    int targetWidth,
    int targetHeight,
  ) {
    final sourceAspect = source.width / source.height;
    final targetAspect = targetWidth / targetHeight;

    int newWidth, newHeight;

    if (sourceAspect > targetAspect) {
      // Source is wider, scale by height and crop width
      newHeight = targetHeight;
      newWidth = (source.width * (targetHeight / source.height)).round();
    } else {
      // Source is taller, scale by width and crop height
      newWidth = targetWidth;
      newHeight = (source.height * (targetWidth / source.width)).round();
    }

    // Resize
    final resized = img.copyResize(
      source,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );

    // Crop to target size (center crop)
    final cropX = (newWidth - targetWidth) ~/ 2;
    final cropY = (newHeight - targetHeight) ~/ 2;

    return img.copyCrop(
      resized,
      x: cropX,
      y: cropY,
      width: targetWidth,
      height: targetHeight,
    );
  }

  /// Fit: Scale to fit within screen, add black bars if needed.
  static img.Image _fitMode(
    img.Image source,
    int targetWidth,
    int targetHeight,
  ) {
    final sourceAspect = source.width / source.height;
    final targetAspect = targetWidth / targetHeight;

    int newWidth, newHeight;

    if (sourceAspect > targetAspect) {
      // Source is wider, fit by width
      newWidth = targetWidth;
      newHeight = (source.height * (targetWidth / source.width)).round();
    } else {
      // Source is taller, fit by height
      newHeight = targetHeight;
      newWidth = (source.width * (targetHeight / source.height)).round();
    }

    // Resize
    final resized = img.copyResize(
      source,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );

    // Create black background and paste centered
    final result = img.Image(width: targetWidth, height: targetHeight);
    img.fill(result, color: img.ColorRgb8(0, 0, 0));

    final offsetX = (targetWidth - newWidth) ~/ 2;
    final offsetY = (targetHeight - newHeight) ~/ 2;

    img.compositeImage(result, resized, dstX: offsetX, dstY: offsetY);

    return result;
  }

  /// Stretch: Scale to exactly match screen (may distort).
  static img.Image _stretchMode(
    img.Image source,
    int targetWidth,
    int targetHeight,
  ) {
    return img.copyResize(
      source,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Center: Keep original size, crop if larger, pad with black if smaller.
  static img.Image _centerMode(
    img.Image source,
    int targetWidth,
    int targetHeight,
  ) {
    final result = img.Image(width: targetWidth, height: targetHeight);
    img.fill(result, color: img.ColorRgb8(0, 0, 0));

    // Calculate position to center the source
    final offsetX = (targetWidth - source.width) ~/ 2;
    final offsetY = (targetHeight - source.height) ~/ 2;

    // If source is larger, we need to crop it first
    if (source.width > targetWidth || source.height > targetHeight) {
      final cropX = source.width > targetWidth
          ? (source.width - targetWidth) ~/ 2
          : 0;
      final cropY = source.height > targetHeight
          ? (source.height - targetHeight) ~/ 2
          : 0;
      final cropWidth = source.width > targetWidth ? targetWidth : source.width;
      final cropHeight = source.height > targetHeight
          ? targetHeight
          : source.height;

      final cropped = img.copyCrop(
        source,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      final pasteX = (targetWidth - cropped.width) ~/ 2;
      final pasteY = (targetHeight - cropped.height) ~/ 2;

      img.compositeImage(result, cropped, dstX: pasteX, dstY: pasteY);
    } else {
      img.compositeImage(result, source, dstX: offsetX, dstY: offsetY);
    }

    return result;
  }
}
