import 'package:flutter/material.dart';

/// The classic transparency checkerboard, drawn *behind* the export boundary so
/// it is visible while editing but never ends up in the exported PNG.
class CheckerboardPainter extends CustomPainter {
  const CheckerboardPainter({this.cell = 12, this.dark = false});

  final double cell;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint a = Paint()..color = dark ? const Color(0xFF2A2F3A) : const Color(0xFFE9ECF2);
    final Paint b = Paint()..color = dark ? const Color(0xFF20242E) : const Color(0xFFD3D8E2);
    canvas.drawRect(Offset.zero & size, a);
    for (double y = 0; y < size.height; y += cell) {
      for (double x = 0; x < size.width; x += cell) {
        final bool odd = (((x / cell).floor() + (y / cell).floor()) % 2) == 1;
        if (odd) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, cell, cell).intersect(Offset.zero & size),
            b,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CheckerboardPainter old) =>
      old.cell != cell || old.dark != dark;
}
