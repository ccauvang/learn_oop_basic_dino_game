import 'package:flutter/material.dart';
import 'package:dino/gamecontroller.dart';
import 'package:dino/movementstrategy.dart';

abstract class Entity {
  Offset position;
  double width, height;
  MovementStrategy movement;

  Entity({
    required this.position,
    required this.width,
    required this.height,
    required this.movement,
  });

  void update(double dt) => movement;
  void draw(Canvas canvas, Size size, Gamecontroller gctl);
}
