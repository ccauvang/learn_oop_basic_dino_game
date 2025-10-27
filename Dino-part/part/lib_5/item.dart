import 'package:flutter/material.dart';
import 'package:dino/dino.dart';
import 'package:dino/effectstrategy.dart';
import 'package:dino/entity.dart';
import 'package:dino/gamecontroller.dart';
import 'package:dino/movementstrategy.dart';

import 'dart:ui' as ui;

class Item extends Entity {
  final String type;
  final int effectValue;
  final EffectStrategy effect;
  bool isCollision;
  double width, height;

  Item({
    required this.type,
    required this.effectValue,
    required this.effect,
    required this.width,
    required this.height,
    required Offset pos,
    required MovementStrategy movement,
    this.isCollision = false,
  }) : super(position: pos, width: width, height: height, movement: movement);

  bool passTheRing(Dino dino) {
    return ((position.dx < dino.position.dx + dino.size) &&
        (position.dx + width > dino.position.dx) &&
        (dino.position.dy < position.dy + height) &&
        (dino.position.dy + dino.height > position.dy));
  }

  bool checkCollision(Dino dino, Gamecontroller gctl) {
    return (position.dx < dino.position.dx + dino.size &&
        position.dx + width > dino.position.dx &&
        dino.position.dy < gctl.groundHeight + height);
  }

  void applyEffect(Dino d, Gamecontroller gctl) =>
      effect.apply(d, effectValue, gctl);

  void move(double dt) => movement;

  @override
  void draw(Canvas canvas, Size size, Gamecontroller gctl) {
    if (type == 'Heal') {
      // Apple body - red circle
      Paint applePaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(0, gctl.groundHeight - height * 2),
        width / 2,
        applePaint,
      );
    } else if (type == 'Poison') {
      // Apple body - red circle
      Paint applePaint = Paint()
        ..color = const Color.fromARGB(255, 11, 45, 13)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(0, gctl.groundHeight - height * 2),
        width / 2,
        applePaint,
      );
    } else if (type == 'Rocket') {
      // Apple body - red circle
      Paint applePaint = Paint()
        ..color = const Color.fromARGB(255, 197, 231, 61)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(0, gctl.groundHeight - height * 2),
        width / 2,
        applePaint,
      );
    }
    if (type == 'Heal' || type == 'Poison' || type == 'Rocket') {
      // Stem - brown rectangle
      Paint stemPaint = Paint()
        ..color = Colors.brown
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(0, gctl.groundHeight - height * 2 - 5),
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
          center: Offset(0 + 15, gctl.groundHeight - height * 2 - 10),
          width: 20,
          height: 12,
        ),
        leafPaint,
      );
    }

    if (type == 'Ring') {
      final ui.Image? idle = gctl.assetBundle.itemRing.imageRes;
      if (idle == null) {
        Paint leafPaint = Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill;

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(width / 2, (position.dy + height) / 2),
            width: width,
            height: height,
          ),
          leafPaint,
        );
      } else {
        ui.Image img = idle;
        final p = Paint()
          ..filterQuality = FilterQuality.high
          ..isAntiAlias = true
          ..blendMode = BlendMode.srcOver;

        final src = Rect.fromLTWH(
          0,
          0,
          img.width.toDouble(),
          img.height.toDouble(),
        );

        final data = Rect.fromLTWH(
          0,
          gctl.groundHeight - height * 2 - 30,
          width,
          height,
        );
        canvas.drawImageRect(img, src, data, p);
      }
    }
  }
}
