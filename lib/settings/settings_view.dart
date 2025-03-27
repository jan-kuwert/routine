import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/settings/appearance_settings_view.dart';
import 'package:routine/settings/database_settings_view.dart';

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DatabaseSettingsView(
                          controller: controller,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: ThemedIcon(Symbols.person_rounded),
                    title: Text('Account'),
                    trailing: ThemedIcon(
                      Symbols.chevron_right_rounded,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AppearanceSettingsView(controller: controller),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: ThemedIcon(Symbols.palette_rounded),
                    title: Text('Apperance'),
                    trailing: ThemedIcon(
                      Symbols.chevron_right_rounded,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DatabaseSettingsView(
                          controller: controller,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: ThemedIcon(Symbols.database_rounded),
                    title: Text('Data'),
                    trailing: ThemedIcon(
                      Symbols.chevron_right_rounded,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 32.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Implement logout functionality
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pop(context);
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (route) => false);
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Symbols.logout_rounded),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
