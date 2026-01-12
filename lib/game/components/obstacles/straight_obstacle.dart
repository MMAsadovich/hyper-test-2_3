import 'package:flame/components.dart';
import 'obstacle_base.dart';

class StraightObstacle extends ObstacleBase {
  StraightObstacle({
    required super.speed,
    required super.onPassed,
  });

  // Straight: base update yetadi (faqat pastga tushadi)
  @override
  void update(double dt) {
    super.update(dt);
  }
}
