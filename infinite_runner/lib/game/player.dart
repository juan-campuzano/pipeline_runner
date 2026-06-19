import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'obstacle.dart';
import 'runner_game.dart';

class PlayerCharacter extends SpriteComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  static const double groundY = RunnerGame.groundY;
  static const double gravity = 600.0;
  static const double jumpVelocity = -350.0;

  int jumpCount = 0;
  bool isAlive = true;
  double _vy = 0;

  late Sprite _runSprite;
  late Sprite _jumpSprite;

  PlayerCharacter()
      : super(
          size: Vector2(48, 48),
          position: Vector2(80, groundY - 48),
        );

  @override
  Future<void> onLoad() async {
    _runSprite = await game.loadSprite('player_run.png');
    _jumpSprite = await game.loadSprite('player_jump.png');
    sprite = _runSprite;
    add(RectangleHitbox(size: Vector2(38, 44), position: Vector2(5, 4)));
  }

  @override
  void update(double dt) {
    if (!isAlive) return;

    _vy += gravity * dt;
    position.y += _vy * dt;

    if (position.y >= groundY - size.y) {
      position.y = groundY - size.y;
      _vy = 0;
      jumpCount = 0;
      sprite = _runSprite;
    }
  }

  void jump() {
    if (jumpCount >= 2) return;
    jumpCount++;
    _vy = jumpVelocity;
    sprite = _jumpSprite;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstacle && isAlive) {
      isAlive = false;
      game.triggerGameOver();
    }
  }

  void reset() {
    isAlive = true;
    jumpCount = 0;
    _vy = 0;
    position = Vector2(80, groundY - size.y);
    sprite = _runSprite;
  }
}
