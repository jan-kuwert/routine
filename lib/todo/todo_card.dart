import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/todo.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/todo/todo_detail_view.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final FirestoreService firestoreService;

  const TodoCard({
    super.key,
    required this.todo,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailView(
                todo: todo,
                firestoreService: firestoreService,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Checkbox(
                value: todo.isCompleted,
                onChanged: (bool? value) async {
                  if (value != null) {
                    if (!value && todo.isCompleted) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reopen Todo'),
                          content: const Text(
                              'Are you sure you want to mark this todo as incomplete?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Reopen'),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                    }

                    final updatedTodo = todo.copyWith(
                      isCompleted: value,
                      completedAt: value ? DateTime.now() : null,
                    );
                    await firestoreService.updateTodo(updatedTodo);
                  }
                },
                shape: const CircleBorder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    if (todo.dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          DateFormat('EEE, MMM d').format(todo.dueDate!),
                          style: TextStyle(
                            color: todo.dueDate!.isBefore(DateTime.now()) &&
                                    !todo.isCompleted
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (todo.description != null && todo.description!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: ThemedIcon(Symbols.description_rounded,
                      size: 20, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
