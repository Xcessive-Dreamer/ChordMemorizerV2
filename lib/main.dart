import 'package:flutter/material.dart';
import 'src/pages/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/backend/song_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // To check the platform
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensures Flutter is initialized before async calls

  // ✅ Enable FFI for desktop platforms (Windows, Mac, Linux)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Set up the settings controller
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  // ✅ Ensure database is initialized **before** populating songs
  await DatabaseHelper.instance.database;
  await DatabaseHelper.instance.populateDefaultSongs(await DatabaseHelper.instance.database);

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(MyApp(settingsController: settingsController));
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController;
  
  const MyApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      theme: ThemeData(
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.black),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.black),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
          ),
        ),
      ),
      home: ContentView(settingsController: settingsController),
    );
  }
}
