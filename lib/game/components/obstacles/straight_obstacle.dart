import 'package:flutter/material.dart';
import 'obstacle_base.dart';

class StraightObstacle extends ObstacleBase {
  StraightObstacle({required super.speed, required super.onPassed})
      : super(paint: Paint()..color = const Color(0xFFFF4D4D));
}
