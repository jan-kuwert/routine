import 'package:flutter/material.dart';
import 'package:routine/routine_font_icons.dart';
import 'package:routine/widgets/daily_card_widget.dart';
import 'package:routine/widgets/goal_card_widget.dart';

class SportPage extends StatefulWidget {
  const SportPage({super.key});

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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  GoalCardWidget(title: 'Active Goal'),
                  DailyCardWidget(title: 'Today')
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        tooltip: 'Increment',
        child: const Icon(RoutineFont.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
