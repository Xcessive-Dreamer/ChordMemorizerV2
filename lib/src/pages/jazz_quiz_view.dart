import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../settings/metronome.dart'; // Import your Metronome class
import '../models/quiz_model.dart'; // Import your QuizModel class

class JazzQuizView extends StatefulWidget {
  final String songName;
  final int bpm;
  final String songKey;

  const JazzQuizView({
    super.key,
    required this.songName,
    required this.bpm,
    required this.songKey,
  });

  @override
  JazzQuizViewState createState() => JazzQuizViewState();
}

class JazzQuizViewState extends State<JazzQuizView> {
  late final Metronome metronome;
  late final QuizModel quizModel;
  bool isMetronomeOn = false;
  bool isCorrectChord = false;
  bool chordSelected = false;
  int? selectedChordIndex;
  int currentQuestionIndex = 0;
  int count = 0;
  List<String> selectedChords = [];
  bool isIncrementingIndex = false;
  late int songIndex; // Add songIndex variable

  @override
  void initState() {
    super.initState();
    metronome = Metronome(songName: widget.songName, isSongModeP: true, isMetronomeModeP: false, bpmP: widget.bpm);
    quizModel = QuizModel(); // Initialize your QuizModel instance
    quizModel.initializeSongs(); // Initialize songs before getting index

    // Calculate songIndex based on songName
    songIndex = quizModel.songs.indexWhere((song) => song.name == widget.songName);

    // Connections
    metronome.beatSignal.listen((currCount) {
      setState(() {
        count++;
        if (count > 4) {
          count = 1;
        }
      });
    });

    quizModel.correctChordStream.listen((isCorrect) {
      setState(() {
        isCorrectChord = isCorrect;
      });
    });

    metronome.barPublisher.listen((currCount) {
      setState(() {
        _updateQuestionIndex();
      });
    });
  }

@override
Widget build(BuildContext context) {
  // initialize songs before accessing songs
  final chordChanges = quizModel.songs[songIndex].chordChanges; // Use songIndex to get chordChanges
  final chordChange = chordChanges[currentQuestionIndex];

  return Scaffold(
    appBar: AppBar(
      title: Text('Quiz: ${quizModel.songs[songIndex].name}'),
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
        // Positioned Box for the text in the upper left corner
        Positioned(
          top: 20, // Adjust this value to move the text vertically
          left: 10, // Adjust this value to move the text horizontally
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Song Name: ${widget.songName}', style: const TextStyle(color: Colors.black)),
                Text('BPM: ${widget.bpm}', style: const TextStyle(color: Colors.black)),
                Text('Key: ${widget.songKey}', style: const TextStyle(color: Colors.black)),
                Text('Count: $count', style: const TextStyle(color: Colors.black)),
                //Text('Chord: ${currentQuestionIndex + 1}', style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ),

        // Centered column for the buttons
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (currentQuestionIndex < chordChanges.length)
                  for (int index = 0; index < chordChange.targetChordOptions.length; index++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Add spacing between buttons
                      child: SizedBox(
                        width: 200.0, // Hardcoded width for all buttons
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
                                : Color.fromARGB(255, 255, 255, 255),
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            chordChange.targetChordOptions[index],
                            style: const TextStyle(
                              color: Colors.black // Text color for unselected options
                            ),
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
}




  void _updateQuestionIndex() {
  setState(() {
    if (currentQuestionIndex < quizModel.songs[songIndex].chordChanges.length - 1) {
      currentQuestionIndex++;
      metronome.chordDuration = quizModel.songs[songIndex]
        .chordChanges[currentQuestionIndex]
        .durationInBeats;
    } else {
      // Handle the end of the song or loop back to the start
      currentQuestionIndex = 0;  // or handle differently if needed
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
