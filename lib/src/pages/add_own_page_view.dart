import 'package:flutter/material.dart';

class AddYourOwnPageView extends StatefulWidget {
  const AddYourOwnPageView({Key? key}) : super(key: key);

  @override
  _AddYourOwnPageViewState createState() => _AddYourOwnPageViewState();
}

class _AddYourOwnPageViewState extends State<AddYourOwnPageView> {
  // Controller for beats per measure input.
  final TextEditingController _beatsController = TextEditingController(text: "4");
  
  // List of measures (each measure holds up to 2 chord inputs).
  final List<Measure> _measures = [];

  @override
  void initState() {
    super.initState();
    // Start with one empty measure.
    _measures.add(Measure());
  }

  void _addMeasure() {
    setState(() {
      _measures.add(Measure());
    });
  }

  void _saveSong() {
    // Example: Collect all chords from measures.
    List<List<String>> songMeasures = _measures.map((measure) {
      return [
        measure.chordController1.text,
        measure.chordController2.text,
      ].where((chord) => chord.isNotEmpty).toList();
    }).toList();

    // Get beats per measure.
    int beatsPerMeasure = int.tryParse(_beatsController.text) ?? 4;

    // Here you can save or process the song data.
    debugPrint("Saving Song:");
    debugPrint("Beats per Measure: $beatsPerMeasure");
    for (int i = 0; i < songMeasures.length; i++) {
      debugPrint("Measure ${i + 1}: ${songMeasures[i]}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Your Own Song"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Beats per measure input.
            TextFormField(
              controller: _beatsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Beats per Measure",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Measures grid: using Wrap to keep measures scrollable.
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_measures.length, (index) {
                return _buildMeasureWidget(_measures[index], index);
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMeasure,
              child: const Text("Add Measure"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSong,
              child: const Text("Save Song"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasureWidget(Measure measure, int index) {
    return Container(
      width: 150, // Adjust as needed. This size helps display 4 per row.
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text("Measure ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: measure.chordController1,
                  decoration: const InputDecoration(
                    labelText: "Chord 1",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: measure.chordController2,
                  decoration: const InputDecoration(
                    labelText: "Chord 2",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _beatsController.dispose();
    for (var measure in _measures) {
      measure.dispose();
    }
    super.dispose();
  }
}

class Measure {
  final TextEditingController chordController1 = TextEditingController();
  final TextEditingController chordController2 = TextEditingController();

  void dispose() {
    chordController1.dispose();
    chordController2.dispose();
  }
}
