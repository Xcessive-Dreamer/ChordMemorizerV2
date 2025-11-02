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
  String displayedText = "";
  final String descriptionText = "Select a song and key to start practicing jazz chord progressions.";
  bool isTypingComplete = false;

  @override
  void initState() {
    super.initState();
    _loadSongsFromDB();
    _startTypingAnimation();
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

  void _startTypingAnimation() async {
    for (int i = 0; i < descriptionText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      setState(() {
        displayedText = descriptionText.substring(0, i + 1);
      });
    }
    setState(() {
      isTypingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.8; // 80% of screen width
    final containerHeight = screenWidth * 0.3; // 30% of screen width for height

    return Scaffold(
      appBar: AppBar(title: const Text('Jazz Page')),
      body: Center(
        child: songs.isEmpty
            ? const CircularProgressIndicator()
            : LayoutBuilder(
                builder: (context, constraints) {
                  const double minWidth = 350;
                  const double minHeight = 600;

                  return ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: minWidth,
                      minHeight: minHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Center(
                            child: SizedBox(
                              width: containerWidth,
                              height: containerHeight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Welcome To The Jazz\nChord Progression Practice!",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                        color: Theme.of(context).colorScheme.onSurface,
                                        letterSpacing: 0.5,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        displayedText,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Theme.of(context).colorScheme.onSurface,
                                          height: 1.5,
                                          letterSpacing: 0.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25.0),
                          Center(
                            child: Container(
                              width: 250,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Song",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownMenu<String>(
                                      enableSearch: true,
                                      menuHeight: 200,
                                      menuStyle: const MenuStyle(
                                        backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                                      ),
                                      textStyle: const TextStyle(color: Colors.black),
                                      width: 220,
                                      hintText: "Song Select",
                                      inputDecorationTheme: const InputDecorationTheme(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                      ),
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
                                                  foregroundColor: WidgetStatePropertyAll<Color>(Colors.black),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Select Key",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownMenu<String>(
                                      enableSearch: true,
                                      menuHeight: 200,
                                      menuStyle: const MenuStyle(
                                        backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                                      ),
                                      textStyle: const TextStyle(color: Colors.black),
                                      width: 220,
                                      hintText: "Key Select",
                                      inputDecorationTheme: const InputDecorationTheme(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                      ),
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
                                                  foregroundColor: WidgetStatePropertyAll<Color>(Colors.black),
                                                ),
                                              ))
                                          .toList(),
                                      enabled: selectedKey != null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: useFlatKeys,
                                            onChanged: (value) => _toggleFlatKeys(value!),
                                          ),
                                          const Text("Use Flat Keys (♭)"),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: useSharpKeys,
                                            onChanged: (value) => _toggleSharpKeys(value!),
                                          ),
                                          const Text("Use Sharp Keys (♯)"),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
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
                                  const SizedBox(height: 12),
                                  Center(
                                    child: ElevatedButton(
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.surface,
                                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Start Practice",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}