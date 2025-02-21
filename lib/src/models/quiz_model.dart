import 'dart:math';
import 'dart:async';

class QuizModel {
  late final bool isSharpKey;
  late final bool isFlatKey;

  List<Song> songs = [];

  /// Transposes a song into the selected key while keeping the beat duration
  /// and song name intact. Also generates 3 random chord options plus the correct one.
  Song transposeSong(String originalKey, String selectedKey, Song song) {
    // Define note sets
    List<String> sharps = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    List<String> flats = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

    // Map enharmonic equivalents between sharp and flat notes
    Map<String, String> enharmonics = {
      'C#': 'Db',
      'D#': 'Eb',
      'F#': 'Gb',
      'G#': 'Ab',
      'A#': 'Bb',
      'Db': 'C#',
      'Eb': 'D#',
      'Gb': 'F#',
      'Ab': 'G#',
      'Bb': 'A#'
    };

    // Determine whether to use sharps or flats
    List<String> noteSet = isSharpKey ? sharps : flats;

    // Find the index of the selected key in the appropriate note set
    int newKeyIndex = noteSet.indexOf(selectedKey);
    int origKeyIndex = noteSet.indexOf(originalKey);

    // Handle sharp to flat transition using enharmonic equivalents
    if (isSharpKey && flats.contains(selectedKey)) {
      selectedKey = enharmonics[selectedKey] ?? selectedKey;
      newKeyIndex = sharps.indexOf(selectedKey);
    } else if (isFlatKey && sharps.contains(selectedKey)) {
      selectedKey = enharmonics[selectedKey] ?? selectedKey;
      newKeyIndex = flats.indexOf(selectedKey);
    }

    if (newKeyIndex == -1) {
      throw ArgumentError('Selected key $selectedKey is not in the note set');
    }

    int semitoneDiff = newKeyIndex - origKeyIndex;

    // Transpose the song and generate random chord options
    List<ChordChange> transposedChordChanges = [];

    for (var chordChange in song.chordChanges) {
      String originalChord = chordChange.originalChord;

      // Extract root note and chord quality
      String rootNote = originalChord.length > 1 && (originalChord[1] == '#' || originalChord[1] == 'b')
          ? originalChord.substring(0, 2)
          : originalChord[0];
      String chordQuality = originalChord.substring(rootNote.length);

      // Check for enharmonic equivalents
      if (isSharpKey && flats.contains(rootNote)) {
        rootNote = enharmonics[rootNote] ?? rootNote;
      } else if (isFlatKey && sharps.contains(rootNote)) {
        rootNote = enharmonics[rootNote] ?? rootNote;
      }

      int index = noteSet.indexOf(rootNote);

      if (index != -1) {
        // Transpose the root note and append the original chord quality
        String transposedChord = noteSet[(index + semitoneDiff) % noteSet.length] + chordQuality;

        // Generate 3 random chords and shuffle the options
        List<String> chordOptions = generateChordOptions(transposedChord);

        // Create a new ChordChange with transposed chord and shuffled options
        ChordChange transposedChange = ChordChange(
          transposedChord,  // The correct transposed chord
          chordOptions,  // Random options including the correct chord
          chordChange.durationInBeats  // Keep the same beat duration
        );

        transposedChordChanges.add(transposedChange);
      }
    }

    // Return the new Song with transposed chords and the same name
    return Song(song.name, transposedChordChanges);
  }

  /// Generates 3 random chord options and includes the correct transposed chord as the fourth.
  List<String> generateChordOptions(String correctChord) {
    List<String> sharps = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    List<String> flats = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];
    List<String> chordQualities = ['m7', 'maj7', 'dim7', '7', 'm7b5'];

    Random random = Random();

    // Create a set for unique random chords
    Set<String> randomChords = {};

    // Generate 3 random chords
    while (randomChords.length < 3) {
      int randNum = random.nextInt(2); // 0 for sharp, 1 for flat
      String rootNote = randNum == 0
          ? sharps[random.nextInt(sharps.length)]
          : flats[random.nextInt(flats.length)];
      String chordQuality = chordQualities[random.nextInt(chordQualities.length)];
      randomChords.add('$rootNote$chordQuality');
    }

    // Convert set to list and add the correct chord
    List<String> chordOptions = randomChords.toList();
    chordOptions.add(correctChord);

    // Shuffle the options
    chordOptions.shuffle();

