import 'package:flutter/material.dart';
import '../settings/metronome.dart'; // Import your Metronome class

class MetronomePageView extends StatefulWidget {
  const MetronomePageView({super.key});

  @override
  MetronomePageViewState createState() => MetronomePageViewState();
}

class MetronomePageViewState extends State<MetronomePageView> {
  late Metronome metronome;
  int bpm = 120;
  bool isMetronomeOn = false;
  int count = 0;

@override
void initState() {
  super.initState();
  metronome = Metronome(bpmP: bpm, isMetronomeModeP: true, isSongModeP: false);
  metronome.barPublisher.listen((currCount) {
    setState(() {
      count++;
      if(metronome.isMetronomeMode) {
        metronome.playOneShot();
      }
    });
  });

  // Subscribe to the barPublisher here
  final subscription = metronome.subscribeToBeatSignal();
  subscription.listen((currCount) {
    // tick for each signal sent
    setState(() {
      count++;
      metronome.playOneShot();
    });
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metronome Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('BPM: $bpm'),
            Slider(
              min: 50,
              max: 240,
              value: bpm.toDouble(),
              onChanged: (value) {
                metronome.stop(); // turn off metronome when updating tempo
                isMetronomeOn = false;
                setState(() {
                  bpm = value.toInt(); // Update local bpm variable
                  metronome.bpmField = bpm; // Update metronome's bpmField
                  if (isMetronomeOn) {
                    metronome.toggleMetronome(bpm); // Restart metronome with new BPM
                  }
                });
              },
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  isMetronomeOn = !isMetronomeOn;
                  if (isMetronomeOn) {
                    metronome.toggleMetronome(bpm);
                  } else {
                    metronome.stop();
                  }
                });
              },
              child: Text(isMetronomeOn ? 'Stop Metronome' : 'Start Metronome'),
            ),
            Text(metronome.count.toString()),
          ],
        ),
      ),
    );
  }
}
