import 'package:flutter/material.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/sport/create_exercise_dialog.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  SettingsView({super.key, required this.controller});

  static const routeName = '/settings';
  final service = IsarService();
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Settings'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              // When a user selects a theme from the dropdown list, the
              // SettingsController is updated, which rebuilds the MaterialApp.
              child: Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.only(left: 8.0),
                child: DropdownButton<ThemeMode>(
                  // Read the selected themeMode from the controller
                  value: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                  dropdownColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8.0),
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  underline: Container(), // This removes the underline
                  items: [
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
                    )
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
                child: CreateExerciseDialog(
              service: service,
            )),
          ),
          SliverToBoxAdapter(
            child: TextButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.error),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              label: const Text('Clear Database'),
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Clear Database'),
                  content: const Text(
                    'This will PERMANENTLY delete all your data. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // service.cleanDb();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Database cleared')),
                        );
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Symbols.skull),
            ),
          )
        ],
      ),
    );
  }
}
