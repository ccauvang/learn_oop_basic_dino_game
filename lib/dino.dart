import 'package:flutter/material.dart';
import 'package:dino/entity.dart';
import 'package:dino/gamecontroller.dart';
import 'package:dino/item.dart';
import 'package:dino/movementstrategy.dart';

import 'dart:ui' as ui;

class Dino extends Entity {
  double _health;
  double _score;
  double size;
  double dinoSize = 100.0;

  MovementStrategy flyMovement;

  Dino({
    required Offset pos,
    required MovementStrategy movementd,
    required this.flyMovement,
    required this.size,
    double health = 100,
    double score = 0,
  }) : _health = health,
       _score = score,
       super(position: pos, width: size, height: size, movement: movementd);

  double get health => _health;
  set health(double value) => _health = value;

  double get score => _score;
  set score(double value) => _score = value;

  void jump(Gamecontroller gctl, AnimationController parentsAnimation) {
    if (!gctl.isJumping && !gctl.isGameOver) {
      if ((gctl.isPhase1 && !gctl.isPhase2) || (!gctl.isJumping && !gctl.isPhase1 && !gctl.isPhase2)) {
        if (gctl.isPhase1) {
          gctl.dinoAnimation = movement.move(e: this, gameSpeed: gctl.gameSpeed, gctl: gctl);

          if (!gctl.planeController.isCompleted) {
            gctl.planeAnimation = flyMovement.move(e: this, gameSpeed: gctl.gameSpeed, gctl: gctl);
            gctl.planeController.reset();
          }
          // gctl.planeController.forward(from: 0);
          if (!gctl.dinoController.isCompleted) {
            gctl.dinoAnimation = movement.move(e: this, gameSpeed: gctl.gameSpeed, gctl: gctl);
            gctl.dinoController.reset();
          }
        } else {
          gctl.soundBundle.jumpPlay();
        }

        parentsAnimation.forward();
      }
      // HapticFeedback.lightImpact();
    }
  }

  void takeDamage(double value) {
    health = (health - value).clamp(0, 100);
  }

  void collectItem(Item item, Gamecontroller gctl) {
    item.applyEffect(this, gctl);
  }

  void reset() {
    _health = 100;
    score = 0;

    position = Offset(80, 100.0);
  }

  @override
  void draw(Canvas canvas, Size size, Gamecontroller gctl) {
    bool isGameOver = gctl.isGameOver;
    ui.Image? idle;

    if (gctl.isPhase1) {
      idle = gctl.assetBundle.dinoPlane.imageRes;
    } else if (gctl.isPhase2) {
      idle = gctl.assetBundle.dinoDoge.imageRes;
    } else {
      idle = gctl.assetBundle.dinoDoge.imageRes;
    }

    if (idle == null) {
      // print('${GameAssets().imageRes}');
      Paint paint = Paint()
        ..color = Colors.grey[700]!
        ..style = PaintingStyle.fill;

      // Draw the image on canvas
      // Body
      canvas.drawRRect(RRect.fromLTRBR(15, 20, 45, 50, Radius.circular(8)), paint);

      // Head
      canvas.drawRRect(RRect.fromLTRBR(10, 5, 40, 25, Radius.circular(10)), paint);

      // Legs
      canvas.drawRRect(RRect.fromLTRBR(18, 50, 24, 60, Radius.circular(3)), paint);
      canvas.drawRRect(RRect.fromLTRBR(36, 50, 42, 60, Radius.circular(3)), paint);

      // Arms
      canvas.drawRRect(RRect.fromLTRBR(12, 25, 18, 35, Radius.circular(2)), paint);
      canvas.drawRRect(RRect.fromLTRBR(42, 25, 48, 35, Radius.circular(2)), paint);

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
      if (!gctl.isPhase1 || gctl.isPhase2) {
        // shadown
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
      }

      final p = Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true
        ..blendMode = BlendMode.srcOver;

      final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());

      final data = Rect.fromLTWH(position.dx - dinoSize, (gctl.groundHeight - (dinoSize * 2) + 30), dinoSize, dinoSize);
      canvas.drawImageRect(img, src, data, p);
    }
  }
}
