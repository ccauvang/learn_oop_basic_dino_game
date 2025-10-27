import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

class GameAssets {
  ui.Image? dinoIdle;
  bool _loading = false;
  bool reloading = true;

  GameAssets() {
    load();
    if (!reloading) {
      reload();
    }
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    dinoIdle = await loadImageSafe('assets/images/cheems.png');
    _loading = false;
    if (dinoIdle == null) {
      reloading = false;
    } else {
      reloading = true;
    }
  }

  // Gọi hàm này sau khi anh thay ảnh để nạp lại ngay
  Future<void> reload() async {
    dinoIdle?.dispose();
    dinoIdle = null;
    _loading = false;
    await load();
  }

  Future<ui.Image?> loadImageSafe(String assetPath) async {
    try {
      print('🔄 Loading image: $assetPath');

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
        '🖼️ Frame obtained, image size: ${frame.image.width}x${frame.image.height}',
      );

      print('✅ Successfully loaded: $assetPath');
      print('${frame.image}');
      return frame.image;
    } catch (e, stackTrace) {
      print('❌ Error loading image from asset: $assetPath');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
