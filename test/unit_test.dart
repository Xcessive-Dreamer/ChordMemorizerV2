// ignore_for_file: unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'package:chord_memorizer_cp/src/models/quiz_model.dart';

void main() {
  group('2-5-1 Tests', () {
    late QuizModel quizModel;

    setUp(() async {
      quizModel = QuizModel();
      quizModel.isSharpKey = false;
      quizModel.isFlatKey = true;
      // No longer calling initializeSongs() because we're now using DB operations.
    });

    test('transposes C major 251 progression to Eb major', () {
      // Define the original song in C major manually
      Song song = Song("2-5-1-C", [
        ChordChange("CMaj7", ["F#m7b5", "B7", "Em7", "CMaj7"], 4),
        ChordChange("Dm7", ["Dm7", "G7", "Cmaj7", "Am7"], 4),
        ChordChange("G7", ["Dm7", "G7", "Cmaj7", "F#m7b5"], 4),
      ]);

      // Define the expected result after transposition to Eb major
      Song expectedSong = Song("2-5-1-Eb", [
        ChordChange("EbMaj7", ["Gm7", "C7", "Cm7", "EbMaj7"], 4),
        ChordChange("Fm7", ["Gm7", "C7", "EbMaj7", "Dm7"], 4),
        ChordChange("Bb7", ["Gm7", "C7", "EbMaj7", "Cm7"], 4),
      ]);

      // Perform the transposition
      Song transposedSong = quizModel.transposeSong("C", "Eb", song);
      expect(compareSongs(transposedSong, expectedSong), isTrue);
    });

    test('transposes Eb major 251 progression to C major', () {
      // Define the original song in Eb major manually
      Song song = Song("2-5-1-Eb", [
        ChordChange("EbMaj7", ["Gm7", "C7", "Cm7", "EbMaj7"], 4),
        ChordChange("Fm7", ["Gm7", "C7", "EbMaj7", "Dm7"], 4),
        ChordChange("Bb7", ["Gm7", "C7", "EbMaj7", "Cm7"], 4),
      ]);

      // Define the expected result after transposition to C major
      Song expectedSong = Song("2-5-1-C", [
        ChordChange("CMaj7", ["F#m7b5", "B7", "Em7", "CMaj7"], 4),
        ChordChange("Dm7", ["Dm7", "G7", "Cmaj7", "Am7"], 4),
        ChordChange("G7", ["Dm7", "G7", "Cmaj7", "F#m7b5"], 4),
      ]);

      // Perform the transposition
      Song transposedSong = quizModel.transposeSong("Eb", "C", song);
      expect(compareSongs(transposedSong, expectedSong), isTrue);
    });

    test('transposes G major 176 progression to C major', () {
      // G major song
      Song song = Song("1-7-6-G", [
        ChordChange("GMaj7", ["F#m7b5", "B7", "Em7", "GMaj7"], 4),
        ChordChange("F#m7b5", ["Dm7", "G7", "Cmaj7", "F#m7b5"], 4),
        ChordChange("Em7", ["Em7", "G7", "Cmaj7", "F#m7b5"], 4),
      ]);

      // Expected C major song
      Song expectedSong = Song("1-7-6-C", [
        ChordChange("CMaj7", ["F#m7b5", "B7", "Em7", "CMaj7"], 4),
        ChordChange("Bm7b5", ["Dm7", "G7", "Cmaj7", "Bm7b5"], 4),
        ChordChange("Am7", ["Am7", "G7", "Cmaj7", "F#m7b5"], 4),
      ]);

      // Perform the transposition
      Song transposedSong = quizModel.transposeSong("G", "C", song);
      expect(compareSongs(transposedSong, expectedSong), isTrue);
    });

    test('loads song from DB and transposes it', () async {
      // Create a song to insert into the DB.
      Song songToInsert = Song("Test Song", [
        ChordChange("CMaj7", ["F#m7b5", "B7", "Em7", "CMaj7"], 4),
        ChordChange("Dm7", ["Dm7", "G7", "Cmaj7", "Am7"], 4),
      ]);
      // Insert the song into the DB.
      await quizModel.insertSong(songToInsert);

      // Now load the song by its name.
      await quizModel.loadSong("Test Song");
      expect(quizModel.currentSong, isNotNull);

      // Define expected transposition (for example, transposing from C to Eb).
      Song expectedSong = Song("Test Song", [
        ChordChange("EbMaj7", ["Gm7", "C7", "Cm7", "EbMaj7"], 4),
        ChordChange("Fm7", ["Gm7", "C7", "EbMaj7", "Dm7"], 4),
      ]);

      // Transpose the loaded song.
      Song transposedSong = quizModel.transposeSong("C", "Eb", quizModel.currentSong!);
      expect(compareSongs(transposedSong, expectedSong), isTrue);
    });

    tearDown(() {
      quizModel.dispose();
    });
  });
}

/// Utility function to compare two songs based on their chord changes.
bool compareSongs(Song transposed, Song expected) {
  if (transposed.chordChanges.length != expected.chordChanges.length) {
    return false;
  }
  for (int i = 0; i < expected.chordChanges.length; i++) {
    String transposedChord = transposed.chordChanges[i].originalChord;
    String expectedChord = expected.chordChanges[i].originalChord;
    if (transposedChord != expectedChord) {
      return false;
    }
  }
  return true;
}
