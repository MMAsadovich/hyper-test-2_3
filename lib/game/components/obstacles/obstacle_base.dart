import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../player.dart';
import '../../tap_avoid_game.dart';
import '../../game_theme.dart';

abstract class ObstacleBase extends PositionComponent
    with CollisionCallbacks, HasGameRef<TapAvoidGame> {
  ObstacleBase({
    required this.speed,
    required this.onPassed,
  });

  final double speed;
  final void Function() onPassed;

  bool _counted = false;

  late final Paint _fillPaint = Paint()..color = GameTheme.obstacle;

  late final Paint _glowPaint = Paint()
    ..color = GameTheme.obstacle.withOpacity(0.18)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

  late final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..color = Colors.white.withOpacity(0.20);

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      gameRef.triggerGameOver();
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ✅ TIP: spike uchi pastga qaratilgan (tushayotgan obstacle uchun zo'r)
    // relative koordinatalar: (0..1) va parentSize = size
    add(
      PolygonHitbox.relative(
        [
          Vector2(0.5, 1.0), // bottom tip
          Vector2(1.0, 0.0), // top right
          Vector2(0.0, 0.0), // top left
        ],
        parentSize: size,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;

    // spike (tip down)
    final path = Path()
      ..moveTo(w / 2, h)   // bottom tip
      ..lineTo(w, 0)       // top right
      ..lineTo(0, 0)       // top left
      ..close();

    // glow -> fill -> outline
    canvas.drawPath(path, _glowPaint);
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _strokePaint);
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