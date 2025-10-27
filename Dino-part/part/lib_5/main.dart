import 'package:flutter/material.dart';
import 'dart:async';

import 'package:dino/dino.dart';

import 'package:dino/gamecontroller.dart';
import 'package:dino/item.dart';
import 'package:dino/movementstrategy.dart';
import 'package:dino/obstacle.dart';
import 'package:dino/painter.dart';
import 'package:dino/painter/cloudpainter.dart';
import 'package:dino/painter/groundpainter.dart';

void main() {
  runApp(DinoGameApp());
}

class DinoGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dino Game',
      theme: ThemeData(primarySwatch: Colors.grey, fontFamily: 'monospace'),
      home: DinoGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DinoGameScreen extends StatefulWidget {
  @override
  _DinoGameScreenState createState() => _DinoGameScreenState();
}

class _DinoGameScreenState extends State<DinoGameScreen>
    with TickerProviderStateMixin {
  // late AnimationController _dinoController;
  // late AnimationController _planeController;
  // late AnimationController _gameController;
  // late Animation<double> _dinoAnimation;
  // late Animation<double> _planeAnimation;

  List<Obstacle> obstacles = [];
  List<Item> items = [];
  Timer? gameTimer;

  late Dino dino;
  late Gamecontroller gctl;

  @override
  void initState() {
    super.initState();

    dino = Dino(
      pos: Offset(80, 100),
      size: 50,
      movement: VerticalMovement(),
      flyMovement: FlyMovement(),
    );
    gctl = Gamecontroller(
      dino: dino,
      obstacles: obstacles,
      items: items,
      gameSpeed: 200,
      highScore: 0,
      evolutionScore: 100,
      evolutionEndPhaseScore: 800,
      groundHeight: 100,
      dinoController: AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      ),
      planeController: AnimationController(
        duration: Duration(milliseconds: 2000),
        vsync: this,
      ),
      gameController: AnimationController(
        duration: Duration(milliseconds: 15),
        vsync: this,
      )..repeat(),
    );

    gctl.dinoAnimation.addListener(() {
      if (mounted) {
        setState(() {
          dino.position = Offset(dino.position.dx, gctl.dinoAnimation.value);
        });
      }
    });

    gctl.planeAnimation.addListener(() {
      if (mounted) {
        setState(() {
          dino.position = Offset(dino.position.dx, gctl.planeAnimation.value);
        });
      }
    });

    gctl.dinoController.addStatusListener((status) {
      if (!gctl.isPhase1) {
        if (status == AnimationStatus.completed) {
          gctl.dinoController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          gctl.isJumping = false;
        }
      } else {
        if (status == AnimationStatus.completed) {
          Timer(Duration(milliseconds: 50), () {
            gctl.dinoAnimation = dino.movement.move(
              e: dino,
              gameSpeed: gctl.gameSpeed,
              gctl: gctl,
            );
            gctl.dinoController.reset();

            gctl.planeAnimation = dino.flyMovement.move(
              e: dino,
              gameSpeed: gctl.gameSpeed,
              gctl: gctl,
            );
            gctl.planeController.forward();
          });
        } else if (status == AnimationStatus.dismissed) {
          gctl.isJumping = false;
        }
      }
    });

    gctl.gameController.addListener(() {
      if (gctl.isGameStarted && !gctl.isGameOver) {
        if (mounted) {
          setState(() {
            gctl.updateGame(gctl, gctl.dinoController);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    gctl.dinoController.dispose();
    gctl.gameController.dispose();
    gctl.gameTimer?.cancel();
    gctl.obstacleTimer?.cancel();
    gctl.scoreTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          if (gctl.isActive) {
            setState(() {
              // print(
              //   'Is over ${gctl.isGameOver}\nIs Start: ${gctl.isGameStarted}',
              // );
              if (gctl.isGameOver || !gctl.isGameStarted) {
                gctl.startGame(contex: MediaQuery.of(context).size);
              }
              if ((gctl.isPhase1 && !gctl.isPhase2) ||
                  (!gctl.isJumping && !gctl.isPhase1 && !gctl.isPhase2)) {
                if (gctl.isPhase1) {
                  gctl.dinoAnimation = dino.movement.move(
                    e: dino,
                    gameSpeed: gctl.gameSpeed,
                    gctl: gctl,
                  );

                  if (!gctl.planeController.isCompleted) {
                    gctl.planeAnimation = dino.flyMovement.move(
                      e: dino,
                      gameSpeed: gctl.gameSpeed,
                      gctl: gctl,
                    );
                    gctl.planeController.reset();
                  }
                  // gctl.planeController.forward(from: 0);
                  if (!gctl.dinoController.isCompleted) {
                    gctl.dinoAnimation = dino.movement.move(
                      e: dino,
                      gameSpeed: gctl.gameSpeed,
                      gctl: gctl,
                    );
                    gctl.dinoController.reset();
                  }
                }

                dino.jump(gctl, gctl.dinoController);
                gctl.isJumping = true;

                print('jump');
              }
            });
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Sky with clouds
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 183, 255, 254),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: CustomPaint(painter: CloudPainter()),
                ),
              ),

              // Ground
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: gctl.groundHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border(
                      top: BorderSide(color: Colors.grey[400]!, width: 2),
                    ),
                  ),
                  child: CustomPaint(painter: GroundPainter()),
                ),
              ),

              // Dino
              Positioned(
                bottom: dino.position.dy,
                left: dino.position.dx,
                child: SizedBox(
                  width: dino.dinoSize,
                  height: dino.position.dy - dino.dinoSize,
                  child: CustomPaint(
                    painter: Painter(entity: dino, gctl: gctl),
                  ),
                ),
              ),

              // Obstacles
              ...gctl.obstacles.map(
                (obstacle) => Positioned(
                  bottom: obstacle.position.dy,
                  left: obstacle.position.dx,
                  child: SizedBox(
                    width: obstacle.width,
                    height: obstacle.height,
                    child: CustomPaint(
                      painter: Painter(entity: obstacle, gctl: gctl),
                    ),
                  ),
                ),
              ),

              // items
              ...gctl.items.map(
                (item) => Positioned(
                  bottom: item.position.dy,
                  left: item.position.dx,
                  child: SizedBox(
                    width: item.width,
                    height: item.height,
                    child: CustomPaint(
                      painter: Painter(entity: item, gctl: gctl),
                    ),
                  ),
                ),
              ),

              // Score
              Positioned(
                top: 50,
                right: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dino.score > gctl.highScore
                          ? 'Highest Score ${dino.score.toString().padLeft(5, '0')}'
                          : 'Highest Score ${gctl.highScore.toString().padLeft(5, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                        color: const Color.fromARGB(255, 55, 218, 115),
                      ),
                    ),
                    Text(
                      dino.score.toString().padLeft(5, '0'),
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              // Hp
              Positioned(
                top: 50,
                right: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Healt ${dino.health.toInt().toString().padLeft(3, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'MyPixelFont',
                        color: const Color.fromARGB(255, 233, 148, 148),
                      ),
                    ),
                  ],
                ),
              ),

              // Game Over / Start Screen
              if (!gctl.isGameStarted || gctl.isGameOver)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withValues(alpha: .9),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!gctl.isGameStarted) ...[
                            Text(
                              'DINO GAME',
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: 'MyPixelFont',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Tap to start and jump',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'MyPixelFont',
                                color: Colors.grey[600],
                              ),
                            ),
                          ] else ...[
                            Text(
                              'GAME OVER',
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: 'MyPixelFont',
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Highest Score: ${gctl.highScore}',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'MyPixelFont',
                                color: const Color.fromARGB(255, 100, 255, 107),
                              ),
                            ),
                            SizedBox(height: 60),
                            ElevatedButton(
                              onPressed: () {
                                if (mounted) {
                                  setState(() {
                                    gctl.resetGame();
                                    if (!gctl.isJumping && !gctl.isGameOver) {
                                      if (!gctl.isGameStarted) {
                                        gctl.startGame(
                                          contex: MediaQuery.of(context).size,
                                        );
                                      }
                                    }
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                              ),
                              child: Text(
                                'RESTART',
                                style: TextStyle(
                                  fontFamily: 'MyPixelFont',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
