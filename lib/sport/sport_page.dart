import 'package:flutter/material.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/sport/add_sheet.dart';
import 'package:routine/widgets/daily_card_widget.dart';
import 'package:routine/widgets/goal_card_widget.dart';

class SportPage extends StatefulWidget {
  final IsarService service;

  const SportPage({super.key, required this.service});

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  List<String> selecetedExercises = ['pushups', 'pullups'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Sport'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to the settings page using a named route.
                  // Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  GoalCardWidget(title: 'Active Goal'),
                  StreamBuilder(
                      stream: widget.service.exerciseStream(),
                      builder: (context, snapshot) =>
                          const DailyCardWidget(title: 'Today')),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AddSheet(service: widget.service),
    );
  }
}
