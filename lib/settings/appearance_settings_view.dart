import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/settings/color_option.dart';
import 'package:routine/settings/settings_controller.dart';

class AppearanceSettingsView extends StatelessWidget {
  AppearanceSettingsView({super.key, required this.controller});

  final SettingsController controller;
  final service = IsarService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Appearance'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () {
                  // Store the current theme mode to restore if cancelled
                  ThemeMode initialThemeMode = controller.themeMode;
                  // Temporary theme mode that will be used until saved
                  ThemeMode tempThemeMode = controller.themeMode;

                  showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) => AlertDialog(
                        title: const Text('Select Theme'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Radio<ThemeMode>(
                                value: ThemeMode.system,
                                groupValue: tempThemeMode,
                                onChanged: (value) {
                                  setState(() {
                                    tempThemeMode = ThemeMode.system;
                                  });
                                },
                              ),
                              title: const Text('System Theme'),
                              onTap: () {
                                setState(() {
                                  tempThemeMode = ThemeMode.system;
                                });
                              },
                            ),
                            ListTile(
                              leading: Radio<ThemeMode>(
                                value: ThemeMode.light,
                                groupValue: tempThemeMode,
                                onChanged: (value) {
                                  setState(() {
                                    tempThemeMode = ThemeMode.light;
                                  });
                                },
                              ),
                              title: const Text('Light Theme'),
                              onTap: () {
                                setState(() {
                                  tempThemeMode = ThemeMode.light;
                                });
                              },
                            ),
                            ListTile(
                              leading: Radio<ThemeMode>(
                                value: ThemeMode.dark,
                                groupValue: tempThemeMode,
                                onChanged: (value) {
                                  setState(() {
                                    tempThemeMode = ThemeMode.dark;
                                  });
                                },
                              ),
                              title: const Text('Dark Theme'),
                              onTap: () {
                                setState(() {
                                  tempThemeMode = ThemeMode.dark;
                                });
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Restore original theme and close dialog
                              controller.updateThemeMode(initialThemeMode);
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Save the selected theme
                              controller.updateThemeMode(tempThemeMode);
                              Navigator.pop(context);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const ThemedIcon(Symbols.brightness_6_rounded),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.themeMode == ThemeMode.system
                                  ? 'System Theme'
                                  : controller.themeMode == ThemeMode.light
                                      ? 'Light Theme'
                                      : 'Dark Theme',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () {
                  // Store initial color to restore if cancelled
                  Color initialSeedColor = controller.colorSchemeSeed;
                  // Temporary color that will be used until saved
                  Color tempSeedColor = controller.colorSchemeSeed;

                  showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) => AlertDialog(
                        title: const Text('Select Theme Color'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 4,
                            mainAxisSpacing: 32,
                            crossAxisSpacing: 16,
                            children: [
                              ColorOption(
                                color: Colors.pink,
                                isSelected: tempSeedColor == Colors.pink,
                                onTap: () =>
                                    setState(() => tempSeedColor = Colors.pink),
                              ),
                              ColorOption(
                                color: Colors.deepPurple,
                                isSelected: tempSeedColor == Colors.deepPurple,
                                onTap: () => setState(
                                    () => tempSeedColor = Colors.deepPurple),
                              ),
                              ColorOption(
                                color: Colors.lightBlue,
                                isSelected: tempSeedColor == Colors.lightBlue,
                                onTap: () => setState(
                                    () => tempSeedColor = Colors.lightBlue),
                              ),
                              ColorOption(
                                color: Colors.teal,
                                isSelected: tempSeedColor == Colors.teal,
                                onTap: () =>
                                    setState(() => tempSeedColor = Colors.teal),
                              ),
                              ColorOption(
                                color: Colors.lime,
                                isSelected: tempSeedColor == Colors.lime,
                                onTap: () =>
                                    setState(() => tempSeedColor = Colors.lime),
                              ),
                              ColorOption(
                                color: Colors.amber,
                                isSelected: tempSeedColor == Colors.amber,
                                onTap: () => setState(
                                    () => tempSeedColor = Colors.amber),
                              ),
                              ColorOption(
                                color: Colors.deepOrange,
                                isSelected: tempSeedColor == Colors.deepOrange,
                                onTap: () => setState(
                                    () => tempSeedColor = Colors.deepOrange),
                              ),
                              ColorOption(
                                color: Colors.blueGrey,
                                isSelected: tempSeedColor == Colors.blueGrey,
                                onTap: () => setState(
                                    () => tempSeedColor = Colors.blueGrey),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Restore original color and close dialog
                              controller
                                  .updateColorSchemeSeed(initialSeedColor);
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Save the selected color
                              controller.updateColorSchemeSeed(tempSeedColor);
                              Navigator.pop(context);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ThemedIcon(Symbols.format_paint_rounded),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme Color',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Customize app accent color',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
