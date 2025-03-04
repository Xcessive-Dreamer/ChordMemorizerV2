import 'package:flutter/material.dart';
import 'measure_painter.dart';
import '../settings/chord_text.dart';

class MeasureWidget extends StatefulWidget {
  final TextEditingController chordController1;
  final TextEditingController chordController2;
  final double width;
  final double height;
  final bool showDelete;
  final bool showDurationToggle;
  final bool showBorders;
  final VoidCallback onDelete;
  // Updated onFocus callback now passes both the controller and its FocusNode.
  final Function(TextEditingController, FocusNode) onFocus;

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
  // Flags to track whether each chord field is in editing mode.
  bool _editingChord1 = true;
  bool _editingChord2 = true;

  // Initialize FocusNodes immediately.
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      if (!_focusNode1.hasFocus && widget.chordController1.text.isNotEmpty) {
        setState(() {
          _editingChord1 = false;
        });
      }
    });
    _focusNode2.addListener(() {
      if (!_focusNode2.hasFocus && widget.chordController2.text.isNotEmpty) {
        setState(() {
          _editingChord2 = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  void _toggleChordDuration() {
    setState(() {
      if (isSplit) {
        widget.chordController2.clear(); // Clear second chord when switching back to 4 beats
      }
      isSplit = !isSplit;
    });
  }

  // Build InputDecoration that respects showBorders flag.
  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: widget.showBorders ? Colors.white : Colors.transparent,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: widget.showBorders ? Colors.white : Colors.transparent,
          width: 1,
        ),
      ),
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

  // Builds a chord editor which toggles between a TextField and a formatted ChordText.
  Widget _buildChordEditor(
    TextEditingController controller,
    bool isEditing,
    FocusNode focusNode,
    VoidCallback onTap,
    VoidCallback onEditingComplete,
  ) {
    if (isEditing) {
      return TextField(
        controller: controller,
        focusNode: focusNode,
        onEditingComplete: () {
          if (controller.text.isNotEmpty) {
            setState(() {
              if (controller == widget.chordController1) {
                _editingChord1 = false;
              } else {
                _editingChord2 = false;
              }
            });
          }
          onEditingComplete();
        },
        onSubmitted: (_) {
          if (controller.text.isNotEmpty) {
            setState(() {
              if (controller == widget.chordController1) {
                _editingChord1 = false;
              } else {
                _editingChord2 = false;
              }
            });
          }
          onEditingComplete();
        },
        onTap: onTap,
        decoration: _buildInputDecoration(),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: ChordText(chord: controller.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Adds space between rows
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
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  height: widget.height * 0.4,
                  width: widget.width * 0.4,
                  child: _buildChordEditor(
                    widget.chordController1,
                    _editingChord1,
                    _focusNode1,
                    () {
                      setState(() {
                        _editingChord1 = true;
                      });
                      // Pass both controller and FocusNode to parent.
                      widget.onFocus(widget.chordController1, _focusNode1);
                    },
                    () {},
                  ),
                ),
              ),
            ),

          // Two chord inputs (2 beats per chord).
          if (isSplit) ...[
            Positioned(
              top: -15,
              left: widget.width * 0.1,
              child: SizedBox(
                height: widget.height * 0.4,
                width: widget.width * 0.4,
                child: _buildChordEditor(
                  widget.chordController1,
                  _editingChord1,
                  _focusNode1,
                  () {
                    setState(() {
                      _editingChord1 = true;
                    });
                    widget.onFocus(widget.chordController1, _focusNode1);
                  },
                  () {},
                ),
              ),
            ),
            Positioned(
              top: -15,
              right: widget.width * 0.1,
              child: SizedBox(
                height: widget.height * 0.4,
                width: widget.width * 0.4,
                child: _buildChordEditor(
                  widget.chordController2,
                  _editingChord2,
                  _focusNode2,
                  () {
                    setState(() {
                      _editingChord2 = true;
                    });
                    widget.onFocus(widget.chordController2, _focusNode2);
                  },
                  () {},
                ),
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
