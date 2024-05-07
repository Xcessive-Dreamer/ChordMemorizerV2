import 'package:flutter/material.dart';
import '../settings/metronome.dart'; // Import your Metronome class

class JazzQuizView extends StatefulWidget {
  final int bpm;
  final String songName;
  final String songKey;

  const JazzQuizView({
    super.key,
    required this.songKey,
    required this.bpm,
    required this.songName,
  });

  @override
  JazzQuizViewState createState() => JazzQuizViewState();
}

class JazzQuizViewState extends State<JazzQuizView> {
  late final Metronome metronome;
  bool isQuizRunning = false;
  int count = 0;
  int chordNum = 1;

  @override
  void initState() {
    super.initState();
    metronome = Metronome(songName: widget.songName, isSongModeP: true, isMetronomeModeP: false, bpmP: widget.bpm);
    metronome.beatSignal.listen((_) {
      setState(() {
        count++;
        if(count > 4) {
          count = 1;
        }
      });
    });

    metronome.barPublisher.listen((_) {
      setState(() {
        chordNum++;
      });
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz View'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('BPM: ${widget.bpm}'),
            Text('Song Name: ${widget.songName}'),
            Text('Key: ${widget.songKey}'),
            Text('Count: $count'),
            Text('Chord: $chordNum'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isQuizRunning = !isQuizRunning;
                  if (isQuizRunning) {
                    metronome.toggleMetronome(widget.bpm);
                  } else {
                    metronome.stop();
                  }
                });
              },
              child: Text(isQuizRunning ? 'Stop Quiz' : 'Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    metronome.stop();
    super.dispose();
  }
}
