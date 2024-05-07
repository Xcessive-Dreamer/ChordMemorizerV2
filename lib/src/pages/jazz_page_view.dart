import 'package:flutter/material.dart';
import 'jazz_quiz_view.dart';

class JazzPageView extends StatefulWidget {
  const JazzPageView({super.key});

  @override
  JazzPageViewState createState() => JazzPageViewState();
}

class JazzPageViewState extends State<JazzPageView> {
  String selectedSong = ""; // Default selected song
  String selectedKey = "";

  // List of available songs
  List<String> songs = ["Autumn Leaves", "Misty", "1-6-2-5"];
  List<String> keys = ["Em", "Cm", "Gm"];
  
  double bpm = 90; // Update with unique song names

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jazz Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dropdown menu to select songs
            UnconstrainedBox(
              child: Container(
                width: 200,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5)),
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
                  dropdownMenuEntries: songs.map((song) {
                    return DropdownMenuEntry(value: song, label: song);
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 20),
          // DROP DOWN FOR KEY
          UnconstrainedBox(
            child: Container(
              width: 200,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5)),
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
                dropdownMenuEntries: keys.map((key) {
                  return DropdownMenuEntry(value: key, label: key);
                }).toList(),
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
              )
          ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JazzQuizView(songName: selectedSong,bpm: bpm.toInt(), songKey: selectedKey,)),
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
