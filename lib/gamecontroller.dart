import 'dart:async';
import 'dart:math';

import 'package:dino/assetsController.dart';
import 'package:dino/functions/random.dart';

import 'package:dino/effectstrategy.dart';
import 'package:dino/movementstrategy.dart';
import 'package:dino/soundController.dart';

import 'package:flutter/material.dart';
import 'package:dino/dino.dart';
import 'package:dino/item.dart';
import 'package:dino/obstacle.dart';

class Gamecontroller {
  Dino _dino;
  List<Obstacle> _obstacles;
  List<Item> _items;
  double _highScore = 0;
  final double _evolutionScore;
  final double _evolutionEndScore;
  final double _groundHeight;
  double _gameSpeed;
  bool _isJumping;
  bool _isGameOver;
  bool _isGameStarted;
  bool _isActive;
  bool _isHitTheCactus = false;
  bool _isHitTheHeal = false;

  final AssetsController _assetBundle = AssetsController();
  final SoundController _soundBundle = SoundController();

  bool isPhase1 = false;
  bool isPhase2 = false;

  var phaseCheck = <String, dynamic>{};

  Timer? gameTimer;
  Timer? obstacleTimer;
  Timer? scoreTimer;
  Timer? flydownTimer;
  Timer? delaySound;

  AnimationController dinoController;
  AnimationController planeController;
  AnimationController gameController;

  late Animation<double> dinoAnimation;
  late Animation<double> planeAnimation;

  Gamecontroller({
    required Dino dino,
    required List<Obstacle> obstacles,
    required List<Item> items,
    required double gameSpeed,
    required double evolutionScore,
    required double evolutionEndScore,
    required double groundHeight,
    required this.dinoController,
    required this.planeController,
    required this.gameController,
    bool isJumping = false,
    bool isGameOver = true,
    bool isGameStarted = false,
    bool isActive = true,
  }) : _dino = dino,
       _evolutionScore = evolutionScore,
       _obstacles = obstacles,
       _items = items,
       _isJumping = isJumping,
       _isActive = isActive,
       _isGameOver = isGameOver,
       _gameSpeed = gameSpeed,
       _groundHeight = groundHeight,
       _isGameStarted = isGameStarted,
       _evolutionEndScore = evolutionEndScore {
    phaseCheck = <String, dynamic>{
      'phase1': <String, dynamic>{
        'scoreStart': _evolutionScore,
        'scoreEnd': _evolutionScore + _evolutionEndScore,
        'isChangePhase': false,
      },
      'phase2': <String, dynamic>{
        'scoreStart': _evolutionEndScore,
        'scoreEnd': _evolutionEndScore + _evolutionEndScore,
        'isChangePhase': false,
      },
    };

    dinoAnimation = _dino.movement.move(e: _dino, gameSpeed: _gameSpeed, gctl: this);

    planeAnimation = Tween<double>(
      begin: _dino.position.dy,
      end: _groundHeight,
    ).animate(CurvedAnimation(parent: planeController, curve: Curves.decelerate));
  }

  get highScore => _highScore;
  get isHitTheCactus => _isHitTheCactus;
  get isHitTheHeal => _isHitTheHeal;

  get obstacles => _obstacles;
  get items => _items;
  get dino => _dino;

  get isActive => _isActive;
  get isGameOver => _isGameOver;
  get isGameStarted => _isGameStarted;
  get assetBundle => _assetBundle;
  get soundBundle => _soundBundle;
  get gameSpeed => _gameSpeed;
  get groundHeight => _groundHeight;

  get isJumping => _isJumping;
  set isJumping(bool value) => _isJumping = value;

  void startGame({required Size contex}) {
    _isGameStarted = true;
    _isGameOver = false;
    _dino.score = 0;
    _dino.health = 100;
    _obstacles.clear();
    _items.clear();
    _gameSpeed = 300.0;

    _soundBundle.musicBackgroundPlay(when: 'Phase1');

    var infoItem = <String, dynamic>{'type': '', 'effect': EffectStrategy, 'value': 0};

    obstacleTimer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (!_isGameOver) {
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
              infoItem['value'] = 20;
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
              pos: Offset(contex.width, _groundHeight),
              w: 25,
              h: (2.0 * Random().nextInt(30)) < 30 ? (40.0 + Random().nextInt(30)) : (2.0 * Random().nextInt(30) + 30),
              movemento: HorizontalMovement(),
            ),
          );

