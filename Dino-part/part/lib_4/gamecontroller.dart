import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dino/dino.dart';
import 'package:dino/item.dart';
import 'package:dino/obstacle.dart';

class Gamecontroller {
  Dino dino;
  List<Obstacle> obstacles;
  List<Item> items;
  double highScore;
  double gameSpeed;
  double groundHeight;
  bool isJumping;
  bool isGameOver;
  bool isGameStarted;
  bool isActive;

  Timer? gameTimer;
  Timer? obstacleTimer;
  Timer? scoreTimer;

  Gamecontroller({
    required this.dino,
    required this.obstacles,
    required this.items,
    required this.gameSpeed,
    required this.highScore,
    required this.groundHeight,
    this.isJumping = false,
    this.isActive = true,
    this.isGameOver = false,
    this.isGameStarted = false,
  });

  void startGame() {
    isGameStarted = true;
    isGameOver = false;
    dino.score = 0;
    dino.health = 100;
    obstacles.clear();
    gameSpeed = 300.0;
  }

  void updateGame(Gamecontroller gctl, AnimationController parent) {
    // Move obstacles
    obstacles = obstacles.where((obstacle) {
      obstacle.movement.move(
        e: obstacle,
        gameSpeed: gctl.gameSpeed,
        groundHeight: gctl.groundHeight,
        parentsAnimation: parent,
      ); // 60 FPS
      return obstacle.position.dx > -obstacle.width;
    }).toList();

    items = items.where((item) {
      item.movement.move(
        e: item,
        gameSpeed: gctl.gameSpeed,
        groundHeight: gctl.groundHeight,
        parentsAnimation: parent,
      ); // 60 FPS
      return item.position.dx > -item.width;
    }).toList();
  }

  void addObstacle({required Obstacle obstacle}) {
    obstacles.add(obstacle);
  }

  void addItem({required Item item}) {
    items.add(item);
  }

  void gameOver(AnimationController dinoctl) {
    isGameOver = true;
    if (dino.score > highScore) {
      highScore = dino.score;
    }
    dino.reset();

    obstacleTimer?.cancel();
    scoreTimer?.cancel();
    dinoctl.reset();
  }

  void resetGame(AnimationController dinoctl) {
    isGameStarted = false;
    isGameOver = false;
    dino.score = 0;
    obstacles.clear();
    items.clear();
    dino.position = Offset(80, groundHeight);
    gameSpeed = 300;

    obstacleTimer?.cancel();
    scoreTimer?.cancel();
    dinoctl.reset();
    // startGame();
  }
}
