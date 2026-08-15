// lib/widgets/scrollx_dark_background.dart
//
// Reusable dark background for the onboarding / authentication experience.
// Provides:
//   • Subtle dark-black gradient (almost black — depth only, not colorful)
//   • Very faint white game-language pattern (max alpha 0.16, most ~0.06–0.10)
//   • Deterministic composition per page via [patternSeed]
//   • Fully static — no animation, no rebuilds from this widget
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Public widget ─────────────────────────────────────────────────────────────
class ScrollXDarkBackground extends StatelessWidget {
  final Widget child;
  final int patternSeed;

  const ScrollXDarkBackground({
    super.key,
    required this.child,
    this.patternSeed = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1 ── Dark gradient — almost black, purely for depth ────────────
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF050505),
                Color(0xFF141414),
                Color(0xFF1D1D1D),
                Color(0xFF0A0A0A),
              ],
              stops: [0.0, 0.35, 0.70, 1.0],
            ),
          ),
        ),

        // 2 ── Ghost game-language pattern (static, pointer-ignoring) ────
        IgnorePointer(
          child: CustomPaint(
            painter: _ScrollXPatternPainter(seed: patternSeed),
          ),
        ),

        // 3 ── Child content ─────────────────────────────────────────────
        child,
      ],
    );
  }
}

// ── Pattern painter ───────────────────────────────────────────────────────────
//
// Draws ~18–22 static game-language symbols at varied sizes, rotations, and
// opacity. The entire palette is white/translucent — no colour.
//
// Symbol vocabulary (game-inspired, abstract):
//   ×  +  =  ?  ○  □  △  ◇  •  grid fragments  rounded-rect outlines  pills
//
// Opacity range:
//   distant background  →  0.03–0.05
//   mid layer           →  0.06–0.10
//   near focal          →  0.12–0.16
//   hard maximum        →  0.16  (never 0.20 for drawn shapes)
class _ScrollXPatternPainter extends CustomPainter {
  final int seed;
  const _ScrollXPatternPainter({required this.seed});

  // Deterministic pseudo-random from seed + index
  double _r(int idx, double lo, double hi) {
    final v = math.sin((seed * 9973 + idx * 1597).toDouble()) * 43758.5453;
    final frac = v - v.floor();
    return lo + frac * (hi - lo);
  }

