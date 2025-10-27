import 'package:flutter/material.dart';

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) async {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 0, 253, 253)
      ..style = PaintingStyle.fill;

    // Draw some simple clouds
    for (int i = 0; i < 3; i++) {
      double x = size.width * (0.2 + i * 0.3);
      double y = size.height * (0.2 + i * 0.1);

      // Cloud body
      // canvas.drawCircle(Offset(x, y), 20, paint);
      // canvas.drawCircle(Offset(x + 15, y), 25, paint);
      // canvas.drawCircle(Offset(x + 30, y), 20, paint);
      // canvas.drawCircle(Offset(x + 15, y - 10), 15, paint);

      canvas.drawOval(Rect.fromLTWH(x - 28, y - 12, 32, 22), paint);
      canvas.drawOval(Rect.fromLTWH(x - 10, y - 16, 36, 26), paint);
      canvas.drawOval(Rect.fromLTWH(x + 16, y - 10, 26, 20), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
