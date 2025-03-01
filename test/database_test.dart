import 'package:flutter_test/flutter_test.dart';
import 'package:chord_memorizer_cp/src/backend/song_db.dart';
import 'package:chord_memorizer_cp/src/models/quiz_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:developer';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('Retrieve "Autumn Leaves" song from DB after clearing and populating defaults', () async {
    // Clear the database to ensure a fresh start.
    //await DatabaseHelper.instance.deleteAll();

    // Populate the default songs from the JSON file.
    // Note: The populateDefaultSongs method requires a Database instance.
    await DatabaseHelper.instance.populateDefaultSongs(await DatabaseHelper.instance.database);

    // Retrieve the song by name ("Autumn Leaves").
    Song? song = await DatabaseHelper.instance.getSongByName("Misty", "songs");

    // log out song details for verification.
    if (song != null) {
      log("Song: ${song.name}");
      for (var chordChange in song.chordChanges) {
        log("  Chord: ${chordChange.originalChord}");
        log("  Options: ${chordChange.targetChordOptions}");
        log("  Duration: ${chordChange.durationInBeats}");
      }
    } else {
      log("Song 'Autumn Leaves' not found in the database.");
    }
  });

  group('Database Song Retrieval Test', () {
    late QuizModel quizModel;

    setUp(() async {
      quizModel = QuizModel();
      quizModel.isSharpKey = false;
      quizModel.isFlatKey = true;

      // Optional: If you want to ensure default songs are populated,
      // you can call:
      // await DatabaseHelper.instance.populateDefaultSongs(await DatabaseHelper.instance.database);
    });

    test('Retrieve "Autumn Leaves" from DB and log song data', () async {
      // Load the song by name from the database.
      await quizModel.loadSong("Autumn Leaves", "songs");

      if (quizModel.currentSong != null) {
        log("Song: ${quizModel.currentSong!.name}");
        for (var chordChange in quizModel.currentSong!.chordChanges) {
          log("Chord: ${chordChange.originalChord}");
          log("Duration: ${chordChange.durationInBeats}");
          log("Duration: ${chordChange.targetChordOptions}");
        }
      } else {
        log("Song 'Autumn Leaves' not found in the database.");
      }
    });

    tearDown(() {
      quizModel.dispose();
    });
  });
}
