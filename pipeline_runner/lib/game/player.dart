import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'obstacle.dart';
import 'runner_game.dart';

class PlayerCharacter extends SpriteAnimationComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  static const double groundY = RunnerGame.groundY;
  static const double gravity = 600.0;
  static const double jumpVelocity = -350.0;

  int jumpCount = 0;
  bool isAlive = true;
  double _vy = 0;

  late SpriteAnimation _runAnimation;
  late SpriteAnimation _jumpAnimation;

  PlayerCharacter()
      : super(
          size: Vector2(48, 48),
          position: Vector2(80, groundY - 48),
        );

  @override
  Future<void> onLoad() async {
    final runFrame1 = await game.loadSprite('player_run.png');
    final runFrame2 = await game.loadSprite('player_jump.png');

    _runAnimation = SpriteAnimation.spriteList(
      [runFrame1, runFrame2],
      stepTime: 0.15,
    );
    _jumpAnimation = SpriteAnimation.spriteList(
      [runFrame2],
      stepTime: 1.0,
      loop: false,
    );

    animation = _runAnimation;
    flipHorizontallyAroundCenter();
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
      animation = _runAnimation;
    }

    super.update(dt);
  }

  void jump() {
    if (jumpCount >= 2) return;
    jumpCount++;
    _vy = jumpVelocity;
    animation = _jumpAnimation;
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
    animation = _runAnimation;
  }
}
