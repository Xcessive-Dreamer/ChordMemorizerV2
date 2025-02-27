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
    // Ensure only one connection is opened
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
        name TEXT NOT NULL
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

    // Populate default songs from JSON
    await populateDefaultSongs(db);
  }

  Future<void> populateDefaultSongs(Database db) async {
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
    int count = Sqflite.firstIntValue(countResult) ?? 0;
    if (count > 0) return; // If songs already exist, don't repopulate.

    debugPrint("Populating default songs from JSON...");

    try {
      // Load JSON using rootBundle (not a file path)
      String jsonString = await rootBundle.loadString('assets/songs/songs.json');
      List<dynamic> jsonData = jsonDecode(jsonString);

      for (var songData in jsonData) {
        Song song = Song(
          songData["name"],
          (songData["chords"] as List).map((chord) {
            return ChordChange(
              chord["original"],
              [], // Options will be generated dynamically at runtime.
              chord["duration"]
            );
          }).toList()
        );
        await insertSong(song);
      }

      debugPrint("✅ Default songs loaded successfully!");
    } catch (e) {
      debugPrint("❌ Error loading default songs: $e");
    }
  }

  Future<int> insertSong(Song song) async {
    final db = await instance.database;
    int songId = await db.insert('songs', {'name': song.name});
    for (var chord in song.chordChanges) {
      await db.insert('chord_changes', {
        'song_id': songId,
        'original_chord': chord.originalChord,
        // Store chord options as a comma-separated string.
        // Since options are generated dynamically, this may be an empty string.
        'target_chord_options': chord.targetChordOptions.join(','),
        'duration': chord.durationInBeats,
      });
    }
    return songId;
  }

  Future<Song?> getSongByName(String name) async {
    final db = await instance.database;
    final songData = await db.query(
      'songs',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (songData.isEmpty) return null;
    final songRow = songData.first;

    final chordData = await db.query(
      'chord_changes',
      where: 'song_id = ?',
      whereArgs: [songRow['id']],
    );

    List<ChordChange> chordChanges = chordData.map((map) {
      return ChordChange(
        map['original_chord'] as String,
        // Convert the comma-separated string back into a list.
        (map['target_chord_options'] as String).split(','),
        map['duration'] as int,
      );
    }).toList();

    return Song(songRow['name'] as String, chordChanges);
  }

  Future<List<Song>> getAllSongs() async {
    final db = await instance.database;
    final songData = await db.query('songs');
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
