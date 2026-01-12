import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../tap_avoid_game.dart';
import 'obstacles/obstacle_base.dart';

class Player extends RectangleComponent with CollisionCallbacks, HasGameRef<TapAvoidGame> {
  Player() : super(paint: Paint()..color = const Color(0xFF38E07B));

  final double _moveDistance = 72;

  bool invulnerable = false;

  // Effektlarni reference qilib saqlaymiz (tag kerak emas)
  MoveEffect? _moveEffect;
  OpacityEffect? _blinkEffect;

  // Revive token: eski delayed callbacklarni "bekor" qilish uchun
  int _reviveToken = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  void resetSafe() {
    invulnerable = false;
    opacity = 1.0;

    // Old effectlarni o‘chirib yuboramiz
    _moveEffect?.removeFromParent();
    _moveEffect = null;

    _blinkEffect?.removeFromParent();
    _blinkEffect = null;

    // Old delayed callbacklar endi ishlamasin
    _reviveToken++;
  }

  void revive({required double invulnerableSeconds}) {
    invulnerable = true;

    // token yangilaymiz (old delayed callbacklar bekor bo‘ladi)
    _reviveToken++;
    final int token = _reviveToken;

    // old blink effect remove
    _blinkEffect?.removeFromParent();
    _blinkEffect = null;

    // blink effect (visual)
    final blink = OpacityEffect.to(
      0.2,
      EffectController(
        duration: 0.2,
        alternate: true,
        // repeatCount int bo‘lishi kerak
        repeatCount: (invulnerableSeconds / 0.2).floor().clamp(1, 999999),
      ),
    );
    _blinkEffect = blink;
    add(blink);

    // Timer o‘rniga Future.delayed + token
    Future.delayed(Duration(milliseconds: (invulnerableSeconds * 1000).round()), () {
      // Agar yangi revive bo‘lib ketgan bo‘lsa, eski callback ishlamasin
      if (_reviveToken != token) return;
      if (isRemoving || !isMounted) return;

      invulnerable = false;
      opacity = 1.0;

      _blinkEffect?.removeFromParent();
      _blinkEffect = null;
    });
  }

  void dodgeSmooth(int direction, {required double screenWidth}) {
    final halfW = size.x / 2;
    final targetX = (position.x + (_moveDistance * direction)).clamp(halfW, screenWidth - halfW);

    // old move effect remove
    _moveEffect?.removeFromParent();
    _moveEffect = null;

    final move = MoveEffect.to(
      Vector2(targetX.toDouble(), position.y),
      EffectController(duration: 0.12, curve: Curves.easeOut),
    );

    _moveEffect = move;
    add(move);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is ObstacleBase) {
      if (invulnerable) return;

      // async muammo bo‘lmasin deb wrapper
      gameRef.triggerGameOver();
    }
  }

  @override
  void onRemove() {
    // component ketayotgan bo‘lsa delayed callbacklar bekor bo‘lsin
    _reviveToken++;
    super.onRemove();
  }
}
