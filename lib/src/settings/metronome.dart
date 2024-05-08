import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:rxdart/rxdart.dart';

class Metronome {
  late Timer? metronomeTimer;
  late AudioPlayer audioPlayer;
  late int count;
  late int chordDuration;
  late int bpmField;
  late double delay;
  late double beatsPerMeasure;
  late bool isFirstClick;
  late bool isMetronomeMode;
  late bool isSongMode;
  late bool isFirstBar;
  late bool onAppearFinished;
  late String songName;
  late String soundURL;

  final BehaviorSubject<int> barPublisher = BehaviorSubject<int>();
  final BehaviorSubject<int> beatSignal = BehaviorSubject<int>();

  Metronome({
    String? songName,
    int? bpmP,
    bool isMetronomeModeP = false,
    bool isSongModeP = false,
  })   : songName = songName ?? 'metronome',
        isMetronomeMode = isMetronomeModeP,
        isSongMode = isSongModeP,
        isFirstClick = false,
        isFirstBar = false,
        chordDuration = 4,
        count = 1,
        delay = 1,
        bpmField = bpmP ?? 90,
        beatsPerMeasure = 4,
        onAppearFinished = false,
        audioPlayer = AudioPlayer() {setupAudioPlayer();
        metronomeTimer = Timer(const Duration(seconds: 0), () { });
  }

  void setupAudioPlayer() async {
    try {
      const metronomeURL = 'audio/metronome_click.mp3';
      soundURL = isSongMode ? "audio/$songName.mp3" : metronomeURL;
      //await audioPlayer.setSourceUrl(soundURL.toString());
    } catch (e) {
      throw 'Unable to create audio player.';
    }
  }

  void stop() {
    metronomeTimer?.cancel();
    audioPlayer.stop();
    count = 1;
  }

  void toggleMetronome(int bpm) {
  if (metronomeTimer?.isActive ?? false) {
    metronomeTimer?.cancel();
    count = 1;
  } else {
    final interval = 60.0 / bpmField;
    delay = interval;
    isFirstBar = true;
    isFirstClick = true;
    if (isSongMode) {
        audioPlayer.play(AssetSource(soundURL));
    }    
    // Add slight delay upon start to better match audio recordings
    
      tick(); // Immediately emit the first tick
      metronomeTimer = Timer.periodic(Duration(milliseconds: (interval * 1000).round()), (timer) {
        tick();
      }); 

  }
}


  void tick() {
  // if it is the first click dont increment count yet.
  if (isFirstClick && isMetronomeMode) {
    beatSignal.add(count);
    isFirstClick = false;
    return;
  }

  if (isSongMode && count == 1 && !isFirstBar) { // Emit a chord signal only on the first beat of the chord
    barPublisher.add(count);
  }
  else if (isFirstBar) {
    isFirstBar = false;
  }

  count++;
  beatSignal.add(count); // Always emit a beat signal

  if (isSongMode && count > chordDuration) {
    count = 1;
  } else if (isMetronomeMode && count > 4) {
    count = 1;
  }
}


  void playOneShot() async {
    try {
      // create strong beat on 1
      if(isMetronomeMode) {
        if (count == 1) {
          audioPlayer.setVolume(15);
          await audioPlayer.play(AssetSource('audio/metronome_click.mp3'));
        } else {
          audioPlayer.setVolume(5);
          await audioPlayer.play(AssetSource('audio/metronome_click.mp3'));
        }
    }
    } catch (e) {
      throw 'Unable to create audio player.';
    }
  }

  Stream<int> subscribeToBarSignal() {
    return barPublisher.stream;
  }

  Stream<int> subscribeToBeatSignal() {
    return beatSignal.stream;
  }
}
