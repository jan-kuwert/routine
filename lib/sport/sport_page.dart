import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:routine/components/daily_card.dart';
import 'package:routine/components/goal_card.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/routine_icon_pack_icons.dart';
import 'package:routine/sport/add_sheet.dart';

class SportPage extends StatefulWidget {
  final IsarService service;

  const SportPage({super.key, required this.service});

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();

  final String jsonPath = 'assets/exercises.json';
  late Map<String, dynamic> exercises = {};

  Future<void> addExercisesFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/exercises.json');
      final dynamic decoded = json.decode(jsonString);
      for (var i = 0; i < decoded.length; i++) {
        if (decoded[i] is Map) {
          widget.service.addExercise(Exercise()
            ..name = decoded[i]['name'] as String
            ..category = ExerciseCategory.values.firstWhere(
              (category) =>
                  category.name ==
                  decoded[i]['category'].toString().toLowerCase(),
              orElse: () => ExerciseCategory.other,
            )
            ..type = ExerciseType.values.firstWhere(
              (type) =>
                  type.name == decoded[i]['type'].toString().toLowerCase(),
              orElse: () => ExerciseType.repititons,
            ));
        }
      }
      debugPrint('Loaded Exercises: $exercises');

      setState(() {
        exercises = exercises;
      });
    } catch (e) {
      debugPrint('Error adding Exercises: $e');

      exercises = {};
    }
  }

  @override
  void initState() {
    super.initState();
    // We need to use Future.delayed because context isn't available immediately in initState
    Future.microtask(() => addExercisesFromJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_fabKey.currentState?.isOpen == true) {
            _fabKey.currentState?.toggle();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Sport'),
              actions: [
                IconButton(
                  icon: const Icon(RoutineIconPack.history),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    GoalCard(title: 'Active Goal'),
                    StreamBuilder(
                        stream: widget.service.exerciseStream(),
                        builder: (context, snapshot) =>
                            const DailyCard(title: 'Today')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: AddSheet(service: widget.service, fabKey: _fabKey),
    );
  }
}
