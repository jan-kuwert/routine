import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/todo.dart';
import 'package:routine/db/entities/todo_list.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/settings/settings_service.dart';
import 'package:routine/todo/add_todo_sheet.dart';
import 'package:routine/todo/todo_card.dart';
import 'package:routine/todo/todo_history.dart';

class TodoView extends StatefulWidget {
  final FirestoreService firestoreService;

  const TodoView({super.key, required this.firestoreService});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  final SettingsService _settingsService = SettingsService();

  // 'all' means All view. null means My Tasks. String means specific list ID.
  String? _selectedListId = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final lastId = await _settingsService.lastVisitedListId();
    if (mounted) {
      setState(() {
        _selectedListId = lastId ?? 'all';
        _isLoading = false;
      });
    }
  }

  void _selectList(String? listId) {
    setState(() => _selectedListId = listId);
    _settingsService.updateLastVisitedListId(listId);
  }

  Future<void> _showCreateListDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('New List'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'List Name'),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('Create')),
                ]));

    if (name != null && name.isNotEmpty) {
      final list = TodoList(id: '', name: name);
      await widget.firestoreService.addTodoList(list);
    }
  }

  Future<void> _deleteList(TodoList list) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Delete "${list.name}"?'),
                content:
                    const Text('This will delete the list and all its todos.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red))),
                ]));

    if (confirm == true) {
      await widget.firestoreService.deleteTodoList(list.id);
      if (_selectedListId == list.id) {
        _selectList('all');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<List<TodoList>>(
        stream: widget.firestoreService.getTodoListsStream(),
        builder: (context, listSnapshot) {
          final lists = listSnapshot.data ?? [];

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
                  title: const Text('Todos'),
                  actions: [
                    IconButton(
                      icon: const ThemedIcon(Symbols.history),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodoHistoryScreen(
                              firestoreService: widget.firestoreService,
                              listId: _selectedListId == 'all'
                                  ? null
                                  : _selectedListId,
                              filterByList: _selectedListId != 'all',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Horizontal scrollable list filter
                if (lists.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: const Text('All Todos'),
                                selected: _selectedListId == 'all',
                                onSelected: (selected) {
                                  if (selected) _selectList('all');
                                },
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                labelStyle: TextStyle(
                                  color: _selectedListId == 'all'
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                      : null,
                                  fontWeight: _selectedListId == 'all'
                                      ? FontWeight.bold
                                      : null,
                                ),
                                side: _selectedListId == 'all'
                                    ? BorderSide.none
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: const Text('My Tasks'),
                                selected: _selectedListId == null,
                                onSelected: (selected) {
                                  if (selected) _selectList(null);
                                },
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                labelStyle: TextStyle(
                                  color: _selectedListId == null
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                      : null,
                                  fontWeight: _selectedListId == null
                                      ? FontWeight.bold
                                      : null,
                                ),
                                side: _selectedListId == null
                                    ? BorderSide.none
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            ...lists.map(
                              (list) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(list.name),
                                  selected: _selectedListId == list.id,
                                  onSelected: (selected) {
                                    if (selected) _selectList(list.id);
                                  },
                                  onDeleted: () => _deleteList(list),
                                  deleteIcon: const Icon(
                                    Symbols.close_rounded,
                                    size: 18,
                                  ),
                                  selectedColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  labelStyle: TextStyle(
                                    color: _selectedListId == list.id
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                        : null,
                                    fontWeight: _selectedListId == list.id
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                  side: _selectedListId == list.id
                                      ? BorderSide.none
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                StreamBuilder<List<Todo>>(
                  stream: widget.firestoreService.getTodosStream(
                      listId: _selectedListId == 'all' ? null : _selectedListId,
                      filterByList: _selectedListId != 'all'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            _selectedListId == 'all'
                                ? 'No todos found'
                                : 'No todos in this list',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }

                    final todos = snapshot.data!;

                    return SliverReorderableList(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return KeyedSubtree(
                          key: ValueKey(todo.id),
                          child: TodoCard(
                            todo: todo,
                            firestoreService: widget.firestoreService,
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) async {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final Todo item = todos.removeAt(oldIndex);
                        todos.insert(newIndex, item);
                        await widget.firestoreService.reorderTodos(todos);
                      },
                    );
                  },
                ),
              ],
            ),
            ),
            floatingActionButtonLocation: ExpandableFab.location,
            floatingActionButton: ExpandableFab(
              key: _fabKey,
              type: ExpandableFabType.up,
              overlayStyle: ExpandableFabOverlayStyle(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh
                    .withValues(alpha: .9),
              ),
              openButtonBuilder: RotateFloatingActionButtonBuilder(
                child: const ThemedIcon(Symbols.add_rounded),
                fabSize: ExpandableFabSize.regular,
              ),
              closeButtonBuilder: FloatingActionButtonBuilder(
                size: 56,
                builder: (BuildContext context, void Function()? onPressed,
                    Animation<double> progress) {
                  return const Text('');
                },
              ),
              childrenOffset: const Offset(0, -70),
              childrenAnimation: ExpandableFabAnimation.none,
              distance: 70,
              children: [
                Row(
                  children: [
                    const Text('Add Todo'),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: () {
                        _fabKey.currentState?.toggle();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (context) => AddTodoSheet(
                            firestoreService: widget.firestoreService,
                            initialListId: _selectedListId == 'all'
                                ? null
                                : _selectedListId,
                          ),
                        );
                      },
                      tooltip: 'Add Todo',
                      child: const ThemedIcon(Symbols.check_box_rounded),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('New List'),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FloatingActionButton.small(
                        onPressed: () {
                          _fabKey.currentState?.toggle();
                          _showCreateListDialog();
                        },
                        tooltip: 'New List',
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        child: const ThemedIcon(Symbols.list_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
