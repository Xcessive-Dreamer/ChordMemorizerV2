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
  String? selectedSong;
  String? selectedKey;
  bool useFlatKeys = true; // Default to flats
  bool useSharpKeys = false; // Default to flats

  List<String> songs = [];
  List<String> keys = [];
  double bpm = 90;

  @override
  void initState() {
    super.initState();
    _loadSongsFromDB();
  }

  Future<void> _loadSongsFromDB() async {
    List<Song> dbSongs = await DatabaseHelper.instance.getSongsByGenre("jazz");
    setState(() {
      songs = dbSongs.map((song) => song.name).toList();
      if (dbSongs.isNotEmpty) {
        selectedSong = dbSongs[0].name;
        selectedKey = dbSongs[0].key;
        keys = _generateKeyOptions(selectedKey!);
      }
    });
  }

  Future<void> _updateKeyForSelectedSong(String songName) async {
    List<Song> dbSongs = await DatabaseHelper.instance.getSongsByGenre("jazz");
    try {
      Song selected = dbSongs.firstWhere((song) => song.name == songName);
      setState(() {
        selectedKey = selected.key;
        keys = _generateKeyOptions(selected.key);
      });
    } catch (e) {
      debugPrint("❌ Could not find key for song $songName: $e");
    }
  }

  // use circle of fifths logic
  List<String> _generateKeyOptions(String songKey) {
    List<String> majorSharps = ["A", "B", "C", "C#", "D", "E", "F#", "G"];
    List<String> majorFlats = ["Ab", "Bb", "C", "Cb", "Db", "Eb", "F", "Gb"];
    List<String> minorSharps = ["D#m", "G#m", "C#m", "F#m", "Bm", "Em", "Am", "Fm"];
    List<String> minorFlats = ["Am", "Dm", "Gm", "Cm", "Fm", "Bbm", "Ebm", "Abm"];

    bool isMinor = songKey.endsWith("m");
    List<String> allKeys = isMinor
        ? (useFlatKeys ? minorFlats : minorSharps)
        : (useFlatKeys ? majorFlats : majorSharps);

    return [songKey, ...allKeys.where((key) => key != songKey)];
  }

  void _toggleFlatKeys(bool value) {
    setState(() {
      useFlatKeys = value;
      useSharpKeys = !value;
      if (selectedKey != null) {
        keys = _generateKeyOptions(selectedKey!);
      }
    });
  }

  void _toggleSharpKeys(bool value) {
    setState(() {
      useSharpKeys = value;
      useFlatKeys = !value;
      if (selectedKey != null) {
        keys = _generateKeyOptions(selectedKey!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jazz Page')),
      body: Center(
        child: songs.isEmpty
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Song Selection Dropdown
                  UnconstrainedBox(
                    child: Container(
                      width: 200,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: DropdownMenu<String>(
                        enableSearch: true,
                        menuHeight: 200,
                        menuStyle: const MenuStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                        ),
                        textStyle: const TextStyle(color: Colors.black),
                        label: const Text("Song Select", style: TextStyle(color: Colors.black)),
                        width: 200,
                        onSelected: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedSong = newValue;
                            });
                            _updateKeyForSelectedSong(newValue);
                          }
                        },
                        dropdownMenuEntries: songs
                            .map((song) => DropdownMenuEntry<String>(
                                  value: song,
                                  label: song,
                                  style: const ButtonStyle(
                                    foregroundColor: MaterialStatePropertyAll<Color>(Colors.black),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Key Selection Dropdown
                  UnconstrainedBox(
                    child: Container(
                      width: 200,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: DropdownMenu<String>(
                        enableSearch: true,
                        menuHeight: 200,
                        menuStyle: const MenuStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                        ),
                        textStyle: const TextStyle(color: Colors.black),
                        label: const Text("Key", style: TextStyle(color: Colors.black)),
                        width: 200,
                        onSelected: selectedKey != null
                            ? (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedKey = newValue;
                                  });
                                }
                              }
                            : null,
                        dropdownMenuEntries: keys
                            .map((key) => DropdownMenuEntry<String>(
                                  value: key,
                                  label: key,
                                  style: const ButtonStyle(
                                    foregroundColor: MaterialStatePropertyAll<Color>(Colors.black),
                                  ),
                                ))
                            .toList(),
                        enabled: selectedKey != null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Flat & Sharp Key Toggle Checkboxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: useFlatKeys,
                        onChanged: (value) => _toggleFlatKeys(value!),
                      ),
                      const Text("Use Flat Keys (♭)"),
                      const SizedBox(width: 10),
                      Checkbox(
                        value: useSharpKeys,
                        onChanged: (value) => _toggleSharpKeys(value!),
                      ),
                      const Text("Use Sharp Keys (♯)"),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Text("BPM: ${bpm.toInt()}"),
                  UnconstrainedBox(
                    child: Slider(
                      min: 40,
                      max: 200,
                      value: bpm,
                      onChanged: (value) {
                        setState(() {
                          bpm = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Continue Button - Pass `useFlatKeys` to `JazzQuizView`
                  ElevatedButton(
                    onPressed: (selectedSong != null && selectedKey != null)
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JazzQuizView(
                                  songName: selectedSong!,
                                  bpm: bpm.toInt(),
                                  songKey: selectedKey!,
                                  isSharpKey: useSharpKeys,
                                  isFlatKey: useFlatKeys,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Continue'),
                  ),
                ],
              ),
      ),
    );
  }
}
