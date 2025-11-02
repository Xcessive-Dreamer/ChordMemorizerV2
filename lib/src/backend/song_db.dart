import 'dart:convert';

import 'package:flutter/services.dart';
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
    debugPrint("📂 Database path: $dbPath");
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      singleInstance: false,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        genre TEXT NOT NULL,
        key TEXT NOT NULL 
      )
    ''');

    await db.execute('''
      CREATE TABLE chord_changes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        original_chord TEXT NOT NULL,
        duration INTEGER NOT NULL,
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    await populateDefaultSongs(db);
  }

  Future<void> populateDefaultSongs(Database db) async {
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
    int count = Sqflite.firstIntValue(countResult) ?? 0;
    if (count > 0) return; 

    debugPrint("📥 Populating default songs from JSON...");

    List<String> genreFiles = ["jazz", "pop", "rock", "country"]; 

    for (String genreFile in genreFiles) {
      try {
        String jsonPath = 'assets/songs/$genreFile.json';
        String jsonString = await rootBundle.loadString(jsonPath);
        List<dynamic> jsonData = jsonDecode(jsonString);

        for (var songData in jsonData) {
          String genre = songData["genre"];
          String key = songData["key"];

          Song song = Song(
            songData["name"],
            (songData["chords"] as List).map((chord) {
              return ChordChange(
                chord["original"],
                [],
                chord["duration"]
              );
            }).toList(), 
            songData["key"],
          );

          await insertSong(song, genre, key);
        }

        debugPrint("✅ Loaded ${jsonData.length} songs from $genreFile.json!");
      } catch (e) {
        debugPrint("❌ Error loading $genreFile.json: $e");
      }
    }
  }

  Future<int> insertSong(Song song, String genre, String key) async {
    final db = await instance.database;
    int songId = await db.insert('songs', {
      'name': song.name,
      'genre': genre,
      'key': key,
    });

    for (var chord in song.chordChanges) {
      await db.insert('chord_changes', {
        'song_id': songId,
        'original_chord': chord.originalChord,
        'duration': chord.durationInBeats,
      });
    }
    return songId;
  }

  /// ✅ **Updated method: Now pulls from the database instead of JSON**
  Future<Song?> getSongByName(String songName, String genre) async {
    debugPrint("🔍 Searching for '$songName' in the database...");
    debugPrint(genre);
    final db = await instance.database;

    // Query the `songs` table for a matching song name and genre.
    final songData = await db.query(
      'songs',
      where: 'name = ? AND genre = ?',
      whereArgs: [songName, genre],
      limit: 1,
    );

    if (songData.isEmpty) {
      debugPrint("❌ Song '$songName' not found in database.");
      return null;
    }

    final songRow = songData.first;

    // Query the `chord_changes` table for associated chords.
    final chordData = await db.query(
      'chord_changes',
      where: 'song_id = ?',
      whereArgs: [songRow['id']],
    );

    List<ChordChange> chordChanges = chordData.map((map) {
      return ChordChange(
        map['original_chord'] as String,
        [],  // Options are generated dynamically by `QuizModel`.
        map['duration'] as int,
      );
    }).toList();

    debugPrint("✅ Found song '${songRow['name']}' in database.");
    return (Song(songRow['name'] as String, chordChanges, songRow['key'] as String));
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
        [],
        map['duration'] as int,
      );
    }).toList();

    // ✅ Include `key` from the database
    songs.add(Song(songRow['name'] as String, chordChanges, songRow['key'] as String));
  }
  return songs;
}


  Future<void> deleteAll() async {
    // temporarily delete and refill db
    final db = await instance.database;
    debugPrint("🗑️ Deleting all songs and chord changes...");
    await db.delete('chord_changes');
    await db.delete('songs');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
