import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/services/firestore_service.dart';

class ManageExercisesView extends StatefulWidget {
  final FirestoreService firestoreService;

  const ManageExercisesView({super.key, required this.firestoreService});

  @override
  State<ManageExercisesView> createState() => _ManageExercisesViewState();
}

class _ManageExercisesViewState extends State<ManageExercisesView> {
  FirestoreService get _firestoreService => widget.firestoreService;

  void _showAddExerciseDialog() {
    final nameController = TextEditingController();
    ExerciseType selectedType = ExerciseType.repetitions;
    ExerciseCategory selectedCategory = ExerciseCategory.other;
    final incrementsController1 = TextEditingController(text: '5');
    final incrementsController2 = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExerciseType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ExerciseType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExerciseCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ExerciseCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Increments (for quick add buttons)'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: incrementsController1,
                        decoration: const InputDecoration(labelText: 'Small'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: incrementsController2,
                        decoration: const InputDecoration(labelText: 'Large'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final inc1 = int.tryParse(incrementsController1.text) ?? 5;
                  final inc2 = int.tryParse(incrementsController2.text) ?? 10;

                  await _firestoreService.addExercise(Exercise(
                    id: '',
                    name: nameController.text,
                    type: selectedType,
                    category: selectedCategory,
                    increments: [inc1, inc2],
                  ));
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExerciseDialog,
        child: const ThemedIcon(Symbols.add_rounded),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Manage Exercises'),
          ),
          StreamBuilder<List<Exercise>>(
            stream: _firestoreService.exerciseStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No exercises found'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await _firestoreService.importDefaultExercises();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Default exercises imported')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error importing: $e')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Symbols.download_rounded),
                          label: const Text('Import Default Exercises'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final exercises = snapshot.data!;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = exercises[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(exercise.name[0].toUpperCase()),
                      ),
                      title: Text(exercise.name),
                      subtitle: Text(
                          '${exercise.category.name} • ${exercise.type.name}'),
                      trailing: IconButton(
                        icon: const ThemedIcon(Symbols.delete_rounded,
                            color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Exercise'),
                              content: Text(
                                  'Delete ${exercise.name}? This will not affect past workouts.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            try {
                              await _firestoreService.deleteExercise(exercise.id);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    );
                  },
                  childCount: exercises.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
