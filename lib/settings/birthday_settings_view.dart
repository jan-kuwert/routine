import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/birthday.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/services/notification_service.dart';
import 'package:routine/settings/settings_controller.dart';

class BirthdaySettingsView extends StatelessWidget {
  final FirestoreService firestoreService;
  final SettingsController controller;

  const BirthdaySettingsView({
    super.key,
    required this.firestoreService,
    required this.controller,
  });

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Future<void> _handleUnhideBirthday(
    BuildContext context,
    Birthday birthday,
  ) async {
    try {
      await firestoreService.unhideBirthday(birthday.id);
      await NotificationService().scheduleBirthdayNotification(birthday);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${birthday.name}\'s birthday has been unhidden'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleDeleteBirthday(
    BuildContext context,
    Birthday birthday,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Birthday'),
        content: Text(
          'Are you sure you want to permanently delete ${birthday.name}\'s birthday?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await firestoreService.deleteBirthday(birthday.id);
        await NotificationService().cancelNotification(birthday.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Birthday deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Birthday Settings'),
          ),
          // Enable/Disable Birthday Tab
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, child) {
                    return SwitchListTile(
                      title: const Text('Enable Birthdays Tab'),
                      subtitle: const Text('Show birthdays in the navigation bar'),
                      value: controller.isBirthdayEnabled,
                      onChanged: (value) {
                        controller.updateIsBirthdayEnabled(value);
                      },
                      secondary: const ThemedIcon(Symbols.cake_rounded),
                    );
                  },
                ),
              ),
            ),
          ),
          // Section Header: Hidden Birthdays
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: Text(
                'Hidden Birthdays',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          // Hidden Birthdays List
          StreamBuilder<List<Birthday>>(
            stream: firestoreService.getHiddenBirthdaysStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              final hiddenBirthdays = snapshot.data ?? [];

              if (hiddenBirthdays.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Symbols.cake_rounded,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No hidden birthdays',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final birthday = hiddenBirthdays[index];
                    final dateStr =
                        "${_monthName(birthday.date.month)} ${birthday.date.day}";

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: ThemedIcon(Symbols.cake_rounded),
                          ),
                          title: Text(birthday.name),
                          subtitle: Text(dateStr),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const ThemedIcon(Symbols.visibility_rounded),
                                onPressed: () =>
                                    _handleUnhideBirthday(context, birthday),
                                tooltip: 'Unhide',
                              ),
                              IconButton(
                                icon: const ThemedIcon(Symbols.delete_rounded),
                                onPressed: () =>
                                    _handleDeleteBirthday(context, birthday),
                                tooltip: 'Delete permanently',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: hiddenBirthdays.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

