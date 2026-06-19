import 'package:flutter/material.dart';

import '../game/runner_game.dart';

class GameOverScreen extends StatelessWidget {
  final RunnerGame game;

  const GameOverScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xDD0A0A1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💥 MERGE CONFLICT',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF4444),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: ${game.currentScore}',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 8),
            if (game.isNewRecord)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '🏆 ¡NUEVO RÉCORD!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFCC00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              'High Score: ${game.highScore}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF88AACC)),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => game.restart(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('🔄  REINTENTAR'),
            ),
          ],
        ),
      ),
    );
  }
}
