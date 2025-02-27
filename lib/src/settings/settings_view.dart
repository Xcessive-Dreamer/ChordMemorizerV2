// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../backend/song_db.dart'; // Import the DatabaseHelper
import 'settings_controller.dart';
import 'dart:developer';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Selector
            DropdownButton<ThemeMode>(
              value: controller.themeMode,
              onChanged: controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Theme'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Reload Database Button
            ElevatedButton.icon(
              onPressed: () async {
                await _reloadDatabase(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reload Database'),
            ),
          ],
        ),
      ),
    );
  }

  /// Function to reload the database when the button is pressed
  Future<void> _reloadDatabase(BuildContext context) async {
    try {
      log("♻️ Reloading database...");

      await DatabaseHelper.instance.deleteAll();
      await DatabaseHelper.instance.populateDefaultSongs(await DatabaseHelper.instance.database);

      debugPrint("✅ Database reloaded successfully!");

      // Show confirmation in UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database reloaded successfully!')),
      );
    } catch (e) {
      debugPrint("❌ Error reloading database: $e");

      // Show error in UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
