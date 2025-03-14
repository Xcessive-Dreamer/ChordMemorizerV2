import 'package:flutter/material.dart';
import '../settings/metronome.dart'; 
import '../models/quiz_model.dart'; 

class JazzQuizView extends StatefulWidget {
  final String songName;
  final int bpm;
  final String songKey;
  final bool isSharpKey;
  final bool isFlatKey;

  const JazzQuizView({
    super.key,
    required this.songName,
    required this.bpm,
    required this.songKey,
    required this.isSharpKey,
    required this.isFlatKey,
  });

  @override
  JazzQuizViewState createState() => JazzQuizViewState();
}

class JazzQuizViewState extends State<JazzQuizView> {
  late final Metronome metronome;
  late final QuizModel quizModel;
  late Future<void> _loadSongFuture;
  late bool isFlatKey;
  late bool isSharpKey;
  
  bool isMetronomeOn = false;
  bool isCorrectChord = false;
  bool chordSelected = false;
  int? selectedChordIndex;
  int currentQuestionIndex = 0;
  int count = 0;
  List<String> selectedChords = [];
  bool isIncrementingIndex = false;

  @override
  void initState() {
    super.initState();
    // Initialize the metronome.
    metronome = Metronome(
      songName: widget.songName,
      isSongModeP: true,
      isMetronomeModeP: false,
      bpmP: widget.bpm,
    );

    quizModel = QuizModel();

    quizModel.isSharpKey = widget.isSharpKey;
    quizModel.isFlatKey = widget.isFlatKey;

    // Call loadSong only once and store its future.
    _loadSongFuture = quizModel.loadSong(widget.songName, "jazz").then((_) {
      if (quizModel.currentSong != null && quizModel.currentSong!.chordChanges.isNotEmpty) {
        setState(() {
          // Set the correct chord duration before metronome starts.
          metronome.chordDuration = quizModel.currentSong!.chordChanges[0].durationInBeats;
        });
      }
      // get current song original key
      String originalKey = quizModel.currentSong!.key; 
      if(originalKey != widget.songKey) {
        debugPrint("🎵 Original Key: $originalKey, Transposing to: ${widget.songKey}");
        quizModel.currentSong = quizModel.transposeSong(originalKey, widget.songKey, quizModel.currentSong!);
      } 
    });

    // Listen to the beat signal to update the count.
    metronome.beatSignal.listen((currCount) {
      setState(() {
        count++;
        if (count > 4) count = 1;
      });
    });

    // Listen to the correctChordStream for chord checking.
    quizModel.correctChordStream.listen((isCorrect) {
      setState(() {
        isCorrectChord = isCorrect;
      });
    });

    // Listen to the barPublisher to update the question index.
    metronome.barPublisher.listen((currCount) {
      setState(() {
        _updateQuestionIndex();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadSongFuture, // <-- Use the stored future.
      builder: (context, snapshot) {
        // Show a loading indicator while waiting.
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading Song...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        // If song wasn't loaded, show an error.
        if (quizModel.currentSong == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text("Song '${widget.songName}' not found.")),
          );
        }

        // Use the loaded song.
        final chordChanges = quizModel.currentSong!.chordChanges;
        final chordChange = chordChanges[currentQuestionIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text('Quiz: ${quizModel.currentSong!.name}'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isMetronomeOn = !isMetronomeOn;
                    if (isMetronomeOn) {
                      metronome.toggleMetronome(widget.bpm);
                    } else {
                      metronome.stop();
                    }
                  });
                },
                icon: Icon(isMetronomeOn ? Icons.stop : Icons.play_arrow),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Positioned container for song details.
              Positioned(
                top: 20,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Song Name: ${quizModel.currentSong!.name}', style: const TextStyle(color: Colors.black)),
                      Text('BPM: ${widget.bpm}', style: const TextStyle(color: Colors.black)),
                      Text('Key: ${widget.songKey}', style: const TextStyle(color: Colors.black)),
                      Text('Count: $count', style: const TextStyle(color: Colors.black)),
                      // Added text to show current chord.
                      Text('Current Chord Duration: ${chordChange.durationInBeats}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // Centered column for chord option buttons.
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (currentQuestionIndex < chordChanges.length)
                        for (int index = 0; index < chordChange.targetChordOptions.length; index++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              width: 200.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!isIncrementingIndex) {
                                    setState(() {
                                      chordSelected = true;
                                      final selectedChord = chordChange.targetChordOptions[index];
                                      quizModel.checkChord(selectedChord, chordChange.originalChord);
                                      selectedChords.add(selectedChord);
                                      selectedChordIndex = index;
                                      isIncrementingIndex = true;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedChordIndex == index
                                      ? (isCorrectChord ? Colors.green : Colors.red)
                                      : Colors.white,
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  chordChange.targetChordOptions[index],
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateQuestionIndex() {
  setState(() {
    if (quizModel.currentSong != null) {
      if (currentQuestionIndex < quizModel.currentSong!.chordChanges.length - 1) {
        currentQuestionIndex++;
      } else {
        currentQuestionIndex = 0;
      }

      // Always update the metronome to the correct duration.
      metronome.chordDuration = quizModel.currentSong!.chordChanges[currentQuestionIndex].durationInBeats;
    }

    isCorrectChord = false;
    chordSelected = false;
    selectedChordIndex = null;
    isIncrementingIndex = false;
  });
  }

  @override
  void dispose() {
    metronome.stop();
    super.dispose();
  }
}
