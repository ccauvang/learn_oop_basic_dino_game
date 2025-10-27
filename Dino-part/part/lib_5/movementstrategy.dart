import 'package:dino/gamecontroller.dart';
import 'package:flutter/material.dart';
import 'package:dino/entity.dart';

abstract class MovementStrategy {
  move({
    required Entity e,
    required double gameSpeed,
    required Gamecontroller gctl,
  });
}

class NoopMovement implements MovementStrategy {
  @override
  void move({
    required Entity e,
    required double gameSpeed,
    required Gamecontroller gctl,
  }) {}
}

class HorizontalMovement implements MovementStrategy {
  @override
  void move({
    required Entity e,
    required double gameSpeed,
    required Gamecontroller gctl,
  }) {
    e.position = Offset(e.position.dx - gameSpeed / 60, e.position.dy);
    
  }
}

class VerticalMovement implements MovementStrategy {
  @override
  Animation<double> move({
    required Entity e,
    required double gameSpeed,
    required Gamecontroller gctl,
  }) {
    if (gctl.isPhase1) {
      return Tween<double>(
        begin: e.position.dy,
        end: e.position.dy + 30,
      ).animate(
        CurvedAnimation(parent: gctl.dinoController, curve: Curves.linear),
      );
    } else {
      return Tween<double>(
        begin: gctl.groundHeight,
        end: gctl.groundHeight + 100,
      ).animate(
        CurvedAnimation(parent: gctl.dinoController, curve: Curves.decelerate),
      );
    }
  }
}

class FlyMovement implements MovementStrategy {
  @override
  Animation<double> move({
    required Entity e,
    required double gameSpeed,
    required Gamecontroller gctl,
  }) {
    return Tween<double>(
      begin: e.position.dy,
      end: gctl.groundHeight,
    ).animate(CurvedAnimation(parent: gctl.planeController, curve: Curves.easeOut));
  }
}
