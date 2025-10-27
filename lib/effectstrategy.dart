import 'package:flutter/material.dart';
import 'package:dino/dino.dart';
import 'package:dino/gamecontroller.dart';
import 'dart:async';

abstract class EffectStrategy {
  void apply(Dino dino, int value, Gamecontroller gctl);
}

class Poisons implements EffectStrategy {
  @override
  void apply(Dino dino, int value, Gamecontroller gctl) {
    dino.health = (dino.health - value).clamp(0, 100);
  }
}

class Heal implements EffectStrategy {
  @override
  void apply(Dino dino, int value, Gamecontroller gctl) {
    dino.health = (dino.health + value).clamp(0, 100);
  }
}

class Rocket implements EffectStrategy {
  @override
  void apply(Dino dino, int value, Gamecontroller gctl) {
    dino.position = Offset(dino.position.dx, dino.position.dy + 100);

    Future.delayed(Duration(seconds: 3), () {
      if (dino.position.dy != gctl.groundHeight) {
        dino.position = Offset(dino.position.dx, dino.position.dy - 100);
      }
    });
  }
}
