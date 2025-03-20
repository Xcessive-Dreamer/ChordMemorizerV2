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
  var showTitleBorder = true;
  TextEditingController? activeController; // Tracks the currently active input field

  // List of common chord symbols (used elsewhere, e.g., in an overlay)
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

  void _displayInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("How to Use"),
        // explain toggle delete, toggle borders, toggle duration UI

        content: const Text(""
            "1. Add Measure: Click the '+' button to add a new measure.\n"
            "2. Delete Measure: Click the 'Delete' button to toggle delete mode. Then, click the 'X' on any measure to remove it.\n"
            "3. Toggle Borders: Click the 'Borders' button to show/hide input borders for chords.\n"
            "4. Toggle Duration UI: Click the 'Duration' button to show/hide the chord durations,\n"
            "simply click the white box to toggle between 2 and 4 beat chords\n"
            "5. Save Lead Sheet: Click the 'Save' button to print the current lead sheet to the console.\n"
            "6. Song Title: Enter the song title in the text field above the measures."
        ),
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
        title: const Text(""),
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
                        size: 30,
                      ),
                      tooltip: "Toggle Duration Selector",
                      onPressed: _toggleChordDurationUI,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        showDelete ? Icons.delete_forever : Icons.delete_outline,
                        size: 30,
                        color: showDelete ? Colors.red : null,
                      ),
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
                  ],
                ),
              ),
              // add input for song title above icon buttons and center horizontally with a 
              // when user taps enter remove border to match song typical display
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                    width: 250, // Adjust width as needed
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Song Title",
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: showTitleBorder ? const OutlineInputBorder() : InputBorder.none,
                      ),
                      onTap: () {
                        setState(() {
                          showTitleBorder = true; // Show border when the text field is clicked
                        });
                      },
                      onSubmitted: (value) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          showTitleBorder = false; // Remove border when user hits enter
                          
                        });
                      },
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
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
                          // Updated onFocus callback: only pass the controller.
                          onFocus: (controller) {
                            setState(() {
                              activeController = controller;
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
