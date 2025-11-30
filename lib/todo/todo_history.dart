import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/todo.dart';
import 'package:routine/services/firestore_service.dart';

class TodoHistoryScreen extends StatelessWidget {
  final FirestoreService firestoreService;
  final String? listId;
  final bool filterByList;

  const TodoHistoryScreen({
    super.key,
    required this.firestoreService,
    this.listId,
    this.filterByList = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo History'),
      ),
      body: StreamBuilder<List<Todo>>(
        stream: firestoreService.getCompletedTodosStream(
            listId: listId, filterByList: filterByList),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No completed todos yet'));
          }

          final todos = snapshot.data!;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                leading: const ThemedIcon(Symbols.check_circle_rounded, color: Colors.green),
                title: Text(
                  todo.title,
                  style: const TextStyle(decoration: TextDecoration.lineThrough),
                ),
                subtitle: Text(
                  'Completed on ${DateFormat('MMM d, yyyy').format(todo.completedAt ?? DateTime.now())}',
                ),
                trailing: IconButton(
                  icon: ThemedIcon(Symbols.delete_rounded, color: Colors.red),
                  onPressed: () async {
                    // allow deleting from history
                     final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete History Item'),
                        content: const Text('Delete this from history?'),
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
                      await firestoreService.deleteTodo(todo.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

