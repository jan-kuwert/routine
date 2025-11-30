import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/services/firestore_service.dart';

class ExerciseSelectionView extends StatefulWidget {
  const ExerciseSelectionView({super.key});
  static const routeName = '/exercise-selection';

  @override
  State<ExerciseSelectionView> createState() => _ExerciseSelectionViewState();
}

class _ExerciseSelectionViewState extends State<ExerciseSelectionView> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Exercise> _availableExercises = [];
  final Set<String> _selectedExerciseNames = {};
  bool _isLoading = true;
  bool _isSaving = false;

  Map<ExerciseCategory, List<Exercise>> _groupedExercises = {};

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/exercises.json');
      final dynamic decoded = json.decode(jsonString);
      final List<Exercise> exercises = [];

      for (var i = 0; i < decoded.length; i++) {
        if (decoded[i] is Map) {
          exercises.add(Exercise(
            id: '', // Placeholder
            name: decoded[i]['name'] as String,
            category: ExerciseCategory.values.firstWhere(
              (category) =>
                  category.name.toLowerCase() ==
                  decoded[i]['category'].toString().toLowerCase(),
              orElse: () => ExerciseCategory.other,
            ),
            type: ExerciseType.values.firstWhere(
              (type) =>
                  type.name.toLowerCase() ==
                  decoded[i]['type'].toString().toLowerCase(),
              orElse: () => ExerciseType.repetitions,
            ),
            increments: decoded[i].containsKey('increments') &&
                    decoded[i]['increments'] is List &&
                    decoded[i]['increments'].length >= 2
                ? [
                    decoded[i]['increments'][0] as int,
                    decoded[i]['increments'][1] as int
                  ]
                : [],
          ));
        }
      }

      // Group exercises by category
      final grouped = <ExerciseCategory, List<Exercise>>{};
      for (var exercise in exercises) {
        if (!grouped.containsKey(exercise.category)) {
          grouped[exercise.category] = [];
        }
        grouped[exercise.category]!.add(exercise);
      }

      if (mounted) {
        setState(() {
          _availableExercises = exercises;
          _groupedExercises = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading exercises: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleContinue() async {
    setState(() {
      _isSaving = true;
    });

    try {
      for (var exercise in _availableExercises) {
        if (_selectedExerciseNames.contains(exercise.name)) {
          await _firestoreService.addExercise(exercise);
        }
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (route) => false);
      }
    } catch (e) {
      debugPrint('Error saving exercises: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving exercises: $e')),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _handleSkip() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercises'),
        actions: [
          TextButton(
            onPressed: _handleSkip,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Choose the exercises you want to include in your routine. You can add more later in settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _groupedExercises.length,
                    itemBuilder: (context, index) {
                      final category = _groupedExercises.keys.elementAt(index);
                      final exercises = _groupedExercises[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              category.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: exercises.map((exercise) {
                              final isSelected =
                                  _selectedExerciseNames.contains(exercise.name);
                              return FilterChip(
                                label: Text(exercise.name),
                                selected: isSelected,
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedExerciseNames.add(exercise.name);
                                    } else {
                                      _selectedExerciseNames.remove(exercise.name);
                                    }
                                  });
                                },
                                showCheckmark: false,
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                      : null,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : null,
                                ),
                                side: isSelected
                                    ? BorderSide.none
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8.0),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FilledButton(
                    onPressed: _isSaving || _selectedExerciseNames.isEmpty
                        ? null
                        : _handleContinue,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Add ${_selectedExerciseNames.length} Exercises'),
                  ),
                ),
              ],
            ),
    );
  }
}

