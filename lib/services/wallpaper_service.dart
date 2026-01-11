import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import 'image_processing_service.dart';

class WallpaperService {
  static final WallpaperManagerPlus _wallpaperManager = WallpaperManagerPlus();

  static Future<File> convertAssetToTempFile(String assetPath) async {
    final assetBytes = await rootBundle.load(assetPath);
    final imageData = assetBytes.buffer.asUint8List();

    final tempDirectory = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final tempFile = File('${tempDirectory.path}/$fileName');

    await tempFile.writeAsBytes(imageData);
    return tempFile;
  }

  /// Set wallpaper from asset with optional scaling.
  /// If [screenWidth] and [screenHeight] are provided along with [scaleMode],
  /// the image will be processed to fit the screen.
  static Future<String?> setWallpaperFromAsset({
    required String assetPath,
    required int screenLocation,
    int? screenWidth,
    int? screenHeight,
    WallpaperScaleMode? scaleMode,
  }) async {
    try {
      File imageFile;

      // If scale parameters are provided, process the image
      if (screenWidth != null && screenHeight != null && scaleMode != null) {
        imageFile = await ImageProcessingService.processAssetForScreen(
          assetPath: assetPath,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          scaleMode: scaleMode,
        );
      } else {
        imageFile = await convertAssetToTempFile(assetPath);
      }

      return await _wallpaperManager.setWallpaper(imageFile, screenLocation);
    } catch (error) {
      return 'Failed to set wallpaper: $error';
    }
  }

  static Future<String?> setHomeScreenWallpaper(
    String assetPath, {
    int? screenWidth,
    int? screenHeight,
    WallpaperScaleMode? scaleMode,
  }) {
    return setWallpaperFromAsset(
      assetPath: assetPath,
      screenLocation: WallpaperManagerPlus.homeScreen,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      scaleMode: scaleMode,
    );
  }

  static Future<String?> setLockScreenWallpaper(
    String assetPath, {
    int? screenWidth,
    int? screenHeight,
    WallpaperScaleMode? scaleMode,
  }) {
    return setWallpaperFromAsset(
      assetPath: assetPath,
      screenLocation: WallpaperManagerPlus.lockScreen,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      scaleMode: scaleMode,
    );
  }

  static Future<String?> setBothScreensWallpaper(
    String assetPath, {
    int? screenWidth,
    int? screenHeight,
    WallpaperScaleMode? scaleMode,
  }) {
    return setWallpaperFromAsset(
      assetPath: assetPath,
      screenLocation: WallpaperManagerPlus.bothScreens,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      scaleMode: scaleMode,
    );
  }

  static Future<String?> setWallpaperFromFile({
    required File imageFile,
    required int screenLocation,
  }) async {
    try {
      return await _wallpaperManager.setWallpaper(imageFile, screenLocation);
    } catch (error) {
      return 'Failed to set wallpaper: $error';
    }
  }

  static Future<String?> setWallpaperFromNetwork({
    required String imageUrl,
    required int screenLocation,
  }) async {
    try {
      final cachedFile = await DefaultCacheManager().getSingleFile(imageUrl);
      return await _wallpaperManager.setWallpaper(cachedFile, screenLocation);
    } catch (error) {
      return 'Failed to download and set wallpaper: $error';
    }
  }

  static Future<String?> setHomeScreenFromNetwork(String imageUrl) {
    return setWallpaperFromNetwork(
      imageUrl: imageUrl,
      screenLocation: WallpaperManagerPlus.homeScreen,
    );
  }

  static Future<String?> setLockScreenFromNetwork(String imageUrl) {
    return setWallpaperFromNetwork(
      imageUrl: imageUrl,
      screenLocation: WallpaperManagerPlus.lockScreen,
    );
  }

  static Future<String?> setBothScreensFromNetwork(String imageUrl) {
    return setWallpaperFromNetwork(
      imageUrl: imageUrl,
      screenLocation: WallpaperManagerPlus.bothScreens,
    );
  }

  static Future<String?> setLiveWallpaper(String videoPath) async {
    try {
      return await _wallpaperManager.setLiveWallpaper(videoPath);
    } catch (error) {
      return 'Failed to set live wallpaper: $error';
    }
  }
}