  Paint _p(double alpha) => Paint()
    ..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 0.16))
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  Paint _pFill(double alpha) => Paint()
    ..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 0.16))
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;

    // ── Helper: translate + rotate canvas around a point ──────────────
    void withTransform(double cx, double cy, double angle, VoidCallback fn) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      fn();
      canvas.translate(-cx, -cy);
      canvas.restore();
    }

    // ════════════════════════════════════════════════════════════════
    //  LAYER A — distant background (alpha 0.03–0.06)
    // ════════════════════════════════════════════════════════════════

    // Large faint rounded-rect outline (slide-puzzle / card fragment)
    {
      final cx = W * _r(0, 0.55, 0.80);
      final cy = H * _r(1, 0.08, 0.25);
      final w = W * 0.36;
      final h = W * 0.36;
      final angle = _r(2, -0.12, 0.12);
      withTransform(cx, cy, angle, () {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx, cy), width: w, height: h),
            const Radius.circular(18),
          ),
          _p(0.05),
        );
      });
    }

    // Large faint circle (reaction tap / memory match)
    {
      final cx = W * _r(3, 0.05, 0.30);
      final cy = H * _r(4, 0.60, 0.80);
      canvas.drawCircle(Offset(cx, cy), W * 0.22, _p(0.04));
    }

    // Tiny 3×3 grid (pattern memory / slide puzzle)
    {
      final ox = W * _r(5, 0.60, 0.80);
      final oy = H * _r(6, 0.70, 0.88);
      const cell = 12.0;
      const gap = 4.0;
      final paint = _p(0.05);
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                ox + col * (cell + gap),
                oy + row * (cell + gap),
                cell,
                cell,
              ),
              const Radius.circular(3),
            ),
            paint,
          );
        }
      }
    }

    // Faint "?" glyph — large, almost invisible
    {
      final cx = W * _r(7, 0.10, 0.25);
      final cy = H * _r(8, 0.15, 0.32);
      final tp = TextPainter(
        text: TextSpan(
          text: '?',
          style: TextStyle(
            fontSize: W * 0.28,
            color: Colors.white.withValues(alpha: 0.04),
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(cx - tp.width / 2, cy - tp.height / 2));
    }

    // ════════════════════════════════════════════════════════════════
    //  LAYER B — mid layer (alpha 0.06–0.10)
    // ════════════════════════════════════════════════════════════════

    // × symbol (math blitz / equation pairs)
    {
      final cx = W * _r(9, 0.72, 0.90);
      final cy = H * _r(10, 0.35, 0.52);
      const s = 10.0;
      final angle = _r(11, 0.1, 0.4);
      final paint = _p(0.08)..strokeWidth = 2.0;
      withTransform(cx, cy, angle, () {
        canvas.drawLine(
            Offset(cx - s, cy - s), Offset(cx + s, cy + s), paint);
        canvas.drawLine(
            Offset(cx + s, cy - s), Offset(cx - s, cy + s), paint);
      });
    }

    // + symbol (math blitz)
    {
      final cx = W * _r(12, 0.08, 0.22);
      final cy = H * _r(13, 0.42, 0.58);
      const s = 9.0;
      final angle = _r(14, -0.15, 0.15);
      final paint = _p(0.09)..strokeWidth = 2.0;
      withTransform(cx, cy, angle, () {
        canvas.drawLine(Offset(cx - s, cy), Offset(cx + s, cy), paint);
        canvas.drawLine(Offset(cx, cy - s), Offset(cx, cy + s), paint);
      });
    }

    // Small circle (reaction tap)
    {
      final cx = W * _r(15, 0.78, 0.93);
      final cy = H * _r(16, 0.60, 0.75);
      canvas.drawCircle(Offset(cx, cy), 14, _p(0.07));
    }

    // Small pill (button fragment)
    {
      final cx = W * _r(17, 0.30, 0.55);
      final cy = H * _r(18, 0.82, 0.93);
      const w = 42.0;
      const h = 18.0;
      final angle = _r(19, -0.1, 0.1);
      withTransform(cx, cy, angle, () {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx, cy), width: w, height: h),
            const Radius.circular(9),
          ),
          _p(0.07),
        );
      });
    }

    // = symbol (equation pairs)
    {
      final cx = W * _r(20, 0.55, 0.68);
      final cy = H * _r(21, 0.18, 0.30);
      const s = 8.0;
      const gap = 4.0;
      final paint = _p(0.08)..strokeWidth = 1.8;
      canvas.drawLine(
          Offset(cx - s, cy - gap / 2), Offset(cx + s, cy - gap / 2), paint);
      canvas.drawLine(
          Offset(cx - s, cy + gap / 2), Offset(cx + s, cy + gap / 2), paint);
    }

    // Small triangle (shape tap)
    {
      final cx = W * _r(22, 0.14, 0.28);
      final cy = H * _r(23, 0.65, 0.78);
      const s = 11.0;
      final angle = _r(24, -0.2, 0.3);
      final paint = _p(0.07)..strokeWidth = 1.5;
      final path = Path()
        ..moveTo(0, -s)
        ..lineTo(s * 0.87, s * 0.5)
        ..lineTo(-s * 0.87, s * 0.5)
        ..close();
      withTransform(cx, cy, angle, () => canvas.drawPath(path, paint));
    }

    // Small square (slide puzzle tile)
    {
      final cx = W * _r(25, 0.82, 0.95);
      final cy = H * _r(26, 0.12, 0.24);
      const s = 12.0;
      final angle = _r(27, -0.25, 0.25);
      withTransform(cx, cy, angle, () {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx, cy), width: s * 2, height: s * 2),
            const Radius.circular(4),
          ),
          _p(0.08),
        );
      });
    }

    // ════════════════════════════════════════════════════════════════
    //  LAYER C — near focal (alpha 0.12–0.16, used very sparingly)
    // ════════════════════════════════════════════════════════════════

    // One crisp × — focal accent, seed-displaced
    {
      final cx = W * _r(28, 0.85, 0.96);
      final cy = H * _r(29, 0.48, 0.60);
      const s = 7.0;
      final paint = _p(0.13)..strokeWidth = 1.8;
      canvas.drawLine(
          Offset(cx - s, cy - s), Offset(cx + s, cy + s), paint);
      canvas.drawLine(
          Offset(cx + s, cy - s), Offset(cx - s, cy + s), paint);
    }

    // One crisp small circle — focal accent
    {
      final cx = W * _r(30, 0.04, 0.14);
      final cy = H * _r(31, 0.28, 0.40);
      canvas.drawCircle(Offset(cx, cy), 6, _pFill(0.12));
    }

    // Seed-specific extra element
    if (seed == 0) {
      // Page 1: subtle 2×2 card grid fragment (memory match)
      final ox = W * 0.70;
      final oy = H * 0.82;
      const cell = 10.0;
      const gap = 4.0;
      final paint = _p(0.10);
      for (int r = 0; r < 2; r++) {
        for (int c = 0; c < 2; c++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                ox + c * (cell + gap),
                oy + r * (cell + gap),
                cell,
                cell,
              ),
              const Radius.circular(3),
            ),
            paint,
          );
        }
      }
    } else if (seed == 1) {
      // Page 2: subtle keyboard row fragment (typing speed)
      final oy = H * 0.26;
      final ox = W * 0.60;
      const keyW = 8.0;
      const keyH = 8.0;
      const keyGap = 4.0;
      final paint = _p(0.09);
      for (int i = 0; i < 4; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              ox + i * (keyW + keyGap),
              oy,
              keyW,
              keyH,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ScrollXPatternPainter old) => old.seed != seed;
}
