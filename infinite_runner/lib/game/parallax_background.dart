import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import 'runner_game.dart';

class ParallaxBackground extends ParallaxComponent<RunnerGame> {
  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('bg_layer1.png'),
        ParallaxImageData('bg_layer2.png'),
        ParallaxImageData('bg_layer3.png'),
      ],
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(2, 0),
      filterQuality: FilterQuality.none,
      fill: LayerFill.height,
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final dm = game.difficultyManager;
    parallax?.baseVelocity = Vector2(dm.worldSpeed * 0.13, 0);
  }
}
