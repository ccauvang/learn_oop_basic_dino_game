import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

class GameAssets {
  ui.Image? _imageRes;
  String path;

  GameAssets({required this.path}) {
    load(path: path);
  }

  get imageRes => _imageRes;

  Future<void> load({String path = ''}) async {
    if (path == '') {
      _imageRes = await loadImageSafe('assets/images/cheems.png');
    } else {
      _imageRes = await loadImageSafe(path);
    }
  }

  Future<ui.Image?> loadImageSafe(String assetPath) async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      if (!manifestContent.contains(assetPath)) {
        print('❌ Asset not found in manifest: $assetPath');
        return null;
      }

      final data = await rootBundle.load(assetPath);
      print('📦 Data loaded, size: ${data.lengthInBytes} bytes');

      if (data.lengthInBytes == 0) {
        print('❌ Empty file: $assetPath');
        return null;
      }

      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      print('🎨 Codec created');

      final frame = await codec.getNextFrame();
      print('🖼️ Image size: ${frame.image}');

      print('✅ Successfully loaded: $assetPath');
      return frame.image;
    } catch (e, stackTrace) {
      print('❌ Error loading image from asset: $assetPath');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
