import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'game/tap_avoid_game.dart';
import 'overlays/menu_overlay.dart';
import 'overlays/game_over_overlay.dart';

void main() {
  final game = TapAvoidGame();
  runApp(
    GameWidget<TapAvoidGame>(
      game: game,
      overlayBuilderMap: {
        TapAvoidGame.overlayMenu: (context, game) => MenuOverlay(game: game),
        TapAvoidGame.overlayGameOver: (context, game) => GameOverOverlay(game: game),
      },
      initialActiveOverlays: const [TapAvoidGame.overlayMenu],
    ),
  );
}
