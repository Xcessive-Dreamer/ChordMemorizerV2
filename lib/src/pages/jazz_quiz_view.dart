import 'package:flutter/material.dart';
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
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('BPM: ${widget.bpm}'),
            const SizedBox(height: 20),
            Text('Song Name: ${widget.songName}'),
            const SizedBox(height: 20),
            Text('Key: ${widget.songKey}'),
            const SizedBox(height: 20),
            Text('Count: $count'),
            const SizedBox(height: 20),
            Text('Chord: ${currentQuestionIndex + 1}'),
            const SizedBox(height: 20),
            if (currentQuestionIndex < chordChanges.length) // Check if currentQuestionIndex is within range
              for (int index = 0; index < chordChange.targetChordOptions.length; index++)
                ElevatedButton(
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
                    backgroundColor: selectedChordIndex == index ? (isCorrectChord ? Colors.green : Colors.red) : Colors.black,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(chordChange.targetChordOptions[index]),
                ),
          ],
        ),
      ),
    ),
  );
}



  void _updateQuestionIndex() {
    setState(() {
      currentQuestionIndex++;
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
