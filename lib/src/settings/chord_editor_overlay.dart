import 'package:flutter/material.dart';

class ChordEditorOverlay extends StatefulWidget {
  final String initialChord;
  final List<String> chordSymbols;
  
  const ChordEditorOverlay({
    super.key,
    required this.initialChord,
    required this.chordSymbols,
  });
  
  @override
  _ChordEditorOverlayState createState() => _ChordEditorOverlayState();
}

class _ChordEditorOverlayState extends State<ChordEditorOverlay> {
  late TextEditingController _controller;
  // Starting offset for the movable chord symbol box.
  Offset _chordBoxOffset = const Offset(50, 150);
  
  // List of common root note options.
  final List<String> rootNotes = [
    "A", "B", "C", "D", "E", "F", "G", "#", "b"
  ];
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialChord);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _insertSymbol(String symbol) {
    final cursorPosition = _controller.selection.baseOffset;
    final text = _controller.text;
    final newText = text.substring(0, cursorPosition) +
        symbol +
        text.substring(cursorPosition);
    setState(() {
      _controller.text = newText;
      _controller.selection =
          TextSelection.collapsed(offset: cursorPosition + symbol.length);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Semi-transparent background so the underlying page is visible.
      backgroundColor: Colors.black54,
      body: Center(
        child: Stack(
          children: [
            // Centered large text input with a Done button.
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.grey[900],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true, // Auto focus the text field.
                      controller: _controller,
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter chord here",
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Return the new chord.
                        Navigator.of(context).pop(_controller.text);
                      },
                      child: const Text("Done"),
                    )
                  ],
                ),
              ),
            ),
            // Movable chord symbol box with two tabs: "Root" and "Symbols".
            Positioned(
              left: _chordBoxOffset.dx,
              top: _chordBoxOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _chordBoxOffset += details.delta;
                  });
                },
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            color: Colors.blueGrey,
                            child: const TabBar(
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              tabs: [
                                Tab(text: "Root"),
                                Tab(text: "Symbols"),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 150,
                            child: TabBarView(
                              children: [
                                // "Root" tab: display common root note buttons.
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: rootNotes.map((root) {
                                        return ElevatedButton(
                                          onPressed: () => _insertSymbol(root),
                                          child: Text(root),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                // "Symbols" tab: display chord symbol buttons.
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: widget.chordSymbols.map((symbol) {
                                        return ElevatedButton(
                                          onPressed: () => _insertSymbol(symbol),
                                          child: Text(symbol),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
