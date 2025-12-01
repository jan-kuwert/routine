import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/todo.dart';
import 'package:routine/db/entities/todo_list.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/sport/date_input.dart';

class AddTodoSheet extends StatefulWidget {
  final FirestoreService firestoreService;
  final Todo? todo;
  final String? initialListId;

  const AddTodoSheet({
    super.key,
    required this.firestoreService,
    this.todo,
    this.initialListId,
  });

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  final List<TextEditingController> _subtaskControllers = [];
  String? _selectedListId;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description ?? '';
      _dueDate = widget.todo!.dueDate;
      _selectedListId = widget.todo!.listId;
      for (var subtask in widget.todo!.subtasks) {
        _subtaskControllers.add(TextEditingController(text: subtask.title));
      }
    } else {
        _selectedListId = widget.initialListId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSubtask() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) return;

    List<Subtask> finalSubtasks = [];
    if (widget.todo != null) {
      for (var controller in _subtaskControllers) {
        if (controller.text.isEmpty) continue;
        final existing = widget.todo!.subtasks.firstWhere(
            (s) => s.title == controller.text,
            orElse: () => Subtask(title: controller.text));
        finalSubtasks.add(
            Subtask(title: controller.text, isCompleted: existing.isCompleted));
      }
    } else {
      finalSubtasks = _subtaskControllers
          .where((c) => c.text.isNotEmpty)
          .map((c) => Subtask(title: c.text))
          .toList();
    }

    final todo = Todo(
      id: widget.todo?.id ?? '',
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      dueDate: _dueDate,
      subtasks: finalSubtasks,
      order: widget.todo?.order ?? 0,
      isCompleted: widget.todo?.isCompleted ?? false,
      createdAt: widget.todo?.createdAt,
      listId: _selectedListId,
    );

    try {
      if (widget.todo != null) {
        await widget.firestoreService.updateTodo(todo);
      } else {
        await widget.firestoreService.addTodo(todo);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.todo != null ? 'Edit Todo' : 'New Todo',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(width: 4),
                const ThemedIcon(Symbols.check_box_rounded),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: InputBorder.none,
                  floatingLabelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                autofocus: widget.todo == null,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: StreamBuilder<List<TodoList>>(
                stream: widget.firestoreService.getTodoListsStream(),
                builder: (context, snapshot) {
                  final lists = snapshot.data ?? [];
                  // Ensure selectedListId is valid (in case list was deleted)
                  // But if it's null ("My Tasks"), it's always valid.
                  // If it's an ID not in lists, DropdownButton might complain if we don't handle it.
                  // But lists might be loading.
                  
                  return DropdownButtonFormField<String?>(
                    initialValue: _selectedListId,
                    decoration: InputDecoration(
                      labelText: 'List',
                      border: InputBorder.none,
                      floatingLabelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('My Tasks')),
                      ...lists.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))),
                    ],
                    onChanged: (val) => setState(() => _selectedListId = val),
                  );
                }
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: InputBorder.none,
                  floatingLabelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DateInputWidget(
                  selectedDate: _dueDate,
                  dateLabel: 'Due Date (Optional)',
                  onDateChanged: (date) => setState(() => _dueDate = date)),
            ),
            const SizedBox(height: 16),
            const Align(
                alignment: Alignment.centerLeft, child: Text('Subtasks')),
            ..._subtaskControllers.asMap().entries.map((entry) {
              return Row(children: [
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: entry.value,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Subtask',
                    ),
                  ),
                )),
                IconButton(
                    onPressed: () => _removeSubtask(entry.key),
                    icon: const ThemedIcon(Symbols.remove_circle_outline_rounded))
              ]);
            }),
            TextButton.icon(
                onPressed: _addSubtask,
                icon: const ThemedIcon(Symbols.add_rounded),
                label: const Text('Add Subtask')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all<TextStyle>(
                    const TextStyle(fontSize: 16.0),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ));
  }
}

