// ignore_for_file: unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'package:chord_memorizer_cp/src/models/quiz_model.dart';

void main() {
  group('2-5-1 Tests', () {
    late QuizModel quizModel;

    setUp(() {
      quizModel = QuizModel();
      quizModel.isSharpKey = false;
      quizModel.isFlatKey = true;
      quizModel.initializeSongs();
    });

    test('transposes C major 251 progression to Eb major', () {
      // Define the original song in C major
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
      Song? changed = quizModel.transposeSong("C", "Eb", song);

      // Get the transposed song from the quiz model
      Song? transposedSong = quizModel.songs.first;

      // Compare the transposed song with the expected result
      // expect(transposedSong, equals(expectedSong));
    });

    test('transposes Eb major 251 progression to C major', () {
      // Define the original song in C major
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
      quizModel.transposeSong("Eb", "C", expectedSong);

      // Get the transposed song from the quiz model
      Song? transposedSong = quizModel.songs.first;

      // Compare the transposed song with the expected result
      //==expect(transposedSong, equals(expectedSong));
    });

    test('transposes G major 251 progression to C major', () {
      // Define the original song in C major
      Song song = Song("2-5-1-C", [
        ChordChange("GMaj7", ["F#m7b5", "B7", "Em7", "CMaj7"], 4),
        ChordChange("F#m7b5", ["Dm7", "G7", "Cmaj7", "Am7"], 4),
        ChordChange("G7", ["Dm7", "G7", "Cmaj7", "F#m7b5"], 4),
      ]);

      // Define the expected result after transposition to Eb major
      Song expectedSong = Song("2-5-1-Eb", [
        ChordChange("EbMaj7", ["Gm7", "C7", "Cm7", "EbMaj7"], 4),
        ChordChange("Fm7", ["Gm7", "C7", "EbMaj7", "Dm7"], 4),
        ChordChange("Bb7", ["Gm7", "C7", "EbMaj7", "Cm7"], 4),
      ]);

      // Perform the transposition
      quizModel.transposeSong("Eb", "C", expectedSong);

      // Get the transposed song from the quiz model
      Song? transposedSong = quizModel.songs.first;

      // Compare the transposed song with the expected result
      //expect(transposedSong, equals(expectedSong));
    });

    test('transposes Eb major progression to C major', () {
      // Perform the transposition
      quizModel.transposeSong("A", "C", quizModel.songs.first);

      // Get the transposed song from the quiz model
      Song? transposedSong = quizModel.songs.first;

      // Compare the transposed song with the expected result
      //expect(transposedSong, equals(expectedSong));
    });

    tearDown(() {
      quizModel.dispose();
    });
  });
}
