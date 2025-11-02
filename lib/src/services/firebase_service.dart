import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Save a song to Firestore
  Future<String> saveSong(Song song, String genre) async {
    try {
      // Convert song to JSON
      final songData = {
        'name': song.name,
        'genre': genre,
        'key': song.key,
        'chords': song.chordChanges.map((chord) => {
          'original': chord.originalChord,
          'duration': chord.durationInBeats,
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      final docRef = await _firestore.collection('songs').add(songData);
      return docRef.id; // This will be our share code
    } catch (e) {
      print('Error saving song: $e');
      rethrow;
    }
  }

  // Get a song by share code
  Future<Song?> getSongByShareCode(String shareCode) async {
    try {
      final doc = await _firestore.collection('songs').doc(shareCode).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final chordChanges = (data['chords'] as List).map((chord) => 
        ChordChange(
          chord['original'],
          [], // Options will be generated at runtime
          chord['duration'],
        )
      ).toList();

      return Song(
        data['name'],
        chordChanges,
        data['key'],
      );
    } catch (e) {
      print('Error getting song: $e');
      return null;
    }
  }

  // Get all user songs
  Future<List<Song>> getUserSongs() async {
    try {
      final snapshot = await _firestore.collection('songs').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final chordChanges = (data['chords'] as List).map((chord) => 
          ChordChange(
            chord['original'],
            [], // Options will be generated at runtime
            chord['duration'],
          )
        ).toList();

        return Song(
          data['name'],
          chordChanges,
          data['key'],
        );
      }).toList();
    } catch (e) {
      print('Error getting user songs: $e');
      return [];
    }
  }

  // Delete a song by share code
  Future<void> deleteSong(String shareCode) async {
    try {
      await _firestore.collection('songs').doc(shareCode).delete();
    } catch (e) {
      print('Error deleting song: $e');
      rethrow;
    }
  }
} 