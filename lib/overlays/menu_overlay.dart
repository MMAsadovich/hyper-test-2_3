import 'package:flutter/material.dart';
import '../game/tap_avoid_game.dart';

class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key, required this.game});
  final TapAvoidGame game;

  @override
  Widget build(BuildContext context) {
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
              const Text('Tap & Avoid', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text(
                'Chap tomonga tap = chapga\nO‘ng tomonga tap = o‘ngga\nTo‘qnashmang 🙂',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.3),
              ),
              const SizedBox(height: 12),
              Text('Best: ${game.bestScore}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: game.startGame, child: const Text('START'))),
            ],
          ),
        ),
      ),
    );
  }
}
