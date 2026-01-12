import 'dart:math' as math;
import 'package:flame/components.dart';
import 'obstacle_base.dart';

class ZigZagObstacle extends ObstacleBase {
  ZigZagObstacle({
    required super.speed,
    required super.onPassed,
    required this.amplitude,
    required this.frequency,
  });

  final double amplitude; // px
  final double frequency; // hz-ish

  double _t = 0;
  double _startX = 0;
  bool _init = false;

  @override
  void update(double dt) {
    super.update(dt); // ✅ y pastga + passed check

    // startX ni bir marta olib qolamiz
    if (!_init) {
      _startX = position.x;
      _init = true;
    }

    _t += dt;

    // zigzag: sign(sin) -> chap/o‘ng keskin
    final s = math.sin(_t * frequency * math.pi * 2);
    final dir = s >= 0 ? 1.0 : -1.0;

    position.x = _startX + dir * amplitude;
  }
}
