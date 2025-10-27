import 'package:flutter/material.dart';
import 'dart:async';

import 'package:dino/painter/cloudpainter.dart';
import 'package:dino/painter/groundpainter.dart';
import 'package:dino/gamecontroller.dart';
import 'package:dino/movementstrategy.dart';
import 'package:dino/painter.dart';
import 'package:dino/dino.dart';

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
  late AnimationController _dinoController;
  late AnimationController _gameController;
  late Animation<double> _dinoAnimation;

  Timer? gameTimer;

  late Dino dino;
  late Gamecontroller gctl;

  @override
  void initState() {
    super.initState();

    dino = Dino(pos: Offset(80, 100), size: 50, movement: VerticalMovement());
    gctl = Gamecontroller(
      dino: dino,
      gameSpeed: 300,
      highScore: 0,
      groundHeight: 100,
    );

    _dinoController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _gameController = AnimationController(
      duration: Duration(milliseconds: 16),
      vsync: this,
    )..repeat();

    _dinoAnimation = dino.movement.move(
      e: dino,
      gameSpeed: gctl.gameSpeed,
      groundHeight: gctl.groundHeight,
      parentsAnimation: _dinoController,
    );

    _dinoAnimation.addListener(() {
      if (mounted) {
        setState(() {
          dino.position = Offset(dino.position.dx, _dinoAnimation.value);
        });
      }
    });

    _dinoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dinoController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        gctl.isJumping = false;
      }
    });
  }

    void startGame() {
      gctl.scoreTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (!gctl.isGameOver) {
          if (!mounted) return;
          setState(() {
            dino.score++;
            // Increase speed every 100 points
            if (dino.score % 60 == 0) {
              gctl.gameSpeed += 36;
            }
          });
        }
      });
    }

    @override
    void dispose() {
      _dinoController.dispose();
      _gameController.dispose();
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
            if (mounted) {
              setState(() {
                if (!gctl.isJumping && !gctl.isGameOver) {
                  if (!gctl.isGameStarted) {
                    startGame();
                  }
                }
                if (gctl.isJumping == false) {
                  dino.jump(gctl, _dinoController);
                  gctl.isJumping = true;
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
                        'Healt ${dino.health.toString().padLeft(5, '0')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'monospace',
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
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Tap to start and jump',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'monospace',
                                  color: Colors.grey[600],
                                ),
                              ),
                            ] else ...[
                              Text(
                                'GAME OVER',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Highest Score: ${gctl.highScore}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'monospace',
                                  color: const Color.fromARGB(
                                    255,
                                    100,
                                    255,
                                    107,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      gctl.resetGame(_dinoController);
                                      if (!gctl.isJumping && !gctl.isGameOver) {
                                        if (!gctl.isGameStarted) {
                                          startGame();
                                          gctl.startGame();
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
                                    fontFamily: 'monospace',
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
