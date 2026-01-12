import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../tap_avoid_game.dart';

abstract class ObstacleBase extends RectangleComponent with CollisionCallbacks, HasGameRef<TapAvoidGame> {
  ObstacleBase({required this.speed, required this.onPassed, required super.paint});

  final double speed;
  final void Function() onPassed;

  bool _counted = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    if (!_counted && position.y - (size.y / 2) > gameRef.size.y) {
      _counted = true;
      onPassed();
      removeFromParent();
    }
  }
}
