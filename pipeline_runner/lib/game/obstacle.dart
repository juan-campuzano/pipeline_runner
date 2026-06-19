import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'runner_game.dart';

enum ObstacleType { bug, brokenLine, serverDown }

class Obstacle extends SpriteComponent with HasGameReference<RunnerGame> {
  final ObstacleType type;

  static const _sizes = {
    ObstacleType.bug: (w: 36.0, h: 36.0),
    ObstacleType.brokenLine: (w: 32.0, h: 32.0),
    ObstacleType.serverDown: (w: 32.0, h: 48.0),
  };

  static const _labels = {
    ObstacleType.bug: 'BUG',
    ObstacleType.brokenLine: 'ERR',
    ObstacleType.serverDown: 'DOWN',
  };

  Obstacle({required this.type, required Vector2 position})
      : super(position: position);

  @override
  Future<void> onLoad() async {
    final assetName = switch (type) {
      ObstacleType.bug => 'obstacle_bug.png',
      ObstacleType.brokenLine => 'obstacle_broken.png',
      ObstacleType.serverDown => 'obstacle_server.png',
    };
    sprite = await game.loadSprite(assetName);
    final s = _sizes[type]!;
    size = Vector2(s.w, s.h);
    position.y = RunnerGame.groundY - s.h;

    add(RectangleHitbox(
      size: Vector2(s.w - 4, s.h - 4),
      position: Vector2(2, 2),
    ));

    add(TextComponent(
      text: _labels[type]!,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 9,
          color: Color(0xFFFFCC00),
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(0, -12),
    ));
  }

  @override
  void update(double dt) {
    position.x -= game.difficultyManager.worldSpeed * dt;
    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }
}
