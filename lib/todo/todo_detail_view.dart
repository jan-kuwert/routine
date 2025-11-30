import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/todo.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/todo/add_todo_sheet.dart';

class TodoDetailView extends StatefulWidget {
  final Todo todo;
  final FirestoreService firestoreService;

  const TodoDetailView({
    super.key,
    required this.todo,
    required this.firestoreService,
  });

  @override
  State<TodoDetailView> createState() => _TodoDetailViewState();
}

class _TodoDetailViewState extends State<TodoDetailView> {
  late Todo _todo;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
  }

  Future<void> _toggleCompletion(bool? value) async {
    if (value != null) {
      if (!value && _todo.isCompleted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reopen Todo'),
            content: const Text('Are you sure you want to mark this todo as incomplete?'),
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

      final updatedTodo = _todo.copyWith(
        isCompleted: value,
        completedAt: value ? DateTime.now() : null,
      );
      await widget.firestoreService.updateTodo(updatedTodo);
      setState(() {
        _todo = updatedTodo;
      });
    }
  }

  Future<void> _toggleSubtask(int index, bool? value) async {
    if (value != null) {
      final newSubtasks = List<Subtask>.from(_todo.subtasks);
      newSubtasks[index] = Subtask(
          title: _todo.subtasks[index].title, isCompleted: value);
      final updatedTodo = _todo.copyWith(subtasks: newSubtasks);
      await widget.firestoreService.updateTodo(updatedTodo);
      setState(() {
        _todo = updatedTodo;
      });
    }
  }

  Future<void> _addSubtask() async {
    final controller = TextEditingController();
    final newSubtask = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Subtask title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (newSubtask != null && newSubtask.isNotEmpty) {
      final newSubtasks = List<Subtask>.from(_todo.subtasks);
      newSubtasks.add(Subtask(title: newSubtask));
      final updatedTodo = _todo.copyWith(subtasks: newSubtasks);
      await widget.firestoreService.updateTodo(updatedTodo);
      setState(() {
        _todo = updatedTodo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // Empty title as we show it in body
        actions: [
          IconButton(
            tooltip: _todo.isCompleted ? 'Mark as incomplete' : 'Mark as complete',
            icon: ThemedIcon(
              _todo.isCompleted ? Symbols.check_circle_filled_rounded : Symbols.circle,
              color: _todo.isCompleted ? Theme.of(context).colorScheme.primary : null,
              size: 28,
            ),
            onPressed: () => _toggleCompletion(!_todo.isCompleted),
          ),
          IconButton(
            icon: const ThemedIcon(Symbols.edit_rounded),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (context) => AddTodoSheet(
                  firestoreService: widget.firestoreService,
                  todo: _todo,
                ),
              );
              // Refresh data? The sheet updates firestore, we might need to listen to stream or reload?
              // Since this view takes a Todo object, it won't auto-update unless we wrap it in a StreamBuilder 
              // or pass a stream. For simplicity, let's just pop back or reload.
              // Ideally we use a stream here too.
              if (mounted) {
                 // For now, we can rely on parent stream if we pop, but to stay here and see changes:
                 // We really should fetch the latest todo.
                 // Let's wrap body in StreamBuilder or similar pattern.
                 // Or just close this view on edit? 
                 // User might expect to stay.
                 // Let's convert this to use a stream of the single todo.
              }
            },
          ),
          IconButton(
            icon: const ThemedIcon(Symbols.delete_rounded, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Todo'),
                  content: const Text('Are you sure you want to delete this todo?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await widget.firestoreService.deleteTodo(_todo.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Todo>>(
        stream: widget.firestoreService.getTodosStream(),
        builder: (context, snapshot) {
           return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _todo.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 24),
                
                // Description
                if (_todo.description != null && _todo.description!.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: ThemedIcon(Symbols.subject_rounded, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _todo.description!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Date
                if (_todo.dueDate != null) ...[
                  Row(
                    children: [
                      const ThemedIcon(Symbols.schedule_rounded, size: 24),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('EEE, MMM d').format(_todo.dueDate!),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Subtasks
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: ThemedIcon(Symbols.subdirectory_arrow_right_rounded, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_todo.subtasks.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _todo.subtasks.length,
                              itemBuilder: (context, index) {
                                final subtask = _todo.subtasks[index];
                                return InkWell(
                                  onTap: () => _toggleSubtask(index, !subtask.isCompleted),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: subtask.isCompleted,
                                            onChanged: (val) => _toggleSubtask(index, val),
                                            shape: const CircleBorder(),
                                            side: BorderSide(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            subtask.title,
                                            style: TextStyle(
                                              decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                            child: InkWell(
                              onTap: _addSubtask,
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Add subtasks',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }
      ),
    );
  }
}