import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../services/wallpaper_service.dart';

/// A full-screen crop editor that allows users to pan and zoom
/// to select which portion of the image to use as wallpaper.
class WallpaperCropEditor extends StatefulWidget {
  final String assetPath;

  const WallpaperCropEditor({super.key, required this.assetPath});

  @override
  State<WallpaperCropEditor> createState() => _WallpaperCropEditorState();
}

class _WallpaperCropEditorState extends State<WallpaperCropEditor> {
  // Transform controller for InteractiveViewer
  final TransformationController _transformController =
      TransformationController();

  // Image dimensions
  Size? _imageSize;
  Size? _viewportSize;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _loadImageDimensions() async {
    final data = await rootBundle.load(widget.assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    setState(() {
      _imageSize = Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Adjust Wallpaper'),
        actions: [
          if (!_isProcessing)
            TextButton(
              onPressed: _showApplyOptions,
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCropEditor(),
    );
  }

  Widget _buildCropEditor() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // Interactive image with pan and zoom
            InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Image.asset(widget.assetPath, fit: BoxFit.contain),
              ),
            ),

            // Phone frame overlay (doesn't block gestures)
            IgnorePointer(child: _buildPhoneFrameOverlay(constraints)),

            // Instructions
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Text(
                  'Pinch to zoom • Drag to move',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Processing indicator
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Processing...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPhoneFrameOverlay(BoxConstraints constraints) {
    // Calculate the phone frame size based on screen aspect ratio
    final screenSize = _getPhysicalScreenSize();
    final screenAspect = screenSize.width / screenSize.height;

    // Frame should be 75% of the available height
    final frameHeight = constraints.maxHeight * 0.75;
    final frameWidth = frameHeight * screenAspect;

    final frameLeft = (constraints.maxWidth - frameWidth) / 2;
    final frameTop = (constraints.maxHeight - frameHeight) / 2;

    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: _CropOverlayPainter(
        frameRect: Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
      ),
    );
  }

  void _showApplyOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apply Cropped Wallpaper To',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text(
                  'Home Screen',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _applyCroppedWallpaper('home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.white),
                title: const Text(
                  'Lock Screen',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _applyCroppedWallpaper('lock');
                },
              ),
              ListTile(
                leading: const Icon(Icons.smartphone, color: Colors.white),
                title: const Text(
                  'Both Screens',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _applyCroppedWallpaper('both');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyCroppedWallpaper(String destination) async {
    if (_imageSize == null || _viewportSize == null) return;

    setState(() => _isProcessing = true);

    try {
      // Get the cropped image file
      final croppedFile = await _cropImage();

      // Set the wallpaper
      String? result;
      switch (destination) {
        case 'home':
          result = await WallpaperService.setWallpaperFromFile(
            imageFile: croppedFile,
            screenLocation: 1, // Home screen
          );
          break;
        case 'lock':
          result = await WallpaperService.setWallpaperFromFile(
            imageFile: croppedFile,
            screenLocation: 2, // Lock screen
          );
          break;
        case 'both':
          result = await WallpaperService.setWallpaperFromFile(
            imageFile: croppedFile,
            screenLocation: 3, // Both screens
          );
          break;
      }

      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ?? 'Wallpaper set successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<File> _cropImage() async {
    // Load the original image
    final data = await rootBundle.load(widget.assetPath);
    final bytes = data.buffer.asUint8List();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    // Get screen size for output
    final screenSize = _getPhysicalScreenSize();
    final screenWidth = screenSize.width.toInt();
    final screenHeight = screenSize.height.toInt();

    // Calculate the viewport frame dimensions
    final screenAspect = screenSize.width / screenSize.height;
    final frameHeight = _viewportSize!.height * 0.75;
    final frameWidth = frameHeight * screenAspect;
    final frameLeft = (_viewportSize!.width - frameWidth) / 2;
    final frameTop = (_viewportSize!.height - frameHeight) / 2;

    // Get the current transformation matrix
    final matrix = _transformController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();

    // Calculate how the image is displayed in the viewport (before transform)
    final imageAspect = _imageSize!.width / _imageSize!.height;
    final viewportAspect = _viewportSize!.width / _viewportSize!.height;

    double displayWidth, displayHeight;
    double imageOffsetX, imageOffsetY;

    if (imageAspect > viewportAspect) {
      // Image is wider than viewport
      displayWidth = _viewportSize!.width;
      displayHeight = _viewportSize!.width / imageAspect;
      imageOffsetX = 0;
      imageOffsetY = (_viewportSize!.height - displayHeight) / 2;
    } else {
      // Image is taller than viewport
      displayHeight = _viewportSize!.height;
      displayWidth = _viewportSize!.height * imageAspect;
      imageOffsetX = (_viewportSize!.width - displayWidth) / 2;
      imageOffsetY = 0;
    }

    // Apply the transformation to get the actual displayed position
    final scaledWidth = displayWidth * scale;
    final scaledHeight = displayHeight * scale;
    final transformedX = imageOffsetX * scale + translation.x;
    final transformedY = imageOffsetY * scale + translation.y;

    // The frame area in viewport coordinates
    final frameRect = Rect.fromLTWH(
      frameLeft,
      frameTop,
      frameWidth,
      frameHeight,
    );

    // Calculate what portion of the image is visible in the frame
    // Convert frame coordinates to image coordinates
    final imageRect = Rect.fromLTWH(
      transformedX,
      transformedY,
      scaledWidth,
      scaledHeight,
    );

    // Calculate the intersection and map to original image pixels
    final relativeLeft = (frameRect.left - imageRect.left) / imageRect.width;
    final relativeTop = (frameRect.top - imageRect.top) / imageRect.height;
    final relativeWidth = frameRect.width / imageRect.width;
    final relativeHeight = frameRect.height / imageRect.height;

    // Convert to original image coordinates
    int cropX = (relativeLeft * originalImage.width).round();
    int cropY = (relativeTop * originalImage.height).round();
    int cropWidth = (relativeWidth * originalImage.width).round();
    int cropHeight = (relativeHeight * originalImage.height).round();

    // Clamp values to image bounds
    cropX = cropX.clamp(0, originalImage.width - 1);
    cropY = cropY.clamp(0, originalImage.height - 1);
    cropWidth = cropWidth.clamp(1, originalImage.width - cropX);
    cropHeight = cropHeight.clamp(1, originalImage.height - cropY);

    // Crop the image
    final cropped = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // Resize to screen size
    final resized = img.copyResize(
      cropped,
      width: screenWidth,
      height: screenHeight,
      interpolation: img.Interpolation.linear,
    );

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.png';
    final outputFile = File('${tempDir.path}/$fileName');
    await outputFile.writeAsBytes(img.encodePng(resized));

    return outputFile;
  }

  Size _getPhysicalScreenSize() {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view != null) {
      return view.physicalSize;
    }
    return const Size(1080, 1920);
  }
}

/// Custom painter for the crop overlay with dark edges and clear center
class _CropOverlayPainter extends CustomPainter {
  final Rect frameRect;

  _CropOverlayPainter({required this.frameRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    // Draw dark overlay on all four sides of the frame
    // Top
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, frameRect.top), paint);
    // Bottom
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        frameRect.bottom,
        size.width,
        size.height - frameRect.bottom,
      ),
      paint,
    );
    // Left
    canvas.drawRect(
      Rect.fromLTWH(0, frameRect.top, frameRect.left, frameRect.height),
      paint,
    );
    // Right
    canvas.drawRect(
      Rect.fromLTWH(
        frameRect.right,
        frameRect.top,
        size.width - frameRect.right,
        frameRect.height,
      ),
      paint,
    );

    // Draw frame border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rrect = RRect.fromRectAndRadius(frameRect, const Radius.circular(20));
    canvas.drawRRect(rrect, borderPaint);

    // Draw corner handles
    _drawCornerHandles(canvas, frameRect);
  }

  void _drawCornerHandles(Canvas canvas, Rect rect) {
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const handleLength = 25.0;
    const offset = 10.0;

    // Top-left
    canvas.drawLine(
      Offset(rect.left - offset, rect.top + handleLength),
      Offset(rect.left - offset, rect.top - offset),
      handlePaint,
    );
    canvas.drawLine(
      Offset(rect.left - offset, rect.top - offset),
      Offset(rect.left + handleLength, rect.top - offset),
      handlePaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(rect.right - handleLength, rect.top - offset),
      Offset(rect.right + offset, rect.top - offset),
      handlePaint,
    );
    canvas.drawLine(
      Offset(rect.right + offset, rect.top - offset),
      Offset(rect.right + offset, rect.top + handleLength),
      handlePaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left - offset, rect.bottom - handleLength),
      Offset(rect.left - offset, rect.bottom + offset),
      handlePaint,
    );
    canvas.drawLine(
      Offset(rect.left - offset, rect.bottom + offset),
      Offset(rect.left + handleLength, rect.bottom + offset),
      handlePaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(rect.right - handleLength, rect.bottom + offset),
      Offset(rect.right + offset, rect.bottom + offset),
      handlePaint,
    );
    canvas.drawLine(
      Offset(rect.right + offset, rect.bottom + offset),
      Offset(rect.right + offset, rect.bottom - handleLength),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.frameRect != frameRect;
  }
}
