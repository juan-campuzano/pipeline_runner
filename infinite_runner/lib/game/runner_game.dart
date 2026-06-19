import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'difficulty_manager.dart';
import 'obstacle.dart';
import 'obstacle_spawner.dart';
import 'parallax_background.dart';
import 'player.dart';
import 'score_display.dart';
import 'score_repository.dart';

class RunnerGame extends FlameGame
    with HasCollisionDetection, MultiTouchTapDetector {
  static const double logicalWidth = 800;
  static const double logicalHeight = 300;
  static const double groundY = 240.0;

  late PlayerCharacter player;
  late DifficultyManager difficultyManager;
  late ObstacleSpawner obstacleSpawner;
  late ScoreDisplay scoreDisplay;
  final ScoreRepository _scoreRepository = ScoreRepository();

  int currentScore = 0;
  int highScore = 0;
  bool isNewRecord = false;
  bool _resetting = false;

  RunnerGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: logicalWidth,
            height: logicalHeight,
          ),
        );

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    highScore = await _scoreRepository.loadHighScore();

    await world.add(ParallaxBackground());

    difficultyManager = DifficultyManager();
    await world.add(difficultyManager);

    player = PlayerCharacter();
    await world.add(player);

    obstacleSpawner = ObstacleSpawner(difficultyManager: difficultyManager);
    await world.add(obstacleSpawner);

    scoreDisplay = ScoreDisplay(difficultyManager: difficultyManager);
    await camera.viewport.add(scoreDisplay);

    // Ground line
    await camera.viewport.add(
      RectangleComponent(
        position: Vector2(0, groundY),
        size: Vector2(logicalWidth, 2),
        paint: Paint()..color = const Color(0xFF00FF88),
      ),
    );

    // Game starts paused — MainMenu overlay controls when to start
    pauseEngine();
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    if (!player.isAlive || _resetting) return;
    player.jump();
  }

  void triggerGameOver() async {
    if (_resetting) return;
    pauseEngine();
    currentScore = scoreDisplay.currentScore;
    if (currentScore > highScore) {
      highScore = currentScore;
      isNewRecord = true;
      await _scoreRepository.saveHighScore(highScore);
    }
    overlays.add('GameOver');
  }

  Future<void> restart() async {
    _resetting = true;
    overlays.remove('GameOver');
    resumeEngine();

    // Let Flame process one tick so removeFromParent() completes
    await Future.delayed(const Duration(milliseconds: 100));

    for (final o in world.children.whereType<Obstacle>().toList()) {
      o.removeFromParent();
    }

    await Future.delayed(const Duration(milliseconds: 50));

    difficultyManager.reset();
    scoreDisplay.reset();
    obstacleSpawner.reset();
    player.reset();
    isNewRecord = false;
    _resetting = false;
  }
}
