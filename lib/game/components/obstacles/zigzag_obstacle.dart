import 'dart:math';
import 'package:flutter/material.dart';
import 'obstacle_base.dart';

class ZigZagObstacle extends ObstacleBase {
  ZigZagObstacle({
    required super.speed,
    required super.onPassed,
    required this.amplitude,
    required this.frequency,
  }) : super(paint: Paint()..color = const Color(0xFFFFC107));

  final double amplitude;
  final double frequency;

  double _t = 0;
  double? _startX;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    _startX ??= position.x;

    final s = sin(_t * frequency * pi);
    position.x = _startX! + (s.sign) * amplitude * (0.5 + 0.5 * s.abs());

    final halfW = size.x / 2;
    position.x = position.x.clamp(halfW, gameRef.size.x - halfW);
  }
}
