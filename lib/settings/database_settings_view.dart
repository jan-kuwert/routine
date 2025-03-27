import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/settings/settings_controller.dart';
import 'package:routine/sport/create_exercise_dialog.dart';

class DatabaseSettingsView extends StatelessWidget {
  DatabaseSettingsView({super.key, required this.controller});

  final SettingsController controller;
  final service = IsarService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Database'),
          ),
          SliverToBoxAdapter(
            child: Center(
                child: CreateExerciseDialog(
              service: service,
            )),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16),
              child: TextButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                  minimumSize: const Size(double.infinity, 50),
                ),
                label: const Text('Delete all Data'),
                onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Delete all Data'),
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
                icon: const MaterialSymbolsTheme(
                    fill: 1, child: ThemedIcon(Symbols.skull_rounded)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
