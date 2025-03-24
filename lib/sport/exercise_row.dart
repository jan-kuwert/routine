import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/routine_icon_pack_icons.dart';

class ExerciseRow extends StatefulWidget {
  final String title; // title of the exercise like 'Pushup'
  final double goal; // the goal of the exercise like '50'reps or '3,0'min
  final Function(double)
      onProgressChange; // callback to update the progress in parent
  final double counter; // the current value of the exercise
  final int workoutId; // the id of the workout
  final List<int> increments; // value of increment buttons like [5, 10]
  final bool active; // whether the exercise is interactive or not

  const ExerciseRow({
    super.key,
    required this.title,
    required this.goal,
    required this.onProgressChange,
    required this.counter,
    required this.workoutId,
    this.increments = const [],
    this.active = false,
  });

  @override
  State<ExerciseRow> createState() => ExerciseRowState();
}

class ExerciseRowState extends State<ExerciseRow> {
  final service = IsarService();
  late TextEditingController _controller;
  late FocusNode _focusNode;

  List<int>? get increments => widget.increments;
  double get goal => widget.goal;
  String get title => widget.title;
  double get counter => widget.counter;
  int get workoutId => widget.workoutId;
  set counter(double value) => (value);

  void _increment(int increment) async {
    double value = counter + increment;
    _updateCounter(value);
  }

  void _updateCounter(double value) async {
    setState(() {
      counter = value;
      _controller.text = value.toString();
      widget.onProgressChange(counter / goal > 1.0 ? 1.0 : counter / goal);
      updateWorkoutCounter(value);
    });
  }

  Future<void> updateWorkoutCounter(double value) async {
    service.updateWorkoutCounter(workoutId, title, value);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: counter.toString());
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Form(
                      child: IntrinsicWidth(
                        child: TextFormField(
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          controller: _controller,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _updateCounter(
                                value.isEmpty ? 0 : double.parse(value));
                          },
                        ),
                      ),
                    ),
                    Text(
                      '/${goal.toInt()} $title',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      softWrap: true,
                    ),
                    if (counter >= goal)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(RoutineIconPack.check, color: Colors.green),
                      ),
                  ],
                ),
              ),
              if (increments!.length == 2)
                OverflowBar(
                  spacing: 4.0,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primaryContainer),
                      ),
                      onPressed: () {
                        _increment(increments![0]);
                      },
                      child: Text('+${increments![0]}'),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primaryContainer),
                      ),
                      onPressed: () {
                        _increment(increments![1]);
                      },
                      child: Text('+${increments![1]}'),
                    ),
                    if (counter < goal)
                      IconButton(
                        icon: const Icon(RoutineIconPack.check),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primaryContainer),
                        ),
                        onPressed: () {
                          double value = goal - counter;
                          _increment(value.toInt());
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (counter < goal)
          LinearProgressIndicator(
            value: counter / goal,
            minHeight: 7.0,
            borderRadius: BorderRadius.circular(20.0),
          ),
      ],
    );
  }
}
