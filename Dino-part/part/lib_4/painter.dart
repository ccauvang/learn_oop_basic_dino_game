import 'package:flutter/material.dart';
import 'package:dino/entity.dart';
import 'package:dino/gamecontroller.dart';


class Painter extends CustomPainter {

  Entity entity;
  Gamecontroller gctl;
  
  Painter({required this.entity, required this.gctl});

  @override
  void paint(Canvas canvas, Size size){
    entity.draw(canvas, size, gctl);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}