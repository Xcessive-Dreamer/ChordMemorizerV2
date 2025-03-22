// lib/src/pages/user_songs_page_view.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../backend/song_db.dart';
import '../models/quiz_model.dart';
import 'add_own_page_view.dart';
import 'package:path_provider/path_provider.dart';
import '../services/firebase_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';  // Add this import for Clipboard

class UserSongsPageView extends StatefulWidget {
  const UserSongsPageView({super.key});

  @override
  _UserSongsPageViewState createState() => _UserSongsPageViewState();
}

class _UserSongsPageViewState extends State<UserSongsPageView> {
  List<Map<String, dynamic>> userSongs = [];

  @override
  void initState() {
    super.initState();
    _loadUserSongs();
  }

  Future<void> _loadUserSongs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_songs.json');
      
      if (await file.exists()) {
        String content = await file.readAsString();
        if (content.isNotEmpty) {
          setState(() {
            userSongs = List<Map<String, dynamic>>.from(json.decode(content));
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user songs: $e');
    }
  }

  Future<void> _deleteSong(int index) async {
    try {
      final song = userSongs[index];
      
      // Delete from local storage
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_songs.json');
      
      if (await file.exists()) {
        String content = await file.readAsString();
        if (content.isNotEmpty) {
          List<dynamic> songs = json.decode(content);
          songs.removeAt(index);
          await file.writeAsString(json.encode(songs));
        }
      }

      // Delete from Firebase if it has a share code
      if (song['shareCode'] != null) {
        final firebaseService = FirebaseService();
        await firebaseService.deleteSong(song['shareCode']);
      }

      setState(() {
        userSongs.removeAt(index);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting song: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Songs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddYourOwnPage()),
              ).then((_) => _loadUserSongs()); // Reload songs when returning
            },
          ),
        ],
      ),
      body: userSongs.isEmpty
          ? const Center(
              child: Text('No songs yet. Add your own!'),
            )
          : ListView.builder(
              itemCount: userSongs.length,
              itemBuilder: (context, index) {
                final song = userSongs[index];
                return ListTile(
                  title: Text(
                    song['name'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Key: ${song['key']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: song['shareCode']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Song code copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Copy song code',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddYourOwnPage(
                                songToEdit: song,
                              ),
                            ),
                          ).then((_) => _loadUserSongs()); // Reload songs when returning
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Song'),
                              content: Text('Are you sure you want to delete "${song['name']}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deleteSong(index);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Implement song practice functionality
                  },
                );
              },
            ),
    );
  }
}