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
import 'game_theme.dart';

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

  // spawn
  double _spawnTimer = 0;
  double _spawnInterval = 0.80;

  // difficulty (by score milestones)
  double _baseSpeed = 240;        // start speed
  final double _speedStep = 22;   // +speed every 10 score
  final double _speedJitter = 18; // small random (+/-)
  int _lastSpeedMilestone = 0;    // last (score ~/ 10)

  @override
  Color backgroundColor() => GameTheme.bg;

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

    // reset score / flags
    score = 0;
    continueUsed = false;

    // reset spawn + difficulty
    _spawnTimer = 0;
    _spawnInterval = 0.80;

    _baseSpeed = 240;
    _lastSpeedMilestone = 0;

    isRunning = true;

    // player reset
    _player.resetSafe();
    _placePlayerCenter();

    // HUD
    _updateHud();

    // overlays + run
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

    // reset spawn timer (revive paytida birdan spawn bo‘lib ketmasin)
    _spawnTimer = 0;

    overlays.remove(overlayGameOver);
    isRunning = true;

    _player.revive(invulnerableSeconds: 1.5);
    resumeEngine();
  }

  void _onObstaclePassed() {
    score += 1;

    // ✅ every 10 score: speed up + a bit faster spawns
    final milestone = score ~/ 10; // 0,1,2...
    if (milestone > _lastSpeedMilestone) {
      _lastSpeedMilestone = milestone;

      _baseSpeed += _speedStep;
      _spawnInterval = max(0.45, _spawnInterval - 0.03);
    }

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
  }

  void _spawnObstacle() {
    final type = _rng.nextInt(3); // 0 straight, 1 zigzag, 2 wave

    final w = _rng.nextDouble() * 40 + 22; // 22..62

    // ✅ speed: base ± small jitter (no extreme fast/slow)
    final speed = _baseSpeed + (_rng.nextDouble() * _speedJitter * 2 - _speedJitter);

    final x = _rng.nextDouble() * (size.x - w) + (w / 2);

    ObstacleBase obs;

    switch (type) {
      case 1:
        obs = ZigZagObstacle(
          speed: speed,
          amplitude: _rng.nextDouble() * 50 + 25, // yumshoqroq
          frequency: _rng.nextDouble() * 1.2 + 1.2, // kamroq "telba"
          onPassed: _onObstaclePassed,
        );
        break;
      case 2:
        obs = WaveObstacle(
          speed: speed,
          amplitude: _rng.nextDouble() * 55 + 20,
          frequency: _rng.nextDouble() * 1.2 + 1.0,
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
