import 'package:flutter/material.dart';
import 'measure_painter.dart';

class MeasureWidget extends StatefulWidget {
  final TextEditingController chordController1;
  final TextEditingController chordController2;
  final double width;
  final double height;
  final bool showDelete;
  final bool showDurationToggle;
  final VoidCallback onDelete;

  const MeasureWidget({
    super.key,
    required this.chordController1,
    required this.chordController2,
    required this.width,
    required this.height,
    required this.showDelete,
    required this.showDurationToggle,
    required this.onDelete,
  });

  @override
  _MeasureWidgetState createState() => _MeasureWidgetState();
}

class _MeasureWidgetState extends State<MeasureWidget> {
  bool isSplit = false; // Default to 4 beats (one chord per measure)

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // CustomPaint draws the staff lines
        CustomPaint(
          painter: MeasurePainter(),
          size: Size(widget.width, widget.height),
        ),

        // Toggle for Chord Duration (Only show if toggle is enabled)
        if (widget.showDurationToggle)
          Positioned(
            bottom: 5,
            left: widget.width * 0.2,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSplit = !isSplit; // Toggle between 4 beats and 2 beats
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black),
                ),
                child: Text(isSplit ? "2 Beats" : "4 Beats"),
              ),
            ),
          ),

        // Single chord input (Default 4 beats)
        if (!isSplit)
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: widget.width * 0.6,
                child: TextField(
                  controller: widget.chordController1,
                  decoration: const InputDecoration(
                    hintText: "Chord",
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

        // Two chord inputs (2 beats per chord)
        if (isSplit) ...[
          Positioned(
            top: -20,
            left: widget.width * 0.1,
            child: SizedBox(
              width: widget.width * 0.4,
              child: TextField(
                controller: widget.chordController1,
                decoration: const InputDecoration(
                  hintText: "Chord 1",
                  border: InputBorder.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: widget.width * 0.1,
            child: SizedBox(
              width: widget.width * 0.4,
              child: TextField(
                controller: widget.chordController2,
                decoration: const InputDecoration(
                  hintText: "Chord 2",
                  border: InputBorder.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],

        // Delete Button (Toggles On/Off)
        if (widget.showDelete)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete, size: 16, color: Colors.red),
              onPressed: widget.onDelete,
            ),
          ),
      ],
    );
  }
}
