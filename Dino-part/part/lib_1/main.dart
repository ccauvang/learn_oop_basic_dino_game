import 'package:dino/painter/cloudpainter.dart';
import 'package:dino/painter/groundpainter.dart';
import 'package:flutter/material.dart';


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
    bool isGameStarted = false;
    bool isGameOver = false;


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          isGameStarted = true;
          setState(() {});
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
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
                height: 100,
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

              // Game Over / Start Screen
              if (!isGameStarted || isGameOver) ...[
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withValues(alpha: .9),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isGameStarted) ...[
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
                              'Highest Score: 000',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'monospace',
                                color: const Color.fromARGB(255, 100, 255, 107),
                              ),
                            ),
                            SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {},
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
                        ]
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
