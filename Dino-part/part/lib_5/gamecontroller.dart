import 'dart:async';
import 'dart:math';

import 'package:dino/assetController.dart';
import 'package:dino/functions/random.dart';

import 'package:dino/effectstrategy.dart';
import 'package:dino/movementstrategy.dart';

import 'package:flutter/material.dart';
import 'package:dino/dino.dart';
import 'package:dino/item.dart';
import 'package:dino/obstacle.dart';

class Gamecontroller {
  Dino dino;
  List<Obstacle> obstacles;
  List<Item> items;
  double highScore;
  double evolutionScore;
  late double evolutionEndScore;
  double gameSpeed;
  double groundHeight;
  bool isJumping;
  bool isGameOver;
  bool isGameStarted;
  bool isActive;

  Assetcontroller assetBundle = Assetcontroller();

  bool isPhase1 = false;
  bool isPhase2 = false;

  List<List<double>> scorePhase = [
    [1, 0, 0],
    [2, 0, 0],
    [0, 0],
  ];

  Timer? gameTimer;
  Timer? obstacleTimer;
  Timer? scoreTimer;
  Timer? flydownTimer;

  AnimationController dinoController;
  AnimationController planeController;
  AnimationController gameController;

  late Animation<double> dinoAnimation;
  late Animation<double> planeAnimation;

  Gamecontroller({
    required this.dino,
    required this.obstacles,
    required this.items,
    required this.gameSpeed,
    required this.highScore,
    required this.evolutionScore,
    required double evolutionEndPhaseScore,
    required this.groundHeight,
    required this.dinoController,
    required this.planeController,
    required this.gameController,
    this.isJumping = false,
    this.isGameOver = true,
    this.isGameStarted = false,
    this.isActive = true,
  }) {
    evolutionEndScore = evolutionScore + evolutionEndPhaseScore;
    scorePhase[0][1] = evolutionScore;
    scorePhase[0][2] = evolutionEndScore;

    scorePhase[1][1] = scorePhase[0][2];
    scorePhase[1][2] = scorePhase[0][2] + evolutionEndScore;

    scorePhase[2][0] = 0;
    scorePhase[2][1] = 0;
    dinoAnimation = dino.movement.move(
      e: dino,
      gameSpeed: gameSpeed,
      gctl: this,
    );
    planeAnimation = Tween<double>(begin: dino.position.dy, end: groundHeight)
        .animate(
          CurvedAnimation(parent: planeController, curve: Curves.decelerate),
        );
  }

