import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/quiz_model.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database ??= await _initDB('songs.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      singleInstance: false, // Prevents multiple open instances
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        genre TEXT NOT NULL  -- ✅ Added genre field
      )
    ''');

    await db.execute('''
      CREATE TABLE chord_changes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        original_chord TEXT NOT NULL,
        target_chord_options TEXT NOT NULL,
        duration INTEGER NOT NULL,
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    await populateDefaultSongs(db);
  }

Future<void> populateDefaultSongs(Database db) async {
  final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
  int count = Sqflite.firstIntValue(countResult) ?? 0;
  if (count > 0) return; // If songs already exist, don't repopulate.

  debugPrint("📥 Populating default songs from JSON...");

  List<String> genreFiles = ["jazz", "pop", "rock", "country"]; // ✅ JSON file names

  for (String genreFile in genreFiles) {
    try {
      String jsonPath = 'assets/songs/$genreFile.json';
      String jsonString = await rootBundle.loadString(jsonPath);
      List<dynamic> jsonData = jsonDecode(jsonString);

      for (var songData in jsonData) {
        // ✅ Extract genre from JSON instead of assuming from filename
        String genre = songData["genre"];

        Song song = Song(
          songData["name"],
          (songData["chords"] as List).map((chord) {
            return ChordChange(
              chord["original"],
              [],
              chord["duration"]
            );
          }).toList()
        );

        // ✅ Store genre from JSON, not from loop
        await insertSong(song, genre);
      }

      debugPrint("✅ Loaded ${jsonData.length} songs from $genreFile.json!");
    } catch (e) {
      debugPrint("❌ Error loading $genreFile.json: $e");
    }
  }
}

  Future<int> insertSong(Song song, String genre) async {
    final db = await instance.database;
    int songId = await db.insert('songs', {
      'name': song.name,
      'genre': genre  // ✅ Store genre in database
    });

    for (var chord in song.chordChanges) {
      await db.insert('chord_changes', {
        'song_id': songId,
        'original_chord': chord.originalChord,
        'target_chord_options': chord.targetChordOptions.join(','),
        'duration': chord.durationInBeats,
      });
    }
    return songId;
  }

  Future<Song?> getSongByName(String songName, String genre) async {
    debugPrint("🔍 Searching for '$songName' in $genre.json...");

    try {
      String jsonPath = 'assets/songs/$genre.json';
      String jsonString = await rootBundle.loadString(jsonPath);
      List<dynamic> jsonData = jsonDecode(jsonString);

      for (var songData in jsonData) {
        if (songData["name"] == songName) {
          List<ChordChange> chordChanges = (songData["chords"] as List).map((chord) {
            return ChordChange(
              chord["original"],
              [],
              chord["duration"]
            );
          }).toList();

          debugPrint("✅ Found song '$songName' in $genre.json.");
          return Song(songName, chordChanges);
        }
      }
    } catch (e) {
      debugPrint("❌ Error loading $genre.json: $e");
    }

    debugPrint("❌ Song '$songName' not found in $genre.json.");
    return null; // Song not found
  }

  Future<List<Song>> getSongsByGenre(String genre) async {
    final db = await instance.database;
    final songData = await db.query(
      'songs',
      where: 'genre = ?',
      whereArgs: [genre],
    );

    List<Song> songs = [];
    for (var songRow in songData) {
      final chordData = await db.query(
        'chord_changes',
        where: 'song_id = ?',
        whereArgs: [songRow['id']],
      );

      List<ChordChange> chordChanges = chordData.map((map) {
        return ChordChange(
          map['original_chord'] as String,
          (map['target_chord_options'] as String).split(','),
          map['duration'] as int,
        );
      }).toList();

      songs.add(Song(songRow['name'] as String, chordChanges));
    }
    return songs;
  }

  Future<void> deleteAll() async {
    final db = await instance.database;
    await db.delete('chord_changes');
    await db.delete('songs');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
