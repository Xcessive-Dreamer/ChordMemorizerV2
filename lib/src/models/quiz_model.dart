import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../backend/song_db.dart';

class QuizModel {
  late final bool isSharpKey;
  late final bool isFlatKey;

  // Currently loaded song from the database.
  Song? currentSong;

  Future<void> reloadDatabase() async {
    try {
      // Clear the database first
      await DatabaseHelper.instance.deleteAll();
      // Populate it again from JSON
      await DatabaseHelper.instance.populateDefaultSongs(await DatabaseHelper.instance.database);
    } catch (e) {
      debugPrint("❌ Error reloading database: $e");
    }
  }

  /// Loads a song from the database by name.
  Future<void> loadSong(String songName, String genre) async {
  try {
    // Ensure database is initialized before accessing
    await DatabaseHelper.instance.database;

    currentSong = await DatabaseHelper.instance.getSongByName(songName, genre);
    
    if (currentSong == null) {
    debugPrint("❌ Song '$songName' not found in database.");
    } else {
    debugPrint("✅ Song '${currentSong!.name}' loaded successfully.");

      // Generate chord options dynamically
      List<ChordChange> updatedChords = currentSong!.chordChanges.map((chord) {
        List<String> options = generateChordOptions(chord.originalChord);
        return ChordChange(chord.originalChord, options, chord.durationInBeats);
      }).toList();

      currentSong = Song(currentSong!.name, updatedChords, currentSong!.key);
    }
  } catch (e) {
  debugPrint("❌ Error loading song: $e");
  }
}

  /// Inserts a new song into the database. FIX AND TAKE OUT HARD CODE
  Future<void> insertSong(Song song) async {
    await DatabaseHelper.instance.insertSong(song, "Jazz", "Cm");
  }

  String extractRootNote(String chord) {
      if (chord.length > 1 && (chord[1] == '#' || chord[1] == 'b')) {
        return chord.substring(0, 2);
      }
      return chord[0];
  }
  
  /// Transposes a song into the selected key.
Song transposeSong(String originalKey, String selectedKey, Song song) {
    // Define note sets.
    List<String> sharps = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    List<String> flats = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

    // Map enharmonic equivalents.
    Map<String, String> enharmonics = {
      'C#': 'Db', 'D#': 'Eb', 'F#': 'Gb', 'G#': 'Ab', 'A#': 'Bb',
      'Db': 'C#', 'Eb': 'D#', 'Gb': 'F#', 'Ab': 'G#', 'Bb': 'A#'
    };

    // ✅ Extract root note from original and selected key.
    String originalRootNote = extractRootNote(originalKey);
    String selectedRootNote = extractRootNote(selectedKey);

    // ✅ Select the appropriate note set based on user choice.
    List<String> noteSet = isSharpKey ? sharps : flats;

    // ✅ Map selectedKey to the correct notation.
    if (isSharpKey && flats.contains(selectedRootNote)) {
      selectedRootNote = enharmonics[selectedRootNote] ?? selectedRootNote;
    } else if (isFlatKey && sharps.contains(selectedRootNote)) {
      selectedRootNote = enharmonics[selectedRootNote] ?? selectedRootNote;
    }

    // ✅ Get indexes in the chosen note set.
    int origKeyIndex = noteSet.indexOf(originalRootNote);
    int newKeyIndex = noteSet.indexOf(selectedRootNote);

    if (newKeyIndex == -1 || origKeyIndex == -1) {
      throw ArgumentError('Invalid key: $selectedKey or $originalKey not found in note set');
    }

    // ✅ Compute semitone difference.
    int semitoneDiff = newKeyIndex - origKeyIndex;
    List<ChordChange> transposedChordChanges = [];

    for (var chordChange in song.chordChanges) {
      String originalChord = chordChange.originalChord;

      // ✅ Extract root note of the chord.
      String rootNote = extractRootNote(originalChord);
      String chordQuality = originalChord.substring(rootNote.length);

      // ✅ Adjust for enharmonic equivalents.
      if (isSharpKey && flats.contains(rootNote)) {
        rootNote = enharmonics[rootNote] ?? rootNote;
      } else if (isFlatKey && sharps.contains(rootNote)) {
        rootNote = enharmonics[rootNote] ?? rootNote;
      }

      // ✅ Transpose the chord.
      int index = noteSet.indexOf(rootNote);
      if (index != -1) {
        String transposedChord = noteSet[(index + semitoneDiff) % noteSet.length] + chordQuality;

        // ✅ Generate random chord options dynamically.
        List<String> chordOptions = generateChordOptions(transposedChord);

        // ✅ Create a new chord change for the transposed chord.
        ChordChange transposedChange = ChordChange(
          transposedChord,
          chordOptions,
          chordChange.durationInBeats,
        );
        transposedChordChanges.add(transposedChange);
      }
    }

    // ✅ Return a new Song with transposed chord changes.
    return Song(song.name, transposedChordChanges, selectedKey);
}

  /// Generates 3 random chord options and includes the correct chord.
  List<String> generateChordOptions(String correctChord) {
    List<String> sharps = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    List<String> flats = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];
    List<String> chordQualities = ['m7', 'maj7', 'dim7', '7', 'm7b5'];

    Random random = Random();
    Set<String> randomChords = {};

    while (randomChords.length < 3) {
      int randNum = random.nextInt(2); // 0 for sharps, 1 for flats.
      String rootNote = randNum == 0
          ? sharps[random.nextInt(sharps.length)]
          : flats[random.nextInt(flats.length)];
      String chordQuality = chordQualities[random.nextInt(chordQualities.length)];
      randomChords.add('$rootNote$chordQuality');
    }

    List<String> chordOptions = randomChords.toList();
    chordOptions.add(correctChord);
    chordOptions.shuffle();
    return chordOptions;
  }

  /// Game-related properties and methods.
  final StreamController<bool> _correctChordController = StreamController<bool>();
  Stream<bool> get correctChordStream => _correctChordController.stream;
  int correctCount = 0;
  int totalCount = 0;

  void startGame() {
    correctCount = 0;
    totalCount = 0;
  }

  void checkChord(String selectedChord, String originalChord) {
    if (selectedChord == originalChord) {
      _correctChordController.add(true);
      correctCount++;
    } else {
      _correctChordController.add(false);
    }
    totalCount++;
  }

  void dispose() {
    _correctChordController.close();
  }
}

/// The ChordChange class now only stores the essential data.
/// The 'targetChordOptions' will be generated dynamically at runtime.
class ChordChange {
  final String originalChord;
  final List<String> targetChordOptions;
  final int durationInBeats;

  ChordChange(this.originalChord, this.targetChordOptions, this.durationInBeats);

  /// Factory constructor for creating a ChordChange from JSON.
  /// Since options are generated dynamically, we ignore them on load.
  factory ChordChange.fromJson(Map<String, dynamic> json) {
    return ChordChange(
      json['original'],
      [], // Options will be generated dynamically.
      json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': originalChord,
      'duration': durationInBeats,
      // We don't store options since they are generated at runtime.
    };
  }
}

/// The Song class stores the song name and a list of chord changes.
class Song {
  final String name;
  final List<ChordChange> chordChanges;
  final String key;  // ✅ New field for key

  Song(this.name, this.chordChanges, this.key);

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      json['name'],
      (json['chords'] as List)
          .map((chordJson) => ChordChange.fromJson(chordJson))
          .toList(),
      json['key'], // ✅ Ensure we load the key
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'chords': chordChanges.map((c) => c.toJson()).toList(),
      'key': key, // ✅ Ensure we store the key
    };
  }
}
