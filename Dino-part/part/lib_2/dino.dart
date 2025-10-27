import 'package:flutter/material.dart';
import 'package:dino/entity.dart';
import 'package:dino/gamecontroller.dart';
import 'package:dino/loadimage.dart';
import 'package:dino/movementstrategy.dart';

import 'dart:ui' as ui;

class Dino extends Entity {
  double health;
  double score;
  double size;
  String skin;
  GameAssets dinoImg = GameAssets();
  double dinoSize = 100.0;

  Dino({
    required Offset pos,
    required MovementStrategy movement,
    required this.size,
    this.health = 100,
    this.score = 0,
    this.skin = 'default',
  }) : super(position: pos, width: size, height: size, movement: movement);

  void jump(Gamecontroller gctl, AnimationController parentsAnimation) {
    if (!gctl.isJumping && !gctl.isGameOver) {
      if (!gctl.isGameStarted) {
        gctl.startGame();
      }
      gctl.isJumping = true;
      parentsAnimation.forward();
      // HapticFeedback.lightImpact();
    }
  }


  void reset() {
    health = 100;
    score = 0;

    position = Offset(80, 100.0);
  }

  @override
  void draw(Canvas canvas, Size size, Gamecontroller gctl) {
    bool isGameOver = gctl.isGameOver;

    final ui.Image? idle = dinoImg.dinoIdle;
    if (idle == null) {
      // print('${GameAssets().dinoIdle}');
      Paint paint = Paint()
        ..color = Colors.grey[700]!
        ..style = PaintingStyle.fill;

      // Draw the image on canvas
      // Body
      canvas.drawRRect(
        RRect.fromLTRBR(15, 20, 45, 50, Radius.circular(8)),
        paint,
      );

      // Head
      canvas.drawRRect(
        RRect.fromLTRBR(10, 5, 40, 25, Radius.circular(10)),
        paint,
      );

      // Legs
      canvas.drawRRect(
        RRect.fromLTRBR(18, 50, 24, 60, Radius.circular(3)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromLTRBR(36, 50, 42, 60, Radius.circular(3)),
        paint,
      );

      // Arms
      canvas.drawRRect(
        RRect.fromLTRBR(12, 25, 18, 35, Radius.circular(2)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromLTRBR(42, 25, 48, 35, Radius.circular(2)),
        paint,
      );

      // Eye
      Paint eyePaint = Paint()
        ..color = isGameOver ? Colors.red : Colors.black
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(20, 15), 2, eyePaint);

      if (isGameOver) {
        // Draw X for dead dino
        Paint xPaint = Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        canvas.drawLine(Offset(18, 13), Offset(22, 17), xPaint);
        canvas.drawLine(Offset(22, 13), Offset(18, 17), xPaint);
      }

      return;
    } else {
      ui.Image img = idle;

      // bóng đổ
      final shadow = Paint()..color = Colors.black.withValues(alpha: 0.22);
      canvas.drawOval(
        Rect.fromLTWH(
          position.dx - dinoSize + 18,
        (position.dy * 1.5 + (position.dy * 0.5) - (dinoSize * 2) - 20),
          (110 - position.dy * 0.35),
          (90 - position.dy * 0.35),
        ),
        shadow,
      );

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
      final dst = Rect.fromLTWH(
        position.dx - dinoSize,
        (gctl.groundHeight - (dinoSize * 2) + 30),
        dinoSize,
        dinoSize,
      );
      canvas.drawImageRect(img, src, dst, p);
    }

    // Paint paint = Paint()
    //   ..color = Colors.grey[700]!
    //   ..style = PaintingStyle.fill;

    // // Draw the image on canvas
    // // Body
    // canvas.drawRRect(
    //   RRect.fromLTRBR(15, 20, 45, 50, Radius.circular(8)),
    //   paint,
    // );

    // // Head
    // canvas.drawRRect(
    //   RRect.fromLTRBR(10, 5, 40, 25, Radius.circular(10)),
    //   paint,
    // );

    // // Legs
    // canvas.drawRRect(
    //   RRect.fromLTRBR(18, 50, 24, 60, Radius.circular(3)),
    //   paint,
    // );
    // canvas.drawRRect(
    //   RRect.fromLTRBR(36, 50, 42, 60, Radius.circular(3)),
    //   paint,
    // );

    // // Arms
    // canvas.drawRRect(
    //   RRect.fromLTRBR(12, 25, 18, 35, Radius.circular(2)),
    //   paint,
    // );
    // canvas.drawRRect(
    //   RRect.fromLTRBR(42, 25, 48, 35, Radius.circular(2)),
    //   paint,
    // );

    // // Eye
    // Paint eyePaint = Paint()
    //   ..color = isGameOver ? Colors.red : Colors.black
    //   ..style = PaintingStyle.fill;

    // canvas.drawCircle(Offset(20, 15), 2, eyePaint);

    // if (isGameOver) {
    //   // Draw X for dead dino
    //   Paint xPaint = Paint()
    //     ..color = Colors.red
    //     ..strokeWidth = 2
    //     ..style = PaintingStyle.stroke;

    //   canvas.drawLine(Offset(18, 13), Offset(22, 17), xPaint);
    //   canvas.drawLine(Offset(22, 13), Offset(18, 17), xPaint);
    // }
  }
}
