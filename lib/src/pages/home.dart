import 'package:flutter/material.dart';
import 'jazz_page_view.dart';
import 'pop_page_view.dart';
import 'rock_page_view.dart';
import 'country_page_view.dart';
import 'add_own_page_view.dart';
import 'metronome_page_view.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/pages';

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  String selectedGenre = "Jazz";
  List<String> genres = ["Jazz", "Pop", "Rock", "Country"];

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.red : Colors.blue;
      
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
            Text(
              "Welkome To The Chord \n Progression Memorizer, work pls!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: textColor,  // Dynamic text color
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
            Text(
              "The Chord Progression Memorizer empowers you to practice your favorite music anytime, anywhere. \n Select a genre below or add your own changes to get started memorizing songs.",
              style: TextStyle(
                // add if check to check if dark or light mode
                color: textColor,
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
                style: TextStyle(
                  color: textColor,
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
              child:const Text("Add Your Own",
                style: TextStyle(
                  color: Colors.white,
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
              child: Text("Metronome", style: TextStyle(
                color: textColor,
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

