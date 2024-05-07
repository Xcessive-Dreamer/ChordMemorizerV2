import 'package:flutter/material.dart';
import 'jazz_page_view.dart';
import 'pop_page_view.dart';
import 'rock_page_view.dart';
import 'country_page_view.dart';
import 'add_own_page_view.dart';
import 'metronome_page_view.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  static const routeName = '/pages';

  @override
  ContentViewState createState() => ContentViewState();
}

class ContentViewState extends State<ContentView> {
  String selectedGenre = "Jazz";
  List<String> genres = ["Jazz", "Pop", "Rock", "Country"];

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 168, 253, 249),
      appBar: AppBar(
        title: const Text("Xcessive-Music"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Welcome To The Chord \n Progression Memorizer!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
            const Text(
              "The Chord Progression Memorizer empowers you to practice your favorite music anytime, anywhere. Select a genre below or add your own changes to get started memorizing songs.",
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
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
                  label: const Text("Genre Select"),
                  width: 200,
                  onSelected: (String? newValue) {
                    setState(() {
                      selectedGenre = newValue!;
                      
                    });
                  },
                  dropdownMenuEntries: genres.map((genre) {
                    return DropdownMenuEntry(value: genre, label: genre);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                navigateToGenrePage(selectedGenre);
              },
              child: Text(
                "Go to $selectedGenre",
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  // Add more properties as needed
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddOwnPageView()),
                );
              },
              child: const Text("Add Your Own",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MetronomePageView()),
                );
              },
              child: const Text("Metronome", style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToGenrePage(String genre) {
    switch (genre) {
      case "Jazz":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JazzPageView()),
        );
        break;
      case "Pop":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PopPageView()),
        );
        break;
      case "Rock":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RockPageView()),
        );
        break;
      case "Country":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CountryPageView()),
        );
        break;
      default:
        break;
    }
  }
}

