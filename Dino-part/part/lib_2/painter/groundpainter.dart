import 'package:flutter/material.dart';


class GroundPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 92, 78, 24)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw ground pattern
    for (int i = 0; i < size.width ~/ 20; i++) {
      double x = i * 20.0;
      canvas.drawLine(Offset(x, 10), Offset(x + 10, 10), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}