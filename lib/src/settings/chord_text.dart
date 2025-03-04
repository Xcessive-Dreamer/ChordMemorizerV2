import 'package:flutter/material.dart';

class ChordText extends StatelessWidget {
  final String chord;

  const ChordText({super.key, required this.chord});

  @override
  Widget build(BuildContext context) {
    if (chord.isEmpty) return const Text("");

    // Check if this is a slash chord (e.g., "Cm7/Bb")
    String mainChord;
    String bassChord = "";
    if (chord.contains('/')) {
      List<String> parts = chord.split('/');
      mainChord = parts[0];
      bassChord = parts[1];
    } else {
      mainChord = chord;
    }

    // Extract the root note from the main chord.
    String rootNote = extractRootNote(mainChord);
    String extension = mainChord.substring(rootNote.length);

    // List of tokens that should be superscripted.
    // Sorted by descending length so that longer tokens are matched first.
    final List<String> superscriptTokens = [
      "add9",
      "sus",
      "11",
      "13",
      "°",
      "Ø",
      "6",
      "7",
      "9"
    ]..sort((a, b) => b.length.compareTo(a.length));

    List<InlineSpan> extensionSpans = [];
    int i = 0;
    while (i < extension.length) {
      bool matched = false;
      for (String token in superscriptTokens) {
        if (i + token.length <= extension.length &&
            extension.substring(i, i + token.length) == token) {
          extensionSpans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: Transform.translate(
                offset: const Offset(0, -4), // adjust for superscript
                child: Text(
                  token,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          );
          i += token.length;
          matched = true;
          break;
        }
      }
      if (!matched) {
        // No token matched, so just add the current character as normal text.
        extensionSpans.add(TextSpan(text: extension[i]));
        i++;
      }
    }

    // Build the list of spans for the main chord.
    List<InlineSpan> spans = [];
    spans.add(TextSpan(text: rootNote));
    if (extensionSpans.isNotEmpty) {
      spans.addAll(extensionSpans);
    }

    // Append bass chord (if any) without superscripting.
    if (bassChord.isNotEmpty) {
      spans.add(const TextSpan(text: "/"));
      spans.add(TextSpan(text: bassChord));
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 12,
              color: Colors.white, // adjust for dark theme if needed
            ),
        children: spans,
      ),
    );
  }

  /// Extracts the root note (e.g. "C", "C#", "Db") from the given chord string.
  String extractRootNote(String chord) {
    if (chord.length > 1 && (chord[1] == '#' || chord[1] == 'b')) {
      return chord.substring(0, 2);
    }
    return chord.substring(0, 1);
  }
}
