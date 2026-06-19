import 'dart:math';

import 'package:flame/components.dart';

import 'difficulty_manager.dart';
import 'obstacle.dart';
import 'runner_game.dart';

class ObstacleSpawner extends Component with HasGameReference<RunnerGame> {
  final DifficultyManager difficultyManager;
  late double _timer;
  final _rng = Random();

  ObstacleSpawner({required this.difficultyManager}) {
    _timer = difficultyManager.spawnInterval;
  }

  @override
  void update(double dt) {
    _timer -= dt;
    if (_timer <= 0) {
      _spawnObstacle();
      _timer = difficultyManager.spawnInterval;
    }
  }

  void _spawnObstacle() {
    final types = ObstacleType.values;
    final type = types[_rng.nextInt(types.length)];
    final obstacleHeight = type == ObstacleType.serverDown ? 60.0 : 40.0;
    game.world.add(Obstacle(
      type: type,
      position: Vector2(820, RunnerGame.groundY - obstacleHeight),
    ));
  }

  void reset() {
    _timer = difficultyManager.spawnInterval;
  }
}
