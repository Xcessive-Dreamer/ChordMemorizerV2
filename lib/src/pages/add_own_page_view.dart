import 'package:flutter/material.dart';
import '../settings/measure_widget.dart';

class AddYourOwnPage extends StatefulWidget {
  const AddYourOwnPage({super.key});

  @override
  _AddYourOwnPageState createState() => _AddYourOwnPageState();
}

class _AddYourOwnPageState extends State<AddYourOwnPage> {
  final List<TextEditingController> measureControllers1 = [];
  final List<TextEditingController> measureControllers2 = [];
  bool showDelete = false; // Toggle delete button visibility
  bool showBorders = true;
  bool showDurationToggle = true; // Toggle for showing the white box UI
  TextEditingController? activeController; // Tracks the currently active input field
  FocusNode? activeFocusNode; // Tracks the FocusNode of the active field

  // List of common chord symbols
  final List<String> chordSymbols = [
    "△",
    "°",
    "Ø",
    "♯",
    "♭",
    "sus",
    "add9",
    "6",
    "7",
    "9",
    "11",
    "13"
  ];

  @override
  void initState() {
    super.initState();
    // Start with 4 measures.
    for (int i = 0; i < 4; i++) {
      measureControllers1.add(TextEditingController());
      measureControllers2.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in [...measureControllers1, ...measureControllers2]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMeasure() {
    setState(() {
      measureControllers1.add(TextEditingController());
      measureControllers2.add(TextEditingController());
    });
  }

  void _deleteMeasure(int index) {
    setState(() {
      measureControllers1[index].dispose();
      measureControllers2[index].dispose();
      measureControllers1.removeAt(index);
      measureControllers2.removeAt(index);
    });
  }

  void _saveLeadSheet() {
    for (int i = 0; i < measureControllers1.length; i++) {
      debugPrint("Measure ${i + 1}: ${measureControllers1[i].text} ${measureControllers2[i].text}");
    }
  }

  void _toggleDelete() {
    setState(() {
      showDelete = !showDelete;
    });
  }

  void _toggleBorders() {
    setState(() {
      showBorders = !showBorders;
    });
  }

  void _toggleChordDurationUI() {
    setState(() {
      showDurationToggle = !showDurationToggle;
    });
  }

  /// Inserts the selected symbol into the currently active chord input field
  /// and re-requests focus so the field stays in editing mode.
  void _insertChordSymbol(String symbol) {
    if (activeController != null) {
      final cursorPosition = activeController!.selection.baseOffset;
      final text = activeController!.text;
      final newText = text.substring(0, cursorPosition) +
          symbol +
          text.substring(cursorPosition);

      setState(() {
        activeController!.text = newText;
        activeController!.selection =
            TextSelection.collapsed(offset: cursorPosition + symbol.length);
      });
      // Re-request focus to keep the field in editing mode.
      activeFocusNode?.requestFocus();
    }
  }

  void _displayInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("How to Use"),
        content: const Text("Instructions on how to use this feature..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Your Own Lead Sheet"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 30, color: Colors.green),
            tooltip: "Save Lead Sheet",
            onPressed: _saveLeadSheet,
          ),
          IconButton(
            icon: const Icon(Icons.help, size: 30),
            tooltip: "How to Use",
            onPressed: _displayInfo,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth - 32.0; // Adjust for padding
          int measuresPerRow = 4;
          double measureWidth = availableWidth / measuresPerRow;

          return Column(
            children: [
              // Toolbar Section (buttons below AppBar)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_box, size: 30),
                      tooltip: "Add Measure",
                      onPressed: _addMeasure,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                          showDurationToggle
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 30),
                      tooltip: "Toggle Duration Selector",
                      onPressed: _toggleChordDurationUI,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                          showDelete
                              ? Icons.delete_forever
                              : Icons.delete_outline,
                          size: 30,
                          color: showDelete ? Colors.red : null),
                      tooltip: "Toggle Delete",
                      onPressed: _toggleDelete,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        showBorders
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 30,
                        color: showBorders ? Colors.white : null,
                      ),
                      tooltip: "Toggle Chord Borders",
                      onPressed: _toggleBorders,
                    ),
                    const SizedBox(width: 10),
                    // Chord Symbol Dropdown.
                    DropdownButton<String>(
                      hint: const Text("Symbols"),
                      items: chordSymbols.map((String symbol) {
                        return DropdownMenuItem<String>(
                          value: symbol,
                          child: Text(symbol,
                              style: const TextStyle(fontSize: 20)),
                        );
                      }).toList(),
                      onChanged: (symbol) {
                        if (symbol != null) {
                          _insertChordSymbol(symbol);
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Measures Section (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 0,
                      runSpacing: 20,
                      children: List.generate(measureControllers1.length, (index) {
                        return MeasureWidget(
                          chordController1: measureControllers1[index],
                          chordController2: measureControllers2[index],
                          width: measureWidth,
                          height: 80,
                          showBorders: showBorders,
                          showDelete: showDelete,
                          showDurationToggle: showDurationToggle,
                          onDelete: () => _deleteMeasure(index),
                          // Update onFocus to capture both the active controller and its FocusNode.
                          onFocus: (controller, focusNode) {
                            setState(() {
                              activeController = controller;
                              activeFocusNode = focusNode;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
