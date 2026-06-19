import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'runner_game.dart';

enum ObstacleType { bug, brokenLine, serverDown }

class Obstacle extends SpriteComponent with HasGameReference<RunnerGame> {
  final ObstacleType type;

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
    size = sprite!.srcSize;
    add(RectangleHitbox());

    final label = switch (type) {
      ObstacleType.bug => 'BUG',
      ObstacleType.brokenLine => 'BROKEN',
      ObstacleType.serverDown => 'SERVER',
    };
    add(TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFFFFCC00),
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(0, -14),
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
