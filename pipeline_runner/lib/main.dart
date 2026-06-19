import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/runner_game.dart';
import 'screens/game_over.dart';
import 'screens/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const InfiniteRunnerApp());
}

class InfiniteRunnerApp extends StatelessWidget {
  const InfiniteRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = RunnerGame();
    return MaterialApp(
      title: 'Pipeline Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            GameWidget<RunnerGame>(
              game: game,
              backgroundBuilder: (context) => Container(color: Colors.black),
              overlayBuilderMap: {
                'MainMenu': (context, g) => MainMenuScreen(game: g),
                'GameOver': (context, g) => GameOverScreen(game: g),
              },
              initialActiveOverlays: const ['MainMenu'],
            ),
            _JumpButton(game: game),
          ],
        ),
      ),
    );
  }
}

/// Shows a jump button in the black letterbox area below the game canvas.
/// The game canvas is 800×450. Scale = min(W/800, H/450).
/// Black bar below = (H - 450*scale) / 2.
/// Only visible when that bar is tall enough (>60px) to fit the button.
class _JumpButton extends StatelessWidget {
  final RunnerGame game;
  const _JumpButton({required this.game});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final W = size.width;
    final H = size.height;

    // Scale the 800×450 canvas to fit the screen
    final scale = (W / RunnerGame.logicalWidth).clamp(
      0.0,
      H / RunnerGame.logicalHeight,
    );
    final canvasH = RunnerGame.logicalHeight * scale;
    final barH = (H - canvasH) / 2; // height of each black bar

    // Only show if there's enough room in the black bar
    if (barH < 60) return const SizedBox.shrink();

    // Position the button in the bottom black bar
    final buttonBottom = barH / 2 - 45; // vertically centered in the bar

    return Positioned(
      bottom: buttonBottom.clamp(8.0, double.infinity),
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            if (game.player.isAlive) game.player.jump();
          },
          child: Container(
            width: 200,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF88).withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFF00FF88), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  color: Color(0xFF00FF88),
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'SALTAR',
                  style: TextStyle(
                    color: Color(0xFF00FF88),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
