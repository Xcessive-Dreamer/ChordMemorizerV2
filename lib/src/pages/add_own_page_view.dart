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
  bool showDurationToggle = true; // Toggle for showing the white box UI

  @override
  void initState() {
    super.initState();
    // Start with 4 measures
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

  void _toggleChordDurationUI() {
    setState(() {
      showDurationToggle = !showDurationToggle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Your Own Lead Sheet")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth - 32.0; // Adjust for padding
          int measuresPerRow = 4;
          double measureWidth = availableWidth / measuresPerRow;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // ✅ Added back the 16.0 padding
              child: Column(
                children: [
                  Wrap(
                    spacing: 0,
                    runSpacing: 0,
                    children: List.generate(measureControllers1.length, (index) {
                      return MeasureWidget(
                        chordController1: measureControllers1[index],
                        chordController2: measureControllers2[index],
                        width: measureWidth,
                        height: 80,
                        showDelete: showDelete,
                        showDurationToggle: showDurationToggle,
                        onDelete: () => _deleteMeasure(index),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addMeasure,
                    child: const Text("Add Measure"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _toggleChordDurationUI,
                    child: Text(showDurationToggle ? "Hide Duration Selector" : "Show Duration Selector"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _toggleDelete,
                    child: Text(showDelete ? "Hide Delete" : "Show Delete"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveLeadSheet,
                    child: const Text("Save Lead Sheet"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
