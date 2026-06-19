import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, LinearGradient;

import 'runner_game.dart';

/// Procedural scrolling background — 3 independent layers:
///   slow   — night sky + star/code dots
///   medium — server/building silhouettes with lit windows
///   fast   — ground strip + scrolling grid lines
class ParallaxBackground extends Component with HasGameReference<RunnerGame> {
  static const double gW = RunnerGame.logicalWidth;
  static const double gH = RunnerGame.logicalHeight;
  static const double gY = RunnerGame.groundY;

  double _off1 = 0;
  double _off2 = 0;
  double _off3 = 0;

  late final List<(double, double)> _stars;
  late final List<(double, double, double)> _buildings;
  late final List<(double, double, double)> _racks;

  @override
  Future<void> onLoad() async {
    final rng = Random(42);

    _stars = [
      for (var i = 0; i < 70; i++)
        (rng.nextDouble() * gW, rng.nextDouble() * gY * 0.85),
    ];

    _buildings = [];
    double x = 0;
    while (x < gW * 2.2) {
      final w = rng.nextDouble() * 50 + 25.0;
      final h = rng.nextDouble() * 110 + 40.0;
      _buildings.add((x, w, h));
      x += w + rng.nextDouble() * 12 + 4;
    }

    _racks = [];
    x = 0;
    while (x < gW * 2.2) {
      final w = rng.nextDouble() * 28 + 18.0;
      final h = rng.nextDouble() * 55 + 20.0;
      _racks.add((x, w, h));
      x += w + rng.nextDouble() * 20 + 8;
    }
  }

  @override
  void update(double dt) {
    final speed = game.difficultyManager.worldSpeed;
    _off1 = (_off1 + speed * 0.04 * dt) % gW;
    _off2 = (_off2 + speed * 0.13 * dt) % gW;
    _off3 = (_off3 + speed * 0.30 * dt) % gW;
  }

  @override
  void render(Canvas canvas) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF050d1a), Color(0xFF0d2040)],
      ).createShader(Rect.fromLTWH(0, 0, gW, gY));
    canvas.drawRect(Rect.fromLTWH(0, 0, gW, gY), skyPaint);

    // Stars
    final starPaint = Paint()..color = const Color(0xDDffffff);
    final dotPaint = Paint()..color = const Color(0x8800FF88);
    for (final (sx, sy) in _stars) {
      final dx = (sx - _off1 + gW) % gW;
      canvas.drawCircle(Offset(dx, sy), 1.0, starPaint);
      if (dx < 3) canvas.drawCircle(Offset(dx + gW, sy), 1.0, starPaint);
    }
    for (var i = 0; i < _stars.length ~/ 2; i++) {
      final (sx, sy) = _stars[i];
      final dx = ((sx * 1.4) - _off1 * 0.6 + gW * 2) % gW;
      canvas.drawCircle(Offset(dx, sy * 0.55 + 8), 0.8, dotPaint);
    }

    // Buildings (medium layer)
    final bldFill = Paint()..color = const Color(0xFF0e2038);
    final bldStroke = Paint()
      ..color = const Color(0xFF1a5080)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final (bx, bw, bh) in _buildings) {
      for (var pass = 0; pass < 2; pass++) {
        final dx = (bx - _off2 + pass * gW + gW) % (gW + 80) - bw;
        if (dx > gW || dx + bw < 0) continue;
        final rect = Rect.fromLTWH(dx, gY - bh, bw, bh);
        canvas.drawRect(rect, bldFill);
        _drawWindows(canvas, dx, gY - bh, bw, bh);
        canvas.drawRect(rect, bldStroke);
      }
    }

    // Server racks (fast layer)
    final rackFill = Paint()..color = const Color(0xFF091520);
    final rackStroke = Paint()
      ..color = const Color(0xFF004433)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final slotPaint = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.22)
      ..strokeWidth = 0.8;

    for (final (bx, bw, bh) in _racks) {
      for (var pass = 0; pass < 2; pass++) {
        final dx = (bx - _off3 + pass * gW + gW) % (gW + 60) - bw;
        if (dx > gW || dx + bw < 0) continue;
        final rect = Rect.fromLTWH(dx, gY - bh, bw, bh);
        canvas.drawRect(rect, rackFill);
        canvas.drawRect(rect, rackStroke);
        var sy = gY - bh + 6;
        while (sy < gY - 4) {
          canvas.drawLine(Offset(dx + 2, sy), Offset(dx + bw - 2, sy), slotPaint);
          sy += 7;
        }
      }
    }

    // Ground strip
    canvas.drawRect(
      Rect.fromLTWH(0, gY, gW, gH - gY),
      Paint()..color = const Color(0xFF06101a),
    );

    // Scrolling grid on ground
    final gridPaint = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.10)
      ..strokeWidth = 1.0;
    const gridSpacing = 40.0;
    var gx = -(_off3 % gridSpacing);
    while (gx < gW) {
      canvas.drawLine(Offset(gx, gY), Offset(gx, gH), gridPaint);
      gx += gridSpacing;
    }
  }

  void _drawWindows(Canvas canvas, double bx, double by, double bw, double bh) {
    final litPaint = Paint()..color = const Color(0x77FFE066);
    final offPaint = Paint()..color = const Color(0x22FFFFFF);
    const ww = 4.0;
    const wh = 3.0;
    const pad = 5.0;
    var wy = by + pad;
    while (wy + wh < by + bh - 2) {
      var wx = bx + pad;
      while (wx + ww < bx + bw - 2) {
        final p = (wx * 7 + wy * 13).toInt() % 3 == 0 ? offPaint : litPaint;
        canvas.drawRect(Rect.fromLTWH(wx, wy, ww, wh), p);
        wx += ww + 4;
      }
      wy += wh + 5;
    }
  }
}
