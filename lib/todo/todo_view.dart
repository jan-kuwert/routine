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

  String _getTitle(List<TodoList>? lists) {
    if (_selectedListId == 'all') return 'All Todos';
    if (_selectedListId == null) return 'My Tasks';
    final list = lists?.firstWhere((l) => l.id == _selectedListId);
    return list?.name ?? 'Todo';
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
            appBar: AppBar(
              title: Text(_getTitle(lists)),
              actions: [
                IconButton(
                  icon: const ThemedIcon(Symbols.history),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoHistoryScreen(
                          firestoreService: widget.firestoreService,
                          listId:
                              _selectedListId == 'all' ? null : _selectedListId,
                          filterByList: _selectedListId != 'all',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                      child: Center(
                          child:
                              ThemedIcon(Symbols.checklist_rounded, size: 64))),
                  ListTile(
                    leading: const ThemedIcon(Symbols.all_inbox_rounded),
                    title: const Text('All Todos'),
                    selected: _selectedListId == 'all',
                    onTap: () {
                      _selectList('all');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const ThemedIcon(Symbols.check_box_rounded),
                    title: const Text('My Tasks'),
                    selected: _selectedListId == null,
                    onTap: () {
                      _selectList(null);
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text('Lists', style: TextStyle(color: Colors.grey)),
                  ),
                  ...lists.map((list) => ListTile(
                        leading: const ThemedIcon(Symbols.list_rounded),
                        title: Text(list.name),
                        selected: _selectedListId == list.id,
                        onTap: () {
                          _selectList(list.id);
                          Navigator.pop(context);
                        },
                        trailing: IconButton(
                          icon: const ThemedIcon(Symbols.delete_outline_rounded,
                              size: 20),
                          onPressed: () => _deleteList(list),
                        ),
                      )),
                  ListTile(
                    leading: const ThemedIcon(Symbols.add_rounded),
                    title: const Text('Create new list'),
                    onTap: _showCreateListDialog,
                  ),
                ],
              ),
            ),
            body: StreamBuilder<List<Todo>>(
              stream: widget.firestoreService.getTodosStream(
                  listId: _selectedListId == 'all' ? null : _selectedListId,
                  filterByList: _selectedListId != 'all'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(
                          _selectedListId == 'all'
                              ? 'No todos found'
                              : 'No todos in this list',
                          style: Theme.of(context).textTheme.bodyLarge));
                }

                final todos = snapshot.data!;

                return ReorderableListView.builder(
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
            floatingActionButtonLocation: ExpandableFab.location,
            floatingActionButton: ExpandableFab(
              key: _fabKey,
              type: ExpandableFabType.up,
              distance: 70,
              openButtonBuilder: RotateFloatingActionButtonBuilder(
                child: const ThemedIcon(Symbols.add_rounded),
                fabSize: ExpandableFabSize.regular,
              ),
              closeButtonBuilder: FloatingActionButtonBuilder(
                size: 56,
                builder: (BuildContext context, void Function()? onPressed,
                    Animation<double> progress) {
                  return IconButton(
                    onPressed: onPressed,
                    icon: const ThemedIcon(Symbols.close_rounded, size: 36),
                  );
                },
              ),
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    _fabKey.currentState?.toggle();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (context) => AddTodoSheet(
                        firestoreService: widget.firestoreService,
                        initialListId:
                            _selectedListId == 'all' ? null : _selectedListId,
                      ),
                    );
                  },
                  label: const Text('Add Todo'),
                  icon: const ThemedIcon(Symbols.check_box_rounded),
                ),
              ],
            ),
          );
        });
  }
}
