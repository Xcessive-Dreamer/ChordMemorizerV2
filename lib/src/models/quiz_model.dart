import 'dart:async';

class QuizModel {
  final List<Song> songs = [
    Song("Autumn Leaves", [
  // A section
  ChordChange("Am7", List<String>.from(["Am7", "Dm7", "G7", "Cmaj7"])..shuffle(), 4),
  ChordChange("D7", List<String>.from(["G7", "Cmaj7", "D7", "F#m7b5"])..shuffle(), 4),
  ChordChange("GMaj7", List<String>.from(["F#m7b5", "GMaj7", "B7", "Em7"])..shuffle(), 4),
  ChordChange("CMaj7", List<String>.from(["F#m7b5", "B7", "Em7", "CMaj7"])..shuffle(), 4),
  ChordChange("F#m7b5", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 4),
  ChordChange("B7", List<String>.from(["Em7", "Am7", "B7", "D7"])..shuffle(), 4),
  ChordChange("Em", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
  ChordChange("Em", List<String>.from(["Am7", "D7", "Gmaj7", "Em"])..shuffle(), 4),
  // repeat
  ChordChange("Am7", List<String>.from(["Dm7", "G7", "Cmaj7", "Am7"])..shuffle(), 4),
  ChordChange("D7", List<String>.from(["G7", "Cmaj7", "D7", "F#m7b5"])..shuffle(), 4),
  ChordChange("GMaj7", List<String>.from(["GMaj7", "F#m7b5", "B7", "Em7"])..shuffle(), 4),
  ChordChange("CMaj7", List<String>.from(["F#m7b5", "CMaj7", "B7", "Em7"])..shuffle(), 4),
  ChordChange("F#m7b5", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 4),
  ChordChange("B7", List<String>.from(["B7", "Em7", "Am7", "D7"])..shuffle(), 4),
  ChordChange("Em", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
  ChordChange("Em", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
  // B section
  ChordChange("F#m7b5", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 4),
  ChordChange("B7b9", List<String>.from(["B7b9", "Em7", "Am7", "D7"])..shuffle(), 4),
  ChordChange("Em", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
  ChordChange("Em", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
  ChordChange("Am7", List<String>.from(["Am7", "Dm7", "G7", "Cmaj7"])..shuffle(), 4),
  ChordChange("D7", List<String>.from(["D7", "G7", "Cmaj7", "F#m7b5"])..shuffle(), 4),
  ChordChange("GMaj7", List<String>.from(["GMaj7", "Cmaj7", "F#m7b5", "B7"])..shuffle(), 4),
  ChordChange("GMaj7", List<String>.from(["GMaj7", "Cmaj7", "F#m7b5", "B7"])..shuffle(), 4),
  ChordChange("F#m7b5", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 4),
  ChordChange("B7b9", List<String>.from(["B7b9", "Em7", "Am7", "D7"])..shuffle(), 4),
  ChordChange("Em7", List<String>.from(["Em7", "Am7", "D7", "Gmaj7"])..shuffle(), 2),
  ChordChange("Eb7", List<String>.from(["Eb7", "Abmaj7", "Db7", "Gbmaj7"])..shuffle(), 2),
  ChordChange("Dm7", List<String>.from(["Dm7", "G7", "Cmaj7", "F#m7b5"])..shuffle(), 2),
  ChordChange("Db7", List<String>.from(["Db7", "Gb7", "Bmaj7", "E7"])..shuffle(), 2),
  ChordChange("CMaj7", List<String>.from(["CMaj7", "F#m7b5", "B7", "Em7"])..shuffle(), 4),
  ChordChange("B7b9", List<String>.from(["B7b9", "Em7", "Am7", "D7"])..shuffle(), 4),
  ChordChange("Em", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
  ChordChange("Em", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
]),

Song("Misty",[
  // A section
  ChordChange("EMaj7", List<String>.from(["Am7", "Dm7", "G7", "Cmaj7"])..shuffle(), 4),
  ChordChange("Bbm7", List<String>.from(["G7", "Cmaj7", "D7", "F#m7b5"])..shuffle(), 2),
  ChordChange("Eb7", List<String>.from(["F#m7b5", "GMaj7", "B7", "Em7"])..shuffle(), 2),
  ChordChange("AbMaj7", List<String>.from(["F#m7b5", "B7", "Em7", "CMaj7"])..shuffle(), 4),
  ChordChange("Abm7", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 2),
  ChordChange("Db7", List<String>.from(["Em7", "Am7", "B7", "D7"])..shuffle(), 2),
  ChordChange("EMaj7", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 2),
  ChordChange("Cm7", List<String>.from(["Am7", "D7", "Gmaj7", "Em"])..shuffle(), 2),
  ChordChange("Fm7", List<String>.from(["Dm7", "G7", "CMaj7", "Am7"])..shuffle(), 2),
  ChordChange("Bb7", List<String>.from(["G7", "Cmaj7", "D7", "F#m7b5"])..shuffle(), 2),
  // first ending A section
  ChordChange("Gm7", List<String>.from(["GMaj7", "F#m7b5", "B7", "Em7"])..shuffle(), 2),
  ChordChange("C7", List<String>.from(["F#m7b5", "CMaj7", "B7", "Em7"])..shuffle(), 2),
  ChordChange("Fm7", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 2),
  ChordChange("Bb7", List<String>.from(["B7", "Em7", "Am7", "D7"])..shuffle(), 2),
  // repeat A section
  ChordChange("EMaj7", List<String>.from(["Am7", "Dm7", "G7", "Cmaj7"])..shuffle(), 4),
  ChordChange("Bbm7", List<String>.from(["G7", "Cmaj7", "D7", "F#m7b5"])..shuffle(), 4),
  ChordChange("Eb7", List<String>.from(["F#m7b5", "GMaj7", "B7", "Em7"])..shuffle(), 4),
  ChordChange("AbMaj7", List<String>.from(["F#m7b5", "B7", "Em7", "CMaj7"])..shuffle(), 4),
  ChordChange("Abm7", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 4),
  ChordChange("Db7", List<String>.from(["Em7", "Am7", "B7", "D7"])..shuffle(), 4),
  ChordChange("EMaj7", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
  ChordChange("Cm7", List<String>.from(["Am7", "D7", "Gmaj7", "Em"])..shuffle(), 4),
  ChordChange("Fm7", List<String>.from(["Dm7", "G7", "CMaj7", "Am7"])..shuffle(), 4),
  ChordChange("Bb7", List<String>.from(["G7", "Cmaj7", "D7", "F#m7b5"])..shuffle(), 4),
  // second ending A section
  ChordChange("Eb6", List<String>.from(["GMaj7", "F#m7b5", "B7", "Em7"])..shuffle(), 4),
  ChordChange("Eb6", List<String>.from(["GMaj7", "F#m7b5", "B7", "Em7"])..shuffle(), 4),
  // B section
  ChordChange("Bbm7", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 4),
  ChordChange("E7b9", List<String>.from(["B7b9", "Em7", "Am7", "D7"])..shuffle(), 4),
  ChordChange("AbMaj7", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
  ChordChange("AbMaj7", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 4),
  ChordChange("Am7", List<String>.from(["Am7", "Dm7", "G7", "Cmaj7"])..shuffle(), 4),
  ChordChange("D7", List<String>.from(["D7", "G7", "Cmaj7", "F#m7b5"])..shuffle(), 2),
  ChordChange("F7", List<String>.from(["GMaj7", "Cmaj7", "F#m7b5", "B7"])..shuffle(), 2),
  ChordChange("Gm7b5", List<String>.from(["GMaj7", "Cmaj7", "F#m7b5", "B7"])..shuffle(), 2),
  ChordChange("C7b9", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 2),
  ChordChange("Fm7", List<String>.from(["B7b9", "Em7", "Am7", "D7"])..shuffle(), 2),
  ChordChange("Bb7", List<String>.from(["Em7", "Am7", "D7", "Gmaj7"])..shuffle(), 2),
  ChordChange("EMaj7", List<String>.from(["Am7", "Dm7", "G7", "Cmaj7"])..shuffle(), 4),
  ChordChange("Bbm7", List<String>.from(["G7", "Cmaj7", "D7", "F#m7b5"])..shuffle(), 2),
  ChordChange("Eb7", List<String>.from(["F#m7b5", "GMaj7", "B7", "Em7"])..shuffle(), 2),
  ChordChange("AbMaj7", List<String>.from(["F#m7b5", "B7", "Em7", "CMaj7"])..shuffle(), 4),
  ChordChange("Abm7", List<String>.from(["F#m7b5", "B7", "Em7", "Am7"])..shuffle(), 2),
  ChordChange("Db7", List<String>.from(["Em7", "Am7", "B7", "D7"])..shuffle(), 2),
  ChordChange("EMaj7", List<String>.from(["Em", "Am7", "D7", "Gmaj7"])..shuffle(), 2),
  ChordChange("Cm7", List<String>.from(["Am7", "D7", "Gmaj7", "Em"])..shuffle(), 2),
  ChordChange("Fm7", List<String>.from(["Dm7", "G7", "CMaj7", "Am7"])..shuffle(), 2),
  ChordChange("Bb7", List<String>.from(["G7", "Cmaj7", "D7", "F#m7b5"])..shuffle(), 2),
  // ending
  ChordChange("Eb6", List<String>.from(["GMaj7", "F#m7b5", "B7", "Em7"])..shuffle(), 4),
  ChordChange("Fm7", List<String>.from(["GMaj7", "F#m7b5", "B7", "Em7"])..shuffle(), 2),
  ChordChange("Bb7", List<String>.from(["GMaj7", "F#m7b5", "B7", "Em7"])..shuffle(), 2),
]),
Song("1-6-2-5-1",[
  ChordChange("CMaj7", List<String>.from(["F#m7b5", "B7", "Em7", "CMaj7"])..shuffle(), 4),
  ChordChange("Am7", List<String>.from(["Dm7", "G7", "Cmaj7", "Am7"])..shuffle(), 2),
  ChordChange("Dm7", List<String>.from(["Dm7", "G7", "Cmaj7", "F#m7b5"])..shuffle(), 2),
  ChordChange("G7", List<String>.from(["Dm7", "G7", "Cmaj7", "F#m7b5"])..shuffle(), 4),
  ChordChange("CMaj7", List<String>.from(["F#m7b5", "G7", "E7", "CMaj7"])..shuffle(), 2),
]),


];

  final StreamController<bool> _correctChordController = StreamController<bool>();
  Stream<bool> get correctChordStream => _correctChordController.stream;
  int correctCount = 0;
  int totalCount = 0;

  void startGame() {
    correctCount = 0;
    totalCount = 0;
  }

  void checkChord(String selectedChord, String originalChord) {
    if (selectedChord == originalChord) {
      _correctChordController.add(true);
      correctCount++;
    } else {
      _correctChordController.add(false);
    }
    totalCount++;
  }

  void dispose() {
    _correctChordController.close();
  }
}

class ChordChange {
  final String originalChord;
  final List<String> targetChordOptions;
  final int durationInBeats;

  ChordChange(this.originalChord, this.targetChordOptions, this.durationInBeats);
}

class Song {
  final String name;
  final List<ChordChange> chordChanges;

  Song(this.name, this.chordChanges);
}

// SMALL MAIN METHOD FOR TESTING
// void main() {
//   QuizModel quizModel = QuizModel();

//   // Example usage:
//   quizModel.startGame();
//   quizModel.checkChord("Am7", "Am7"); // Simulate checking a chord
//   quizModel.checkChord("Dm7", "Am7"); // Simulate checking a chord
//   print("Correct count: ${quizModel.correctCount}, Total count: ${quizModel.totalCount}");

//   // Don't forget to dispose the quizModel when done to release resources
//   quizModel.dispose();
// }
