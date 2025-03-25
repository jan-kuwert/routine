import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/isar_service.dart';

import '../settings/settings_view.dart';

class HomePage extends StatefulWidget {
  final IsarService service;

  const HomePage({super.key, required this.service});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = IsarService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const ThemedIcon(Symbols.settings_rounded),
                onPressed: () {
                  // Navigate to the settings page using a named route.
                  Navigator.restorablePushNamed(
                      context, SettingsView.routeName);
                },
              ),
            ],
          ),
          const SliverToBoxAdapter(
            child: Center(
              child: Text('Home Page'),
            ),
          ),
        ],
      ),
    );
  }
}
