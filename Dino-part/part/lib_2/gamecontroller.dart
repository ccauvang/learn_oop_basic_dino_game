import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dino/dino.dart';

class Gamecontroller {
  Dino dino;
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
    gameSpeed = 300.0;
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
    dino.position = Offset(80, groundHeight);
    gameSpeed = 300;

    obstacleTimer?.cancel();
    scoreTimer?.cancel();
    dinoctl.reset();
    // startGame();
  }
}
