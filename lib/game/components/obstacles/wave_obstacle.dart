import 'dart:math';
import 'package:flutter/material.dart';
import 'obstacle_base.dart';

class WaveObstacle extends ObstacleBase {
  WaveObstacle({
    required super.speed,
    required super.onPassed,
    required this.amplitude,
    required this.frequency,
  }) : super(paint: Paint()..color = const Color(0xFF40C4FF));

  final double amplitude;
  final double frequency;

  double _t = 0;
  double? _startX;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    _startX ??= position.x;

    position.x = _startX! + sin(_t * frequency * 2 * pi) * amplitude;

    final halfW = size.x / 2;
    position.x = position.x.clamp(halfW, gameRef.size.x - halfW);
  }
}
