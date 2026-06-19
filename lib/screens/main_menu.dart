import 'package:flutter/material.dart';

import '../game/runner_game.dart';

class MainMenuScreen extends StatelessWidget {
  final RunnerGame game;

  const MainMenuScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xCC0A0A1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💻 COMMIT RUNNER',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF88),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esquiva bugs · líneas rotas · servidores caídos',
              style: TextStyle(fontSize: 14, color: Color(0xFF88AACC)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('MainMenu');
                game.resumeEngine();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('▶  JUGAR'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap para saltar · Doble tap para doble salto',
              style: TextStyle(fontSize: 12, color: Color(0xFF556677)),
            ),
          ],
        ),
      ),
    );
  }
}
