// lib/game/tap_avoid_game.dart

import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../services/fake_rewarded_ad_service.dart';
import '../services/rewarded_ad_service.dart';
import '../storage/local_score_storage.dart';

import 'components/player.dart';
import 'components/obstacles/obstacle_base.dart';
import 'components/obstacles/straight_obstacle.dart';
import 'components/obstacles/zigzag_obstacle.dart';
import 'components/obstacles/wave_obstacle.dart';

class TapAvoidGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  static const overlayMenu = 'menu';
  static const overlayGameOver = 'game_over';

  final Random _rng = Random();

  final RewardedAdService rewarded;
  final LocalScoreStorage scoreStorage;

  TapAvoidGame({
    RewardedAdService? rewarded,
    LocalScoreStorage? scoreStorage,
  })  : rewarded = rewarded ?? FakeRewardedAdService(),
        scoreStorage = scoreStorage ?? LocalScoreStorage();

  late Player _player;
  late TextComponent _scoreText;

  int score = 0;
  int bestScore = 0;

  bool isRunning = false;
  bool continueUsed = false;

  double _spawnTimer = 0;
  double _spawnInterval = 0.80;
  double _difficultyTimer = 0;

  @override
  Color backgroundColor() => const Color(0xFF0B1020);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // load best score
    bestScore = await scoreStorage.getBest();

    // HUD
    _scoreText = TextComponent(
      text: 'Score: 0  •  Best: $bestScore',
      position: Vector2(16, 16),
      anchor: Anchor.topLeft,
      priority: 1000,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    add(_scoreText);

    // Player
    _player = Player()
      ..size = Vector2(44, 44)
      ..anchor = Anchor.center;
    add(_player);

    _placePlayerCenter();

    // Menu overlay paytida engine pause
    pauseEngine();
  }

  void _placePlayerCenter() {
    _player.position = Vector2(size.x / 2, size.y - 90);
  }

  void _updateHud() {
    _scoreText.text = 'Score: $score  •  Best: $bestScore';
  }

  void startGame() {
    // clear obstacles
    children.whereType<ObstacleBase>().toList().forEach((c) => c.removeFromParent());

    score = 0;
    continueUsed = false;

    _spawnTimer = 0;
    _difficultyTimer = 0;
    _spawnInterval = 0.80;

    isRunning = true;

    _player.resetSafe();
    _placePlayerCenter();
    _updateHud();

    overlays.remove(overlayMenu);
    overlays.remove(overlayGameOver);
    resumeEngine();
  }

  /// Collision ichidan await qilib bo‘lmagani uchun shu wrapper.
  void triggerGameOver() {
    unawaited(gameOver());
  }

  Future<void> gameOver() async {
    if (!isRunning) return;
    isRunning = false;

    // save best score
    if (score > bestScore) {
      bestScore = score;
      await scoreStorage.setBest(bestScore);
    }
    _updateHud();

    pauseEngine();
    overlays.add(overlayGameOver);
  }

  Future<void> continueAfterAd() async {
    if (isRunning) return;
    if (continueUsed) return;

    final ok = await rewarded.showRewarded();
    if (!ok) return;

    continueUsed = true;

    // revive: obstacles clear
    children.whereType<ObstacleBase>().toList().forEach((c) => c.removeFromParent());

    overlays.remove(overlayGameOver);
    isRunning = true;

    _player.revive(invulnerableSeconds: 1.5);
    resumeEngine();
  }

  void _onObstaclePassed() {
    score += 1;
    _updateHud();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isRunning) return;

    // spawn
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnObstacle();
    }

    // difficulty
    _difficultyTimer += dt;
    if (_difficultyTimer >= 5) {
      _difficultyTimer = 0;
      _spawnInterval = max(0.35, _spawnInterval - 0.05);
    }
  }

  void _spawnObstacle() {
    final type = _rng.nextInt(3); // 0 straight, 1 zigzag, 2 wave

    final w = _rng.nextDouble() * 40 + 22; // 22..62
    final speed = _rng.nextDouble() * 160 + 220; // 220..380
    final x = _rng.nextDouble() * (size.x - w) + (w / 2);

    ObstacleBase obs;
    switch (type) {
      case 1:
        obs = ZigZagObstacle(
          speed: speed,
          amplitude: _rng.nextDouble() * 60 + 30,
          frequency: _rng.nextDouble() * 2 + 1.5,
          onPassed: _onObstaclePassed,
        );
        break;
      case 2:
        obs = WaveObstacle(
          speed: speed,
          amplitude: _rng.nextDouble() * 70 + 25,
          frequency: _rng.nextDouble() * 2 + 1.2,
          onPassed: _onObstaclePassed,
        );
        break;
      default:
        obs = StraightObstacle(
          speed: speed,
          onPassed: _onObstaclePassed,
        );
    }

    obs
      ..size = Vector2(w, w)
      ..position = Vector2(x, -30)
      ..anchor = Anchor.center;

    add(obs);
  }

  /// ✅ NEW Flame Events API:
  /// TapDownInfo emas, TapDownEvent keladi.
  @override
  void onTapDown(TapDownEvent event) {
    if (!isRunning) return;

    final tapX = event.canvasPosition.x;
    final dir = tapX < size.x / 2 ? -1 : 1;

    _player.dodgeSmooth(dir, screenWidth: size.x);
  }
}
