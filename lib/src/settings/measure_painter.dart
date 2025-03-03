import 'package:flutter/material.dart';

class MeasurePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 168, 253, 249)
      ..strokeWidth = 1.0;

    // We'll leave some space at the top for the chord.
    double staffOffset = 20.0;

    // We have 5 staff lines total.
    // We'll calculate spacing so they fit in the remaining vertical space.
    double totalStaffHeight = size.height - (staffOffset * 2);
    double spacing = totalStaffHeight / 4; // 4 gaps between 5 lines

    // The top line starts at staffOffset
    double firstLineY = staffOffset;

    // Draw 5 horizontal staff lines
    for (int i = 0; i < 5; i++) {
      double y = firstLineY + (i * spacing);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Left bar line
    canvas.drawLine(
      Offset(0, firstLineY),
      Offset(0, firstLineY + (4 * spacing)),
      paint,
    );

    // Right bar line
    canvas.drawLine(
      Offset(size.width, firstLineY),
      Offset(size.width, firstLineY + (4 * spacing)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
