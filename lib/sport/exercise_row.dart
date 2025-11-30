import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/services/firestore_service.dart';

// Constants for increment calculations
const double _smallIncrementFactor = 0.25;
const double _mediumIncrementFactor = 0.5;

class ExerciseRow extends StatefulWidget {
  final String title; // title of the exercise like 'Pushup'
  final String exerciseName; // exact name for database updates
  final double goal; // the goal of the exercise like '50'reps or '3,0'min
  final Function(double)
      onProgressChange; // callback to update the progress in parent
  final double counter; // the current value of the exercise
  final String workoutId; // the id of the workout
  final List<int> increments; // value of increment buttons like [5, 10]
  final bool active; // whether the exercise is interactive or not
  final String unit; // unit of the exercise (e.g. 'min', 'reps')

  const ExerciseRow({
    super.key,
    required this.title,
    required this.exerciseName,
    required this.goal,
    required this.onProgressChange,
    required this.counter,
    required this.workoutId,
    this.increments = const [],
    this.active = false,
    this.unit = '',
  });

  @override
  State<ExerciseRow> createState() => ExerciseRowState();
}

class ExerciseRowState extends State<ExerciseRow> {
  final firestoreService = FirestoreService();
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late double _localCounter;

  List<int>? get increments => widget.increments;
  double get goal => widget.goal;
  String get title => widget.title;
  String get exerciseName => widget.exerciseName;
  String get workoutId => widget.workoutId;
  String get unit => widget.unit;

  void _increment(int increment) async {
    double value = _localCounter + increment;
    _updateCounter(value);
  }

  void _updateCounter(double value) async {
    setState(() {
      _localCounter = value;
      _controller.text = _localCounter.toStringAsFixed(0); // Avoid decimals in text if possible
      widget.onProgressChange(_localCounter / goal > 1.0 ? 1.0 : _localCounter / goal);
      updateWorkoutCounter(_localCounter);
    });
  }

  Future<void> updateWorkoutCounter(double value) async {
    await firestoreService.updateWorkoutCounter(workoutId, exerciseName, value);
  }

  @override
  void initState() {
    super.initState();
    _localCounter = widget.counter;
    // Format initial text to integer string if it's a whole number
    String initialText = _localCounter % 1 == 0 ? _localCounter.toInt().toString() : _localCounter.toString();
    _controller = TextEditingController(text: initialText);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(ExerciseRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.counter != oldWidget.counter && widget.counter != _localCounter) {
       _localCounter = widget.counter;
       String text = _localCounter % 1 == 0 ? _localCounter.toInt().toString() : _localCounter.toString();
       if (_controller.text != text) {
         _controller.text = text;
       }
    }
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
                      '/${goal.toInt()}${unit.isNotEmpty ? ' $unit' : ''} $title',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      softWrap: true,
                    ),
                    if (_localCounter >= goal)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: ThemedIcon(Symbols.check_rounded,
                            color: Colors.green),
                      ),
                  ],
                ),
              ),
              if (unit == 'min')
                OverflowBar(
                  spacing: 4.0,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primaryContainer),
                      ),
                      onPressed: () {
                        _updateCounter(_localCounter + (goal * _mediumIncrementFactor));
                      },
                      child: Text(
                          (goal * _mediumIncrementFactor) % 1 == 0
                              ? '+${(goal * _mediumIncrementFactor).toInt()}'
                              : '+${goal * _mediumIncrementFactor}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    if (_localCounter < goal)
                      IconButton(
                        icon: const ThemedIcon(Symbols.check_rounded),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primaryContainer),
                        ),
                        onPressed: () {
                          _updateCounter(goal);
                        },
                      ),
                  ],
                )
              else
                OverflowBar(
                  spacing: 4.0,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primaryContainer),
                      ),
                      onPressed: () {
                        _increment((goal * _smallIncrementFactor).round());
                      },
                      child: Text('+${(goal * _smallIncrementFactor).round()}'),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primaryContainer),
                      ),
                      onPressed: () {
                        _increment((goal * _mediumIncrementFactor).round());
                      },
                      child: Text('+${(goal * _mediumIncrementFactor).round()}'),
                    ),
                    if (_localCounter < goal)
                      IconButton(
                        icon: const ThemedIcon(Symbols.check_rounded),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primaryContainer),
                        ),
                        onPressed: () {
                          double value = goal - _localCounter;
                          _increment(value.toInt());
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (_localCounter < goal)
          LinearProgressIndicator(
            value: _localCounter / goal,
            minHeight: 7.0,
            borderRadius: BorderRadius.circular(20.0),
          ),
      ],
    );
  }
}
