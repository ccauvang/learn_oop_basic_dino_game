import 'package:flutter/material.dart';
import 'package:dino/entity.dart';

abstract class MovementStrategy {
  move({ required Entity e, required double gameSpeed, required double groundHeight, required AnimationController parentsAnimation});
}

class NoopMovement implements MovementStrategy {
  @override
  void move({ required Entity e, required double gameSpeed, required double groundHeight, required AnimationController parentsAnimation}) {}
}

class HorizontalMovement implements MovementStrategy {

  @override
  void move({ required Entity e, required double gameSpeed, required double groundHeight, required AnimationController parentsAnimation}) {
    e.position = Offset(e.position.dx - gameSpeed / 60, e.position.dy);
  }
}

class VerticalMovement implements MovementStrategy {

  @override
  Animation<double> move({ required Entity e, required double gameSpeed, required double groundHeight, required AnimationController parentsAnimation}) {

    return Tween<double>(
      begin: groundHeight,
      end: groundHeight + 100,
    ).animate(CurvedAnimation(
      parent: parentsAnimation,
      curve: Curves.decelerate,
    ));
    
  }
}
