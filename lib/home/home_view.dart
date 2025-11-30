import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/home/sport_summary_card.dart';
import 'package:routine/services/firestore_service.dart';

import '../settings/settings_view.dart';

class HomeView extends StatefulWidget {
  final FirestoreService firestoreService;
  final VoidCallback? onNavigateToSport;

  const HomeView({
    super.key,
    required this.firestoreService,
    this.onNavigateToSport,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  FirestoreService get firestoreService => widget.firestoreService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: FutureBuilder<String?>(
              future:
                  Future.value(FirebaseAuth.instance.currentUser?.displayName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                return Text('Hi, ${snapshot.data ?? 'Welcome back'}');
              },
            ),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SportSummaryCard(
                      firestoreService: widget.firestoreService,
                      onTap: widget.onNavigateToSport,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    // Placeholder for Todo card
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
