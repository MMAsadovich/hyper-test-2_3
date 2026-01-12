import 'package:flutter/material.dart';

class GameConfig {
  static const double playerSize = 44;
  static const double obstacleSize = 34;
  static const double gravity = 6;
  static const double jumpForce = -90;

  // 🎨 Theme colors (C1)
  static const Color bg = Color(0xFF0B0F1A);        // dark navy
  static const Color player = Color(0xFF00E5FF);    // neon cyan
  static const Color obstacle = Color(0xFFFF2D95);  // neon pink
  static const Color glow = Color(0x6600E5FF);      // cyan glow
}
