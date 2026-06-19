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
  runApp(const InfiniteRunnerApp());
}

class InfiniteRunnerApp extends StatelessWidget {
  const InfiniteRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = RunnerGame();
    return MaterialApp(
      title: 'Commit Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GameWidget<RunnerGame>(
        game: game,
        overlayBuilderMap: {
          'MainMenu': (context, g) => MainMenuScreen(game: g),
          'GameOver': (context, g) => GameOverScreen(game: g),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}
