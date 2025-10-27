import 'package:flutter/material.dart';
import 'package:dino/dino.dart';
import 'package:dino/entity.dart';
import 'package:dino/gamecontroller.dart';
import 'package:dino/movementstrategy.dart';

class Obstacle extends Entity {
  final double _damageValue;
  bool _isCollision;
  final String type;

  Obstacle({
    required double damageValue,
    required this.type,
    required Offset pos,
    required double w,
    required double h,
    bool isCollision = false,
    required MovementStrategy movemento,
  }) : _damageValue = damageValue,
       _isCollision = isCollision,
       super(position: pos, width: w, height: h, movement: movemento);

  get isCollision => _isCollision;
  set isCollision(bool value) => _isCollision = value;

  get damageValue => _damageValue;

  bool checkCollision(Dino dino, Gamecontroller gctl) {
    return ((position.dx < dino.position.dx + dino.size) &&
        (position.dx + width > dino.position.dx) &&
        (dino.position.dy < gctl.groundHeight + height));
  }

  @override
  void draw(Canvas canvas, Size size, Gamecontroller gctl) {
    Paint paint = Paint()
      ..color = Colors.green[700]!
      ..style = PaintingStyle.fill;

    // Main stem
    canvas.drawRRect(RRect.fromLTRBR(10, 0, size.width, size.height, Radius.circular(5)), paint);

    // Arms (if tall enough)
    if (size.height > 40) {
      canvas.drawRRect(RRect.fromLTRBR(5, size.height * 0.3, size.width, size.height * 0.5, Radius.circular(3)), paint);
      canvas.drawRRect(
        RRect.fromLTRBR(15, size.height * 0.4, size.width + 5, size.height * 0.6, Radius.circular(3)),
        paint,
      );
    }

    // Spikes
    Paint spikePaint = Paint()
      ..color = Colors.green[800]!
      ..style = PaintingStyle.fill;

    for (int i = 0; i < size.height ~/ 10; i++) {
      double y = i * 10.0 + 5;
      canvas.drawCircle(Offset(8, y), 1, spikePaint);
      canvas.drawCircle(Offset(size.width, y + 3), 1, spikePaint);
    }
  }
}