    return chordOptions;
  }

  /// Initialize the song list after instance creation
  void initializeSongs() {
    songs = [
    Song("Autumn Leaves", [
  // A section
  ChordChange("Am7", generateChordOptions("Am7"), 4),
  ChordChange("D7", generateChordOptions("D7"), 4),
  ChordChange("GMaj7", generateChordOptions("GMaj7"), 4),
  ChordChange("CMaj7", generateChordOptions("CMaj7"), 4),
  ChordChange("F#m7b5", generateChordOptions("F#m7b5"), 4),
  ChordChange("B7", generateChordOptions("B7"), 4),
  ChordChange("Em", generateChordOptions("Em"), 4),
  ChordChange("Em", generateChordOptions("Em"), 4),
  // repeat
  ChordChange("Am7", generateChordOptions("Am7"), 4),
  ChordChange("D7", generateChordOptions("D7"), 4),
  ChordChange("GMaj7", generateChordOptions("GMaj7"), 4),
  ChordChange("CMaj7", generateChordOptions("CMaj7"), 4),
  ChordChange("F#m7b5", generateChordOptions("F#m7b5"), 4),
  ChordChange("B7", generateChordOptions("B7"), 4),
  ChordChange("Em", generateChordOptions("Em"), 4),
  ChordChange("Em", generateChordOptions("Em"), 4),
  // B section
  ChordChange("F#m7b5", generateChordOptions("F#m7b5"), 4),
  ChordChange("B7b9", generateChordOptions("B7b9"), 4),
  ChordChange("Em", generateChordOptions("Em"), 4),
  ChordChange("Em", generateChordOptions("Em"), 4),
  ChordChange("Am7", generateChordOptions("Am7"), 4),
  ChordChange("D7", generateChordOptions("D7"), 4),
  ChordChange("GMaj7", generateChordOptions("GMaj7"), 4),
  ChordChange("GMaj7", generateChordOptions("GMaj7"), 4),
  ChordChange("F#m7b5", generateChordOptions("F#m7b5"), 4),
  ChordChange("B7b9", generateChordOptions("B7b9"), 4),
  ChordChange("Em7", generateChordOptions("Em7"), 2),
  ChordChange("Eb7", generateChordOptions("Eb7"), 2),
  ChordChange("Dm7", generateChordOptions("Dm7"), 2),
  ChordChange("Db7", generateChordOptions("Db7"), 2),
  ChordChange("CMaj7", generateChordOptions("CMaj7"), 4),
  ChordChange("B7b9", generateChordOptions("B7b9"), 4),
  ChordChange("Em", generateChordOptions("Em"), 4),
  ChordChange("Em", generateChordOptions("Em"), 4),
]),

Song("Misty", [
  // A section
  ChordChange("EbMaj7", generateChordOptions("EbMaj7"), 4),
  ChordChange("Bbm7", generateChordOptions("Bbm7"), 2),
  ChordChange("Eb7", generateChordOptions("Eb7"), 2),
  ChordChange("AbMaj7", generateChordOptions("AbMaj7"), 4),
  ChordChange("Abm7", generateChordOptions("Abm7"), 2),
  ChordChange("Db7", generateChordOptions("Db7"), 2),
  ChordChange("EMaj7", generateChordOptions("EMaj7"), 2),
  ChordChange("Cm7", generateChordOptions("Cm7"), 2),
  ChordChange("Fm7", generateChordOptions("Fm7"), 2),
  ChordChange("Bb7", generateChordOptions("Bb7"), 2),
  // first ending A section
  ChordChange("Gm7", generateChordOptions("Gm7"), 2),
  ChordChange("C7", generateChordOptions("C7"), 2),
  ChordChange("Fm7", generateChordOptions("Fm7"), 2),
  ChordChange("Bb7", generateChordOptions("Bb7"), 2),
  // repeat A section
  ChordChange("EbMaj7", generateChordOptions("EbMaj7"), 4),
  ChordChange("Bbm7", generateChordOptions("Bbm7"), 4),
  ChordChange("Eb7", generateChordOptions("Eb7"), 4),
  ChordChange("AbMaj7", generateChordOptions("AbMaj7"), 4),
  ChordChange("Abm7", generateChordOptions("Abm7"), 4),
  ChordChange("Db7", generateChordOptions("Db7"), 4),
  ChordChange("EMaj7", generateChordOptions("EMaj7"), 4),
  ChordChange("Cm7", generateChordOptions("Cm7"), 4),
  ChordChange("Fm7", generateChordOptions("Fm7"), 4),
  ChordChange("Bb7", generateChordOptions("Bb7"), 4),
  // second ending A section
  ChordChange("Eb6", generateChordOptions("Eb6"), 4),
  ChordChange("Eb6", generateChordOptions("Eb6"), 4),
  // B section
  ChordChange("Bbm7", generateChordOptions("Bbm7"), 4),
  ChordChange("E7b9", generateChordOptions("E7b9"), 4),
  ChordChange("AbMaj7", generateChordOptions("AbMaj7"), 4),
  ChordChange("AbMaj7", generateChordOptions("AbMaj7"), 4),
  ChordChange("Am7", generateChordOptions("Am7"), 4),
  ChordChange("D7", generateChordOptions("D7"), 2),
  ChordChange("F7", generateChordOptions("F7"), 2),
  ChordChange("Gm7b5", generateChordOptions("Gm7b5"), 2),
  ChordChange("C7b9", generateChordOptions("C7b9"), 2),
  ChordChange("Fm7", generateChordOptions("Fm7"), 2),
  ChordChange("Bb7", generateChordOptions("Bb7"), 2),
  // ending
  ChordChange("Eb6", generateChordOptions("Eb6"), 4),
  ChordChange("Fm7", generateChordOptions("Fm7"), 2),
  ChordChange("Bb7", generateChordOptions("Bb7"), 2),
]),

Song("1-6-2-5-1", [
  ChordChange("CMaj7", generateChordOptions("CMaj7"), 4),
  ChordChange("Am7", generateChordOptions("Am7"), 2),
  ChordChange("Dm7", generateChordOptions("Dm7"), 2),
  ChordChange("G7", generateChordOptions("G7"), 4),
  ChordChange("CMaj7", generateChordOptions("CMaj7"), 2),
]),
];
}

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
