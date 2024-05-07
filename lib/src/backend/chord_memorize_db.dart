import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String tableName = 'chord_progressions';
  static late Database _database;

  // Initialize database
  static Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'chord_progressions_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $tableName('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'song_name TEXT, '
          'chord_changes TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertDefaultProgressions() async {
    final List<Map<String, dynamic>> defaultSongs = [
      {
        'name': "1-6-2-5",
        'chordChanges': [
          {
            'originalChord': "CMaj7",
            'targetChordOptions': ["F#m7b5", "B7", "Em7", "CMaj7"],
            'durationInBeats': 4,
          },
          {
            'originalChord': "Am7",
            'targetChordOptions': ["Dm7", "G7", "Cmaj7", "Am7"],
            'durationInBeats': 2,
          },
          {
            'originalChord': "Dm7",
            'targetChordOptions': ["Dm7", "G7", "Cmaj7", "F#m7b5"],
            'durationInBeats': 2,
          },
          {
            'originalChord': "G7",
            'targetChordOptions': ["Dm7", "G7", "Cmaj7", "F#m7b5"],
            'durationInBeats': 4,
          },
          {
            'originalChord': "CMaj7",
            'targetChordOptions': ["F#m7b5", "G7", "E7", "CMaj7"],
            'durationInBeats': 2,
          },
        ],
      },
      // Add more default songs here if needed
    ];

    for (var song in defaultSongs) {
      await _database.insert(tableName, song);
    }
  }

  // Insert a chord progression
  static Future<void> insertChordProgression(String songName, String chordChanges) async {
    await _database.insert(
      tableName,
      {
        'song_name': songName,
        'chord_changes': chordChanges,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all chord progressions
  static Future<List<Map<String, dynamic>>> getChordProgressions() async {
    return _database.query(tableName);
  }
}

class ChordProgression {
  final String songName;
  final List<ChordChange> chordChanges;

  ChordProgression({required this.songName, required this.chordChanges});

  Map<String, dynamic> toMap() {
    return {
      'song_name': songName,
      'chord_changes': chordChanges.map((change) => change.toMap()).toList(),
    };
  }

  factory ChordProgression.fromMap(Map<String, dynamic> map) {
    return ChordProgression(
      songName: map['song_name'],
      chordChanges: List<ChordChange>.from(map['chord_changes'].map((change) => ChordChange.fromMap(change))),
    );
  }
}

class ChordChange {
  final String originalChord;
  final List<String> targetChordOptions;
  final int durationInBeats;

  ChordChange({required this.originalChord, required this.targetChordOptions, required this.durationInBeats});

  Map<String, dynamic> toMap() {
    return {
      'original_chord': originalChord,
      'target_chord_options': targetChordOptions,
      'duration_in_beats': durationInBeats,
    };
  }

  factory ChordChange.fromMap(Map<String, dynamic> map) {
    return ChordChange(
      originalChord: map['original_chord'],
      targetChordOptions: List<String>.from(map['target_chord_options']),
      durationInBeats: map['duration_in_beats'],
    );
  }
}