          if (randomInt(0, 100) > 40) {
            addItem(
              item: Item(
                type: infoItem['type'],
                effectValue: infoItem['value'],
                effect: infoItem['effect'],
                pos: Offset(contex.width + _gameSpeed - 60, _groundHeight),
                widthh: 40,
                heightt: 40,
                movementi: HorizontalMovement(),
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
              pos: Offset(contex.width, randominRange(_groundHeight + 50, contex.height - itemH * 2)),
              widthh: 60,
              heightt: itemH,
              movementi: HorizontalMovement(),
            ),
          );
        }
      }
    });
    // var s = 0.0;
    scoreTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_isGameOver) {
        _dino.score++;

        if ((_dino.score > phaseCheck['phase1']['scoreStart']) && (_dino.score < phaseCheck['phase1']['scoreEnd'])) {
          if (!phaseCheck['phase1']['isChangePhase']) {
            isPhase1 = true;
            phaseCheck['phase1']['isChangePhase'] = true;
            _dino.position = Offset(_dino.position.dx, _groundHeight + 150);
            dinoAnimation = _dino.movement.move(e: _dino, gameSpeed: _gameSpeed, gctl: this);
            dinoController.forward();
            _soundBundle.musicBackgroundPlay(when: 'Phase2');
          }
        } else if (_dino.score > phaseCheck['phase2']['scoreStart'] && _dino.score < phaseCheck['phase2']['scoreEnd']) {
          if (!phaseCheck['phase2']['isChangePhase']) {
            isPhase1 = false;
            isPhase2 = true;
            phaseCheck['phase2']['isChangePhase'] = true;
            _dino.position = Offset(_dino.position.dx, _groundHeight);
            dinoAnimation = _dino.movement.move(e: _dino, gameSpeed: _gameSpeed, gctl: this);
          }
        }

        // Increase speed every 100 points
        if (_dino.score % 50 == 0) {
          _gameSpeed += 18;
        }

        if (isPhase1) {
          _dino.health -= 0.5;
        }
      }
    });
  }

  void updateGame(Gamecontroller gctl, AnimationController parent) {
    // Move obstacles
    _obstacles = _obstacles.where((obstacle) {
      obstacle.movement.move(e: obstacle, gameSpeed: _gameSpeed, gctl: gctl);
      return obstacle.position.dx > -obstacle.width;
    }).toList();

    _items = _items.where((item) {
      item.movement.move(e: item, gameSpeed: _gameSpeed, gctl: gctl);
      return item.position.dx > -item.width;
    }).toList();
    if (!_isGameOver) {
      if (!isPhase1) {
        for (Obstacle obstacle in _obstacles) {
          // print('end game ${obstacle.checkCollision(_dino, gctl)}');
          if (obstacle.checkCollision(_dino, gctl)) {
            if (!obstacle.isCollision) {
              obstacle.isCollision = true;
              _isHitTheCactus = true;
              Future.delayed(Duration(milliseconds: 100), () {
                _isHitTheCactus = false;
              });
              _soundBundle.hurtAndCollectPlay();
              _dino.takeDamage(obstacle.damageValue);
              if (_dino.health <= 0) {
                gameOver();
                break;
              }
            }
          }
        }

        for (Item item in _items) {
          // print('end game ${item.checkCollision(_dino, gctl)}');
          if (item.checkCollision(_dino, this)) {
            if (!item.isCollision) {
              item.isCollision = true;

              if (item.type == 'Rocket') {
                _soundBundle.hurtAndCollectPlay(when: 'Collect');
                _isJumping = true;
                Future.delayed(Duration(seconds: 3), () {
                  _isJumping = false;
                });
                // _isJumping = false;
              } else if (item.type == 'Poison') {
                _soundBundle.hurtAndCollectPlay(when: 'Poison');
                _isHitTheCactus = true;
                Future.delayed(Duration(milliseconds: 100), () {
                  _isHitTheCactus = false;
                });
              } else {
                _isHitTheHeal = true;
                Future.delayed(Duration(milliseconds: 100), () {
                  _isHitTheHeal = false;
                });
                _soundBundle.hurtAndCollectPlay(when: 'Collect');
              }

              item.applyEffect(_dino, gctl);
              _items.remove(item);

              if (_dino.health >= 100) {
                _dino.health = 100;
              } else if (_dino.health <= 0) {
                gameOver();
                break;
              }
            }
          }
        }
      } else {
        for (Item item in _items) {
          // print('end game ${obstacle.checkCollision(_dino, gctl)}');
          if (item.passTheRing(_dino)) {
            if (!item.isCollision) {
              item.isCollision = true;
              _soundBundle.hurtAndCollectPlay(when: 'Pass');
              _dino.collectItem(item, gctl);
            }
          }
        }
        if (_dino.health <= 0 || _dino.position.dy < _groundHeight + 15) {
          _soundBundle.hurtAndCollectPlay();
          gameOver();
        }
      }
    }
  }

  void addObstacle({required Obstacle obstacle}) {
    _obstacles.add(obstacle);
  }

  void addItem({required Item item}) {
    _items.add(item);
  }

  void gameOver() {
    _isGameStarted = true;
    _isGameOver = true;
    _isJumping = false;
    _isActive = false;
    _isHitTheCactus = false;
    if (_dino.score > _highScore) {
      _highScore = _dino.score;
    }

    isPhase1 = false;
    isPhase2 = false;

    phaseCheck['phase1']['isChangePhase'] = false;
    phaseCheck['phase2']['isChangePhase'] = false;

    dinoAnimation = _dino.movement.move(e: _dino, gameSpeed: _gameSpeed, gctl: this);
    dinoController.reset();

    planeAnimation = _dino.flyMovement.move(e: _dino, gameSpeed: _gameSpeed, gctl: this);
    planeController.reset();

    obstacleTimer?.cancel();
    scoreTimer?.cancel();

    delaySound = Timer(Duration(milliseconds: 500), () {
      _soundBundle.stopAll();
      _soundBundle.musicBackgroundPlay();
    });
    // dinoctl.reset();
  }

  void resetGame() {
    _isGameStarted = false;
    _isGameOver = false;
    _isActive = true;
    _dino.score = 0;
    _obstacles.clear();
    _items.clear();
    _dino.position = Offset(80, _groundHeight);
    _gameSpeed = 300;

    delaySound?.cancel();
    _soundBundle.stopAll();

    obstacleTimer?.cancel();
    scoreTimer?.cancel();
    flydownTimer?.cancel();
  }
}