  void startGame({required Size contex}) {
    isGameStarted = true;
    isGameOver = false;
    dino.score = 0;
    dino.health = 100;
    obstacles.clear();
    items.clear();
    gameSpeed = 300.0;

    var infoItem = <String, dynamic>{
      'type': '',
      'effect': EffectStrategy,
      'value': 0,
    };

    obstacleTimer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (!isGameOver) {
        if (!isPhase1) {
          int randomI = randomInt(1, 3);
          switch (randomI) {
            case 1:
              infoItem['type'] = 'Poison';
              infoItem['effect'] = Poisons();
              infoItem['value'] = 20;
              break;
            case 2:
              infoItem['type'] = 'Heal';
              infoItem['effect'] = Heal();
              infoItem['value'] = 36;
              break;
            case 3:
              infoItem['type'] = 'Rocket';
              infoItem['effect'] = Rocket();
              infoItem['value'] = 0;
              break;
          }

          addObstacle(
            obstacle: Obstacle(
              damageValue: 36,
              type: 'Cactus',
              pos: Offset(contex.width, groundHeight),
              w: 25,
              h: (2.0 * Random().nextInt(30)) < 30
                  ? (40.0 + Random().nextInt(30))
                  : (2.0 * Random().nextInt(30) + 30),
              movement: HorizontalMovement(),
            ),
          );

          if (randomInt(0, 100) > 60) {
            addItem(
              item: Item(
                type: infoItem['type'],
                effectValue: infoItem['value'],
                effect: infoItem['effect'],
                pos: Offset(contex.width + gameSpeed - 60, groundHeight),
                width: 40,
                height: 40,
                movement: HorizontalMovement(),
              ),
            );
          }
        } else {
          double itemH = 120;
          addItem(
            item: Item(
              type: 'Ring',
              effectValue: 10,
              effect: Heal(),
              pos: Offset(
                contex.width,
                randominRange(groundHeight + 50, contex.height - itemH*2),
              ),
              width: 60,
              height: itemH,
              movement: HorizontalMovement(),
            ),
          );
        }
      }
    });

    scoreTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!isGameOver) {
        dino.score++;
        var s = dino.score;
        if (s > scorePhase[0][1] && s < scorePhase[0][2]) {
          if (scorePhase[2][0] == 0) {
            isPhase1 = true;
            scorePhase[2][0] = 1;
            dino.position = Offset(dino.position.dx, groundHeight + 150);
            dinoAnimation = dino.movement.move(
              e: dino,
              gameSpeed: gameSpeed,
              gctl: this,
            );
          }
        } else if (s > scorePhase[1][1] && s < scorePhase[1][2]) {
          if (scorePhase[2][1] == 0) {
            isPhase1 = false;
            isPhase2 = true;
            scorePhase[2][1] = 1;
            dino.position = Offset(dino.position.dx, groundHeight);
            dinoAnimation = dino.movement.move(
              e: dino,
              gameSpeed: gameSpeed,
              gctl: this,
            );
          }
        }

        // Increase speed every 100 points
        if (dino.score % 50 == 0) {
          gameSpeed += 18;
        }

        if (isPhase1) {
          dino.health -= 0.5;
        }
      }
    });
  }

  void updateGame(Gamecontroller gctl, AnimationController parent) {
    // Move obstacles
    obstacles = obstacles.where((obstacle) {
      obstacle.movement.move(
        e: obstacle,
        gameSpeed: gameSpeed,
        gctl: gctl,
      );
      return obstacle.position.dx > -obstacle.width;
    }).toList();

    items = items.where((item) {
      item.movement.move(
        e: item,
        gameSpeed: gameSpeed,
        gctl: gctl,
      );
      return item.position.dx > -item.width;
    }).toList();

    if (!isPhase1) {
      for (Obstacle obstacle in obstacles) {
        // print('end game ${obstacle.checkCollision(dino, gctl)}');
        if (obstacle.checkCollision(dino, gctl)) {
          if (!obstacle.isCollision) {
            obstacle.isCollision = true;
            dino.takeDamage(obstacle.damageValue);
          }
          if (dino.health <= 0) {
            gameOver();
            break;
          }
        }
      }

      for (Item item in items) {
        // print('end game ${item.checkCollision(dino, gctl)}');
        if (item.checkCollision(dino, this)) {
          if (!item.isCollision) {
            item.isCollision = true;
            item.applyEffect(dino, gctl);

            if (item.type == 'Rocket') {
              isJumping = true;
              Future.delayed(Duration(seconds: 3), () {
                isJumping = false;
              });
              // isJumping = false;
            }
            items.remove(item);
          }
          if (dino.health >= 100) {
            dino.health = 100;
          } else if (dino.health <= 0) {
            gameOver();
            break;
          }
        }
      }
    } else {
      for (Item item in items) {
        // print('end game ${obstacle.checkCollision(dino, gctl)}');
        if (item.passTheRing(dino)) {
          if (!item.isCollision) {
            item.isCollision = true;
            dino.collectItem(item, gctl);
          }
        }
      }
      if (dino.health <= 0 || dino.position.dy < groundHeight + 15) {
        gameOver();
      }
    }
  }

  void addObstacle({required Obstacle obstacle}) {
    obstacles.add(obstacle);
  }

  void addItem({required Item item}) {
    items.add(item);
  }

  void gameOver() {
    isGameStarted = true;
    isGameOver = true;
    isJumping = false;
    isActive = false;
    if (dino.score > highScore) {
      highScore = dino.score;
    }

    isPhase1 = false;
    isPhase2 = false;
    scorePhase[2][0] = 0;
    scorePhase[2][1] = 0;

    dinoAnimation = dino.movement.move(
      e: dino,
      gameSpeed: gameSpeed,
      gctl: this,
    );
    dinoController.reset();

    planeAnimation = dino.flyMovement.move(
      e: dino,
      gameSpeed: gameSpeed,
      gctl: this,
    );
    planeController.reset();

    obstacleTimer?.cancel();
    scoreTimer?.cancel();
    // dinoctl.reset();
  }

  void resetGame() {
    isGameStarted = false;
    isGameOver = false;
    isActive = true;
    dino.score = 0;
    obstacles.clear();
    items.clear();
    dino.position = Offset(80, groundHeight);
    gameSpeed = 300;

    obstacleTimer?.cancel();
    scoreTimer?.cancel();
    flydownTimer?.cancel();
  }
}
