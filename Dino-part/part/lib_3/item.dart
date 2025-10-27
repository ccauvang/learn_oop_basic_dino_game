import 'package:flutter/material.dart';
import 'package:dino/dino.dart';
import 'package:dino/entity.dart';
import 'package:dino/gamecontroller.dart';
import 'package:dino/movementstrategy.dart';

class Item extends Entity {
  final String type;
  final int effectValue;
  bool isCollision;

  Item({
    required this.type,
    required this.effectValue,
    required Offset pos,
    required MovementStrategy movement,
    this.isCollision = false,
  }) : super(position: pos, width: 40, height: 40, movement: movement);

  bool checkCollision(Dino dino, Gamecontroller gctl) {
    return (position.dx < dino.position.dx + dino.size &&
        position.dx + width > dino.position.dx &&
        dino.position.dy < gctl.groundHeight + height);
  }

  void move(double dt) => movement;

  @override
  void draw(Canvas canvas, Size size, Gamecontroller gctl) {
    if (type == 'Healt') {
      // Apple body - red circle
      Paint applePaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(0, gctl.groundHeight - height),
        width / 2,
        applePaint,
      );
    } else if (type == 'Poison') {
      // Apple body - red circle
      Paint applePaint = Paint()
        ..color = const Color.fromARGB(255, 11, 45, 13)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(0, gctl.groundHeight - height),
        width / 2,
        applePaint,
      );
    } else if (type == 'Rocket') {
      // Apple body - red circle
      Paint applePaint = Paint()
        ..color = const Color.fromARGB(255, 197, 231, 61)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(0, gctl.groundHeight - height),
        width / 2,
        applePaint,
      );
    }

    // Stem - brown rectangle
    Paint stemPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, gctl.groundHeight - width / 2 + 10 - height),
        width: 4,
        height: 12,
      ),
      stemPaint,
    );

    // Leaf - green oval
    Paint leafPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0 + 15, gctl.groundHeight - width / 2 + 5 - height),
        width: 20,
        height: 12,
      ),
      leafPaint,
    );
  }
}
