import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../game_theme.dart';
import '../tap_avoid_game.dart';

class Player extends PositionComponent
    with CollisionCallbacks, HasGameRef<TapAvoidGame> {
  Player();

  bool _invulnerable = false;
  double _invulnTimer = 0;

  late final Paint _bodyPaint = Paint()..color = GameTheme.player;

  late final Paint _glowPaint = Paint()
    ..color = GameTheme.player.withOpacity(0.22)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

  late final Paint _rocketPaint = Paint()..color = Colors.white.withOpacity(0.9);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox()); // ✅ collision uchun
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_invulnerable) {
      _invulnTimer -= dt;
      if (_invulnTimer <= 0) _invulnerable = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final r = size.x / 2;
    final c = Offset(r, r);

    // glow
    canvas.drawCircle(c, r + 6, _glowPaint);

    // body (cyan circle)
    canvas.drawCircle(c, r, _bodyPaint);

    // simple rocket icon (triangle + small flame)
    final path = Path()
      ..moveTo(r, r - 12)     // top
      ..lineTo(r + 10, r + 10)
      ..lineTo(r, r + 6)
      ..lineTo(r - 10, r + 10)
      ..close();

    canvas.drawPath(path, _rocketPaint);

    // flame
    final flame = Path()
      ..moveTo(r, r + 14)
      ..lineTo(r + 6, r + 6)
      ..lineTo(r, r + 10)
      ..lineTo(r - 6, r + 6)
      ..close();

    final flamePaint = Paint()..color = Colors.orangeAccent.withOpacity(0.9);
    canvas.drawPath(flame, flamePaint);

    // invulnerable bo‘lsa biroz “blink”
    if (_invulnerable) {
      final overlay = Paint()..color = Colors.white.withOpacity(0.10);
      canvas.drawCircle(c, r, overlay);
    }
  }

  void resetSafe() {
    _invulnerable = false;
    _invulnTimer = 0;
  }

  void revive({double invulnerableSeconds = 1.5}) {
    _invulnerable = true;
    _invulnTimer = invulnerableSeconds;
  }

  /// ✅ Chap/o‘ng “smooth dodge”
  void dodgeSmooth(int dir, {required double screenWidth}) {
    // dir: -1 chap, 1 o‘ng
    final step = 120.0; // qadam (xohlasang 90/140 qilamiz)
    final half = size.x / 2;

    final targetX = (position.x + dir * step).clamp(half, screenWidth - half);

    // effect overlap bo‘lmasin
    children.whereType<MoveEffect>().toList().forEach((e) => e.removeFromParent());

    add(
      MoveToEffect(
        Vector2(targetX, position.y),
        CurvedEffectController(0.14, Curves.easeOut),
      ),
    );
  }
}
