import 'package:flutter/material.dart';
import 'src/pages/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/backend/song_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // To check the platform

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

  // Run the app
  runApp(ContentView(settingsController: settingsController));
}
