import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import 'jazz_page_view.dart';
import 'pop_page_view.dart';
import 'rock_page_view.dart';
import 'country_page_view.dart';
import 'add_own_page_view.dart';
import 'metronome_page_view.dart';

class ContentView extends StatelessWidget {
  const ContentView({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          initialRoute: routeName,
          routes: {
            routeName: (context) => Scaffold(
              backgroundColor: const Color.fromARGB(255, 168, 253, 249),
              appBar: AppBar(
                title: const Text("Xcessive-Music"),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SettingsView.routeName);
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              body: const ContentViewBody(),
            ),
            SettingsView.routeName: (context) =>
                SettingsView(controller: settingsController),
          },
        );
      },
    );
  }
}

class ContentViewBody extends StatefulWidget {
  const ContentViewBody({super.key});

  @override
  ContentViewBodyState createState() => ContentViewBodyState();
}

class ContentViewBodyState extends State<ContentViewBody> {
  String selectedGenre = "Jazz";
  List<String> genres = ["Jazz", "Pop", "Rock", "Country"];

  @override
  Widget build(BuildContext context) {
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
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
            "The Chord Progression Memorizer empowers you to practice your favorite music anytime, anywhere. \n Select a genre below or add your own changes to get started memorizing songs.",
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
                label: const Text(
                  "Genre Select",
                  style: TextStyle(color: Colors.black),  // Hardcode label text color to black
                ),
                width: 200,
                onSelected: (String? newValue) {
                  setState(() {
                    selectedGenre = newValue!;
                  });
                },
                dropdownMenuEntries: genres.map<DropdownMenuEntry<String>>((String genre) {
                  return DropdownMenuEntry<String>(
                    value: genre,
                    label: genre,
                    style: MenuItemButton.styleFrom(
                      foregroundColor: Colors.black,  // Hardcode text color to black
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),  // Add spacing between buttons
            ElevatedButton(
              onPressed: () {
                navigateToGenrePage(selectedGenre);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40), // Button size
                minimumSize: const Size(180, 40), // Set the minimum size for the button
              ),
              child: Text(
                "Go to $selectedGenre",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 10), // Add spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddOwnPageView()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                minimumSize: const Size(180, 40),  // Set the minimum size for the button
              ),
              child: Text(
                "Add Your Own",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 10), 
             // Add spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MetronomePageView()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                minimumSize: const Size(180, 40),  // Set the minimum size for the button
              ),
              child: Text(
                "Metronome",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ]
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
