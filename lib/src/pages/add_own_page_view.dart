import 'package:flutter/material.dart';
import '../settings/measure_widget.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/firebase_service.dart';
import '../models/quiz_model.dart';
import 'package:flutter/services.dart';
import 'user_songs_page_view.dart';


class AddYourOwnPage extends StatefulWidget {
  final Map<String, dynamic>? songToEdit;

  const AddYourOwnPage({
    super.key,
    this.songToEdit,
  });

  @override
  AddYourOwnPageState createState() => AddYourOwnPageState();
}

class AddYourOwnPageState extends State<AddYourOwnPage> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> measureControllers1 = [];
  final List<TextEditingController> measureControllers2 = [];
  bool showDelete = false; // Toggle delete button visibility
  bool showBorders = true;
  bool showDurationToggle = true; // Toggle for showing the white box UI
  var showTitleBorder = true;
  TextEditingController? activeController; // Tracks the currently active input field
  String selectedKey = "C"; // Default key
  final List<String> keys = [
    "C", "C#", "Db", "D", "D#", "Eb", "E", "F", "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B",
    "Cm", "C#m", "Dbm", "Dm", "D#m", "Ebm", "Em", "Fm", "F#m", "Gbm", "Gm", "G#m", "Abm", "Am", "A#m", "Bbm", "Bm"
  ];

  // List of common chord symbols (used elsewhere, e.g., in an overlay)
  final List<String> chordSymbols = [
    "△",
    "°",
    "Ø",
    "♯",
    "♭",
    "sus",
    "add9",
    "6",
    "7",
    "9",
    "11",
    "13"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.songToEdit != null) {
      // Populate the form with the song to edit
      _titleController.text = widget.songToEdit!['name'];
      selectedKey = widget.songToEdit!['key'];
      
      // Calculate how many measures we need
      int totalBeats = 0;
      for (var chord in widget.songToEdit!['chords']) {
        totalBeats += chord['duration'] as int;
      }
      int numMeasures = (totalBeats / 4).ceil();

      // Initialize empty measures
      for (int i = 0; i < numMeasures; i++) {
        measureControllers1.add(TextEditingController());
        measureControllers2.add(TextEditingController());
      }

      // Track which measures should be split
      List<bool> shouldSplitMeasures = List.filled(numMeasures, false);
      
      int currentMeasure = 0;
      int i = 0;
      
      while (i < widget.songToEdit!['chords'].length) {
        var chord = widget.songToEdit!['chords'][i];
        
        if (chord['duration'] == 4) {
          // 4-beat chord goes in the first controller
          measureControllers1[currentMeasure].text = chord['original'];
          measureControllers2[currentMeasure].text = '';
          currentMeasure++;
          i++;
        } else if (chord['duration'] == 2) {
          // For 2-beat chords, we need two chords per measure
          shouldSplitMeasures[currentMeasure] = true;
          // First 2-beat chord goes in controller1
          measureControllers1[currentMeasure].text = chord['original'];
          // Second 2-beat chord goes in controller2
          if (i + 1 < widget.songToEdit!['chords'].length) {
            measureControllers2[currentMeasure].text = widget.songToEdit!['chords'][i + 1]['original'];
            i += 2; // Move to next pair of 2-beat chords
          } else {
            i++; // Move to next chord if no pair exists
          }
          currentMeasure++;
        }
      }

      // Store the split measures state
      splitMeasures = shouldSplitMeasures;
    } else {
      // Start with 4 measures for new songs
      for (int i = 0; i < 4; i++) {
        measureControllers1.add(TextEditingController());
        measureControllers2.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in [...measureControllers1, ...measureControllers2]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMeasure() {
    setState(() {
      measureControllers1.add(TextEditingController());
      measureControllers2.add(TextEditingController());
    });
  }

  void _deleteMeasure(int index) {
    setState(() {
      measureControllers1[index].dispose();
      measureControllers2[index].dispose();
      measureControllers1.removeAt(index);
      measureControllers2.removeAt(index);
    });
  }

  void _saveLeadSheet() async {
    if (!mounted) return;
    
    try {
      // Get the song title
      String title = _titleController.text.trim();
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a song title')),
        );
        return;
      }

      // Create the list of chords
      List<Map<String, dynamic>> chords = [];
      
      for (int i = 0; i < measureControllers1.length; i++) {
        String chord1 = measureControllers1[i].text.trim();
        String chord2 = measureControllers2[i].text.trim();
        
        // If both chords are empty, skip this measure
        if (chord1.isEmpty && chord2.isEmpty) continue;
        
        // If only first chord exists, it's a 4-beat chord
        if (chord1.isNotEmpty && chord2.isEmpty) {
          chords.add({
            "original": chord1,
            "duration": 4
          });
          continue;
        }
        
        // If both chords exist, they're 2-beat chords
        if (chord1.isNotEmpty) {
          chords.add({
            "original": chord1,
            "duration": 2
          });
        }
        if (chord2.isNotEmpty) {
          chords.add({
            "original": chord2,
            "duration": 2
          });
        }
      }

      if (chords.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one chord')),
        );
        return;
      }

      // Create the song object
      Map<String, dynamic> song = {
        "name": title,
        "genre": "user",
        "key": selectedKey,
        "chords": chords
      };

      // Save to local storage
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/user_songs.json');
        debugPrint('Attempting to read from: ${file.path}');
        
        List<dynamic> existingSongs = [];
        if (await file.exists()) {
          String content = await file.readAsString();
          if (content.isNotEmpty) {
            existingSongs = json.decode(content);
          }
        }

        existingSongs.add(song);
        debugPrint('Song added to local storage. Total songs: ${existingSongs.length}');

        await file.writeAsString(json.encode(existingSongs));
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song saved locally!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Error saving to local storage: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving locally: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _uploadToFirebase() async {
    if (!mounted) return;
    
    try {
      // Get the song title
      String title = _titleController.text.trim();
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a song title')),
        );
        return;
      }

      // Create the list of chords
      List<Map<String, dynamic>> chords = [];
      
      for (int i = 0; i < measureControllers1.length; i++) {
        String chord1 = measureControllers1[i].text.trim();
        String chord2 = measureControllers2[i].text.trim();
        
        // If both chords are empty, skip this measure
        if (chord1.isEmpty && chord2.isEmpty) continue;
        
        // If only first chord exists, it's a 4-beat chord
        if (chord1.isNotEmpty && chord2.isEmpty) {
          chords.add({
            "original": chord1,
            "duration": 4
          });
          continue;
        }
        
        // If both chords exist, they're 2-beat chords
        if (chord1.isNotEmpty) {
          chords.add({
            "original": chord1,
            "duration": 2
          });
        }
        if (chord2.isNotEmpty) {
          chords.add({
            "original": chord2,
            "duration": 2
          });
        }
      }

      if (chords.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one chord')),
        );
        return;
      }

      // Show confirmation dialog
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload to Firebase'),
          content: const Text('Are you sure you want to upload this song to Firebase? This will make it available for sharing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Upload'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Upload to Firebase
      try {
        final firebaseService = FirebaseService();
        final chordChanges = chords.map((chord) => 
          ChordChange(
            chord['original'],
            [], // Options will be generated at runtime
            chord['duration'],
          )
        ).toList();

        final songObject = Song(title, chordChanges, selectedKey);
        final shareCode = await firebaseService.saveSong(songObject, "user");
        
        // Save to local storage after successful Firebase upload
        try {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/user_songs.json');
          
          List<dynamic> existingSongs = [];
          if (await file.exists()) {
            String content = await file.readAsString();
            if (content.isNotEmpty) {
              existingSongs = json.decode(content);
            }
          }

          // Create the song object for local storage
          Map<String, dynamic> songToSave = {
            "name": title,
            "genre": "user",
            "key": selectedKey,
            "shareCode": shareCode,
            "chords": chords,
          };

          existingSongs.add(songToSave);
          await file.writeAsString(json.encode(existingSongs));
        } catch (e) {
          debugPrint('Error saving uploaded song to local storage: $e');
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Song uploaded successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Share Code: $shareCode',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share code copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Share Code'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserSongsPageView(),
                          ),
                        );
                      },
                      child: const Text('View Your Songs'),
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Error uploading to Firebase: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading to Firebase: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _toggleDelete() {
    setState(() {
      showDelete = !showDelete;
    });
  }

  void _toggleBorders() {
    setState(() {
      showBorders = !showBorders;
    });
  }

  void _toggleChordDurationUI() {
    setState(() {
      showDurationToggle = !showDurationToggle;
    });
  }

  void _displayInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("How to Use"),
        // explain toggle delete, toggle borders, toggle duration UI

        content: const Text(""
            "1. Add Measure: Click the '+' button to add a new measure.\n"
            "2. Delete Measure: Click the 'Delete' button to toggle delete mode. Then, click the 'X' on any measure to remove it.\n"
            "3. Toggle Borders: Click the 'Borders' button to show/hide input borders for chords.\n"
            "4. Toggle Duration UI: Click the 'Duration' button to show/hide the chord durations,\n"
            "simply click the white box to toggle between 2 and 4 beat chords\n"
            "5. Save Lead Sheet: Click the 'Save' button to print the current lead sheet to the console.\n"
            "6. Song Title: Enter the song title in the text field above the measures."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _importSong() async {
    final TextEditingController shareCodeController = TextEditingController();
    final scaffoldContext = context; // Store the main Scaffold context
    
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Song'),
        content: TextField(
          controller: shareCodeController,
          decoration: const InputDecoration(
            labelText: 'Enter Share Code',
            hintText: 'Paste the share code here',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final shareCode = shareCodeController.text.trim();
              if (shareCode.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please enter a share code')),
                );
                return;
              }

              // Close the dialog immediately
              Navigator.of(dialogContext).pop();

              try {
                final firebaseService = FirebaseService();
                final song = await firebaseService.getSongByShareCode(shareCode);
                
                if (song == null) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Song not found')),
                  );
                  return;
                }

                // Populate the form with the imported song
                setState(() {
                  _titleController.text = song.name;
                  selectedKey = song.key;
                  
                  // Clear existing measures
                  for (var controller in [...measureControllers1, ...measureControllers2]) {
                    controller.dispose();
                  }
                  measureControllers1.clear();
                  measureControllers2.clear();

                  // Calculate how many measures we need
                  int totalBeats = 0;
                  for (var chord in song.chordChanges) {
                    totalBeats += chord.durationInBeats;
                  }
                  int numMeasures = (totalBeats / 4).ceil();

                  // Initialize empty measures
                  for (int i = 0; i < numMeasures; i++) {
                    measureControllers1.add(TextEditingController());
                    measureControllers2.add(TextEditingController());
                  }

                  // Track which measures should be split
                  List<bool> shouldSplitMeasures = List.filled(numMeasures, false);
                  
                  int currentMeasure = 0;
                  int i = 0;
                  
                  while (i < song.chordChanges.length) {
                    var chord = song.chordChanges[i];
                    
                    if (chord.durationInBeats == 4) {
                      // 4-beat chord goes in the first controller
                      measureControllers1[currentMeasure].text = chord.originalChord;
                      measureControllers2[currentMeasure].text = '';
                      currentMeasure++;
                      i++;
                    } else if (chord.durationInBeats == 2) {
                      // For 2-beat chords, we need two chords per measure
                      shouldSplitMeasures[currentMeasure] = true;
                      // First 2-beat chord goes in controller1
                      measureControllers1[currentMeasure].text = chord.originalChord;
                      // Second 2-beat chord goes in controller2
                      if (i + 1 < song.chordChanges.length) {
                        measureControllers2[currentMeasure].text = song.chordChanges[i + 1].originalChord;
                        i += 2; // Move to next pair of 2-beat chords
                      } else {
                        i++; // Move to next chord if no pair exists
                      }
                      currentMeasure++;
                    }
                  }

                  // Store the split measures state
                  splitMeasures = shouldSplitMeasures;
                });

                // Show success message using the main Scaffold context
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  const SnackBar(content: Text('Song imported successfully!')),
                );

                // Save the imported song to local storage
                try {
                  final directory = await getApplicationDocumentsDirectory();
                  final file = File('${directory.path}/user_songs.json');
                  
                  List<dynamic> existingSongs = [];
                  if (await file.exists()) {
                    String content = await file.readAsString();
                    if (content.isNotEmpty) {
                      existingSongs = json.decode(content);
                    }
                  }

                  // Create the song object for local storage
                  Map<String, dynamic> songToSave = {
                    "name": song.name,
                    "genre": "user",
                    "key": song.key,
                    "shareCode": shareCode,
                    "chords": song.chordChanges.map((chord) => {
                      "original": chord.originalChord,
                      "duration": chord.durationInBeats,
                    }).toList(),
                  };

                  existingSongs.add(songToSave);
                  await file.writeAsString(json.encode(existingSongs));
                } catch (e) {
                  debugPrint('Error saving imported song to local storage: $e');
                }
              } catch (e) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(content: Text('Error importing song: ${e.toString()}')),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  // Add this field to store split measures state
  List<bool> splitMeasures = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload, size: 30),
            tooltip: "Import Song",
            onPressed: _importSong,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload, size: 30, color: Colors.blue),
            tooltip: "Upload to Firebase",
            onPressed: _uploadToFirebase,
          ),
          IconButton(
            icon: const Icon(Icons.save, size: 30, color: Colors.green),
            tooltip: "Save Locally",
            onPressed: _saveLeadSheet,
          ),
          IconButton(
            icon: const Icon(Icons.help, size: 30),
            tooltip: "How to Use",
            onPressed: _displayInfo,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth - 32.0; // Adjust for padding
          int measuresPerRow = 4;
          double measureWidth = availableWidth / measuresPerRow;

          
          return Column(
            children: [
              // Toolbar Section (buttons below AppBar)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedKey,
                        dropdownColor: Colors.grey[900],
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedKey = newValue;
                            });
                          }
                        },
                        items: keys.map((String key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Text(key),
                          );
                        }).toList(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_box, size: 30),
                      tooltip: "Add Measure",
                      onPressed: _addMeasure,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        showDurationToggle
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 30,
                      ),
                      tooltip: "Toggle Duration Selector",
                      onPressed: _toggleChordDurationUI,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        showDelete ? Icons.delete_forever : Icons.delete_outline,
                        size: 30,
                        color: showDelete ? Colors.red : null,
                      ),
                      tooltip: "Toggle Delete",
                      onPressed: _toggleDelete,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        showBorders
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 30,
                        color: showBorders ? Colors.white : null,
                      ),
                      tooltip: "Toggle Chord Borders",
                      onPressed: _toggleBorders,
                    ),
                  ],
                ),
              ),
              // add input for song title above icon buttons and center horizontally with a 
              // when user taps enter remove border to match song typical display
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                    width: 250, // Adjust width as needed
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Song Title",
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: showTitleBorder ? const OutlineInputBorder() : InputBorder.none,
                      ),
                      onTap: () {
                        setState(() {
                          showTitleBorder = true; // Show border when the text field is clicked
                        });
                      },
                      onSubmitted: (value) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          showTitleBorder = false; // Remove border when user hits enter
                          
                        });
                      },
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              // Measures Section (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 0,
                      runSpacing: 20,
                      children: List.generate(measureControllers1.length, (index) {
                        return MeasureWidget(
                          chordController1: measureControllers1[index],
                          chordController2: measureControllers2[index],
                          width: measureWidth,
                          height: 80,
                          showBorders: showBorders,
                          showDelete: showDelete,
                          showDurationToggle: showDurationToggle,
                          onDelete: () => _deleteMeasure(index),
                          onFocus: (controller) {
                            setState(() {
                              activeController = controller;
                            });
                          },
                          initialIsSplit: index < splitMeasures.length ? splitMeasures[index] : false,
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
