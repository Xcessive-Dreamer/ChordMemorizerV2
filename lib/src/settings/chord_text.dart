import 'package:flutter/material.dart';

class ChordText extends StatelessWidget {
  final String chord;

  const ChordText({super.key, required this.chord});

  @override
  Widget build(BuildContext context) {
    if(chord.isEmpty) return const Text("");
    String rootNote = extractRootNote(chord);
    String extension = chord.substring(rootNote.length); // Everything after root note

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(
          fontSize: 18,
          color: Colors.white, // Adjust for dark theme
        ),
        children: [
          TextSpan(text: rootNote), // Normal root note
          if (extension.isNotEmpty) // Only add superscript if there's an extension
            WidgetSpan(
              child: Baseline(
                baseline: -3.0, // Adjust to raise superscript
                baselineType: TextBaseline.alphabetic,
                child: Text(
                  extension,
                  style: const TextStyle(fontSize: 12), // Smaller size for superscript
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Extracts the root note (C, C#, Db, etc.) from a given chord string.
  String extractRootNote(String chord) {
    if (chord.length > 1 && (chord[1] == '#' || chord[1] == 'b')) {
      return chord.substring(0, 2); // Handle accidentals (C#, Db, etc.)
    }
    return chord.substring(0, 1); // Single-letter root note
  }
}
