import 'package:flutter/material.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/routine_icon_pack_icons.dart';

class HomePage extends StatefulWidget {
  final IsarService service;

  const HomePage({super.key, required this.service});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(RoutineIconPack.settings),
                onPressed: () {
                  // Navigate to the settings page using a named route.
                  // Navigator.pushNamed(context, '/settings');
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
