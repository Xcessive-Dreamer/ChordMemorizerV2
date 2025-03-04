import 'package:flutter/material.dart';
import 'measure_painter.dart';
import '../settings/chord_text.dart';
import '../settings/chord_editor_overlay.dart'; // Make sure this file exists and implements your overlay.

class MeasureWidget extends StatefulWidget {
  final TextEditingController chordController1;
  final TextEditingController chordController2;
  final double width;
  final double height;
  final bool showDelete;
  final bool showDurationToggle;
  final bool showBorders;
  final VoidCallback onDelete;
  // Updated onFocus callback now only passes the active controller.
  final Function(TextEditingController) onFocus;

  const MeasureWidget({
    super.key,
    required this.chordController1,
    required this.chordController2,
    required this.width,
    required this.height,
    required this.showDelete,
    required this.showBorders,
    required this.showDurationToggle,
    required this.onDelete,
    required this.onFocus,
  });

  @override
  _MeasureWidgetState createState() => _MeasureWidgetState();
}

class _MeasureWidgetState extends State<MeasureWidget> {
  bool isSplit = false; // Default: 4 beats (one chord per measure)

  void _toggleChordDuration() {
    setState(() {
      if (isSplit) {
        widget.chordController2.clear(); // Clear second chord when switching back to 4 beats
      }
      isSplit = !isSplit;
    });
  }

  // A helper method to build a consistent InputDecoration (used here only to draw a border).
  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: widget.showBorders ? Colors.white : Colors.transparent,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    );
  }

  // Instead of inline editing, this builds a widget that displays the chord
  // (using your ChordText widget) and, when tapped, opens a full‑screen overlay.
  Widget _buildChordEditor(TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        // Notify parent of active field (if needed)
        widget.onFocus(controller);
        // Open the full-screen chord editor overlay.
        // The overlay should return the new chord text (or null if canceled).
        String? newChord = await Navigator.of(context).push(
  PageRouteBuilder(
    opaque: false, // This makes the route transparent.
    pageBuilder: (context, animation, secondaryAnimation) {
      return ChordEditorOverlay(
        initialChord: controller.text,
        chordSymbols: const [
          "△", "°", "Ø", "♯", "♭", "sus", "add9", "6", "7", "9", "11", "13"
        ],
      );
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);

        if (newChord != null) {
          setState(() {
            controller.text = newChord;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: widget.showBorders ? Colors.white : Colors.transparent, width: 1),
        ),
        alignment: Alignment.center,
        // Display the chord using your formatted ChordText widget.
        child: ChordText(chord: controller.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Adds space between rows.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // CustomPaint draws the staff lines.
          CustomPaint(
            painter: MeasurePainter(),
            size: Size(widget.width, widget.height),
          ),
          // Toggle for Chord Duration (if enabled).
          if (widget.showDurationToggle)
            Positioned(
              bottom: 5,
              left: widget.width * 0.2,
              child: GestureDetector(
                onTap: _toggleChordDuration,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(isSplit ? "2 Beats" : "4 Beats"),
                ),
              ),
            ),
          // Single chord input (Default 4 beats).
          if (!isSplit)
            Positioned(
              top: -15,
              left: -35,
              right: 0,
              child: Center(
                child: SizedBox(
                  height: widget.height * 0.4,
                  width: widget.width * 0.6,
                  child: _buildChordEditor(widget.chordController1),
                ),
              ),
            ),
          // Two chord inputs (2 beats per chord).
          if (isSplit) ...[
            Positioned(
              top: -15,
              left: widget.width * 0.01,
              child: SizedBox(
                height: widget.height * 0.4,
                width: widget.width * 0.5,
                child: _buildChordEditor(widget.chordController1),
              ),
            ),
            Positioned(
              top: -15,
              right: widget.width * -0.02,
              child: SizedBox(
                height: widget.height * 0.4,
                width: widget.width * 0.5,
                child: _buildChordEditor(widget.chordController2),
              ),
            ),
          ],
          // Delete Button.
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
      ),
    );
  }
}
