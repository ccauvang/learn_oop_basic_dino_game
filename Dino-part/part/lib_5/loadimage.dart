import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

class GameAssets {
  ui.Image? imageRes;
  String path;

  GameAssets({required this.path}) {
    load(path: path);
  }

  Future<void> load({String path = ''}) async {
    if (path == '') {
      imageRes = await loadImageSafe('assets/images/cheems.png');
    } else {
      imageRes = await loadImageSafe(path);
    }
  }

  // Gọi hàm này sau khi anh thay ảnh để nạp lại ngay
  Future<void> reload() async {
    imageRes?.dispose();
    imageRes = null;
    await load();
  }

  Future<ui.Image?> loadImageSafe(String assetPath) async {
    try {
      // Check if asset exists
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
      print(
        '🖼️ Image size: ${frame.image}',
      );

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
