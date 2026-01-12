import 'package:flutter/material.dart';
import '../game/tap_avoid_game.dart';

class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key, required this.game});
  final TapAvoidGame game;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF111A33),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('GAME OVER', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Score: ${game.score}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 6),
              Text('Best: ${game.bestScore}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (loading || game.continueUsed)
                      ? null
                      : () async {
                    setState(() => loading = true);
                    await game.continueAfterAd();
                    if (mounted) setState(() => loading = false);
                  },
                  child: Text(
                    game.continueUsed ? 'CONTINUE (USED)' : (loading ? 'LOADING AD...' : 'CONTINUE (Rewarded)'),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : game.startGame,
                  child: const Text('RESTART'),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: loading
                      ? null
                      : () {
                    game.overlays.remove(TapAvoidGame.overlayGameOver);
                    game.overlays.add(TapAvoidGame.overlayMenu);
                  },
                  child: const Text('MENU'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
