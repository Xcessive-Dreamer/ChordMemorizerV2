import 'package:flutter/material.dart';
import 'jazz_quiz_view.dart';
import '../backend/song_db.dart';
import '../models/quiz_model.dart';

class JazzPageView extends StatefulWidget {
  const JazzPageView({super.key});

  @override
  JazzPageViewState createState() => JazzPageViewState();
}

class JazzPageViewState extends State<JazzPageView> {
  String selectedSong = ""; // Default selected song
  String selectedKey = "";
  
  // List of available songs, initially empty; will be loaded from the database.
  List<String> songs = [];
  List<String> keys = ["Em", "Cm", "Gm"];
  
  double bpm = 90; // BPM value

  @override
  void initState() {
    super.initState();
    _loadSongsFromDB();
  }

  Future<void> _loadSongsFromDB() async {
    // Retrieve all songs from the database.
    List<Song> dbSongs = await DatabaseHelper.instance.getSongsByGenre("Jazz");
    setState(() {
      songs = dbSongs.map((song) => song.name).toList();
      // If there are songs available, set the default selection.
      if (songs.isNotEmpty) {
        selectedSong = songs[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jazz Page'),
      ),
      body: Center(
        child: songs.isEmpty
            ? const CircularProgressIndicator() // Show loading indicator while songs load.
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dropdown menu to select a song from the database.
                  UnconstrainedBox(
                    child: Container(
                      width: 200,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: DropdownMenu(
                        enableSearch: true,
                        menuStyle: MenuStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        label: const Text("Song Select"),
                        width: 200,
                        onSelected: (String? newValue) {
                          setState(() {
                            selectedSong = newValue!;
                          });
                        },
                        dropdownMenuEntries: songs
                            .map((song) => DropdownMenuEntry(value: song, label: song))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dropdown for key selection.
                  UnconstrainedBox(
                    child: Container(
                      width: 200,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: DropdownMenu(
                        enableSearch: true,
                        menuStyle: MenuStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        label: const Text("Key"),
                        width: 200,
                        onSelected: (String? newValue) {
                          setState(() {
                            selectedKey = newValue!;
                          });
                        },
                        dropdownMenuEntries: keys
                            .map((key) => DropdownMenuEntry(value: key, label: key))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text("BPM: ${bpm.toInt()}"),
                  UnconstrainedBox(
                    child: Slider(
                      min: 0,
                      max: 140,
                      value: bpm,
                      onChanged: (value) {
                        setState(() {
                          bpm = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JazzQuizView(
                            songName: selectedSong,
                            bpm: bpm.toInt(),
                            songKey: selectedKey,
                          ),
                        ),
                      );
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
      ),
    );
  }
}
