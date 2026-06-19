import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'difficulty_manager.dart';
import 'runner_game.dart';

class ScoreDisplay extends TextComponent with HasGameReference<RunnerGame> {
  final DifficultyManager difficultyManager;
  int currentScore = 0;
  double _accumulator = 0;

  ScoreDisplay({required this.difficultyManager})
      : super(
          text: 'Score: 0',
          position: Vector2(10, 10),
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.bold,
            ),
          ),
        );

  @override
  void update(double dt) {
    if (!game.player.isAlive || game.overlays.isActive('MainMenu')) return;
    _accumulator += difficultyManager.worldSpeed * dt * 0.1;
    if (_accumulator >= 1.0) {
      final add = _accumulator.floor();
      currentScore += add;
      _accumulator -= add;
      text = 'Score: $currentScore';
    }
  }

  void reset() {
    currentScore = 0;
    _accumulator = 0;
    text = 'Score: 0';
  }
}
