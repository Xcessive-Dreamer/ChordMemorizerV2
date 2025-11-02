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
import 'user_songs_page_view.dart';
import '../services/firebase_service.dart';

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
          theme: ThemeData(
            dropdownMenuTheme: const DropdownMenuThemeData(
              textStyle: TextStyle(color: Colors.black),
              menuStyle: MenuStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            dropdownMenuTheme: const DropdownMenuThemeData(
              textStyle: TextStyle(color: Colors.black),
              menuStyle: MenuStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
              ),
            ),
          ),
          themeMode: settingsController.themeMode,
          initialRoute: routeName,
          routes: {
            routeName: (context) => Scaffold(
                  backgroundColor: const Color.fromARGB(255, 168, 253, 249),
                  appBar: AppBar(
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.start, // Aligns to left
                      crossAxisAlignment: CrossAxisAlignment.center, // Keeps it vertically centered
                      children: [
                        Text(
                          "Xcessive-Music",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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
  List<String> genres = ["Jazz", "Pop", "Rock", "Country", "User"];
  String displayedText = "";
  final String descriptionText = "Master chord progressions, choose a genre or add your own songs to begin.";
  bool isTypingComplete = false;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  void _startTypingAnimation() async {
    for (int i = 0; i < descriptionText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      setState(() {
        displayedText = descriptionText.substring(0, i + 1);
      });
    }
    setState(() {
      isTypingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.8; // 80% of screen width
    final containerHeight = screenWidth * 0.3; // 30% of screen width for height

    return LayoutBuilder(
      builder: (context, constraints) {
        // Define a minimum screen size.
        const double minWidth = 350;
        const double minHeight = 600;

        return ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: minWidth,
            minHeight: minHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    width: containerWidth,
                    height: containerHeight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome To The Chord\nProgression Memorizer!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              displayedText,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.5,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                // Genre Selection
                Center(
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Select Genre",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownMenu<String>(
                            enableSearch: true,
                            menuHeight: 200,
                            menuStyle: const MenuStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                            ),
                            textStyle: const TextStyle(color: Colors.black),
                            width: 220,
                            hintText: "Genre Select",
                            inputDecorationTheme: const InputDecorationTheme(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            onSelected: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedGenre = newValue;
                                });
                              }
                            },
                            dropdownMenuEntries: genres
                                .where((genre) => genre != "User")
                                .map((genre) => DropdownMenuEntry<String>(
                                      value: genre,
                                      label: genre,
                                      style: const ButtonStyle(
                                        foregroundColor: MaterialStatePropertyAll<Color>(Colors.black),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => navigateToGenrePage(selectedGenre),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Start Practice",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // User Songs Section
                Center(
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Your Songs",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserSongsPageView(),
                                ),
                              );
                            },
                            icon: Icon(Icons.music_note, 
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            label: Text(
                              "View Your Songs",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              foregroundColor: Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Tools Section
                Center(
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Tools",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddYourOwnPage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.add, 
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                label: Text(
                                  "Add Song",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MetronomePageView(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.timer, 
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                label: Text(
                                  "Metronome",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      case "User":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserSongsPageView()),
        );
        break;
      default:
        break;
    }
  }
}