import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/birthday.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/services/notification_service.dart';

class BirthdayView extends StatefulWidget {
  final FirestoreService firestoreService;

  const BirthdayView({super.key, required this.firestoreService});

  @override
  State<BirthdayView> createState() => _BirthdayViewState();
}

class _BirthdayViewState extends State<BirthdayView> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    NotificationService().requestPermissions();
  }

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _importContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (await FlutterContacts.requestPermission(readonly: true)) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        int addedCount = 0;
        for (var contact in contacts) {
          // Find birthday event
          Event? birthdayEvent;
          for (var event in contact.events) {
            if (event.label == EventLabel.birthday) {
              birthdayEvent = event;
              break;
            }
          }

          if (birthdayEvent != null) {
            // Year can be null, use a leap year (e.g. 2000) if null to handle Feb 29 correctly for display purposes
            final year = birthdayEvent.year ?? 0;
            final month = birthdayEvent.month;
            final day = birthdayEvent.day;

            // Firestore Timestamp range is limited, year 0 might be an issue?
            // Let's use 2000 if year is missing (0).
            final date = DateTime(year == 0 ? 2000 : year, month, day);

            // Create Birthday entity
            final birthday = Birthday(
              id: contact.id, // Use contact ID to avoid duplicates
              name: contact.displayName,
              date: date,
              isSynced: true, // Mark as synced from contacts
            );

            await widget.firestoreService.saveBirthday(birthday);
            await NotificationService().scheduleBirthdayNotification(birthday);
            addedCount++;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported $addedCount birthdays')),
          );
        }
      } else {
        if (mounted) {
          // Open settings if permission permanently denied?
          openAppSettings();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error importing contacts: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDeleteBirthday(Birthday birthday) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Birthday'),
        content: Text(
          birthday.isSynced
              ? 'This birthday is synced from your contacts. It will be hidden instead of deleted. You can find it in Settings > Manage Birthdays.'
              : 'Are you sure you want to delete ${birthday.name}\'s birthday?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(birthday.isSynced ? 'Hide' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        if (birthday.isSynced) {
          // Hide synced birthdays instead of deleting them
          await widget.firestoreService.hideBirthday(birthday.id);
        } else {
          // Delete manually added birthdays
          await widget.firestoreService.deleteBirthday(birthday.id);
        }
        await NotificationService().cancelNotification(birthday.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                birthday.isSynced
                    ? 'Birthday hidden. You can unhide it in Settings.'
                    : 'Birthday deleted',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showAddBirthdayDialog() {
    final nameController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Birthday'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(selectedDate == null
                      ? 'Select Date'
                      : '${_monthName(selectedDate!.month)} ${selectedDate!.day}, ${selectedDate!.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty && selectedDate != null) {
                    final birthday = Birthday(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      date: selectedDate!,
                    );
                    await widget.firestoreService.saveBirthday(birthday);
                    await NotificationService()
                        .scheduleBirthdayNotification(birthday);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBirthdayDialog,
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Birthdays'),
            actions: [
              IconButton(
                icon: const ThemedIcon(Symbols.sync_rounded),
                color: !_isMobile ? Colors.grey : null,
                onPressed: _isLoading
                    ? null
                    : () {
                        if (!_isMobile) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Contact import is only available on Android and iOS')),
                          );
                          return;
                        }
                        _importContacts();
                      },
                tooltip: 'Sync Contacts',
              ),
            ],
          ),
          StreamBuilder<List<Birthday>>(
            stream: widget.firestoreService.getBirthdaysStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final birthdays = snapshot.data ?? [];

              if (birthdays.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No birthdays found.'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (!_isMobile) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Contact import is only available on Android and iOS')),
                                    );
                                    return;
                                  }
                                  _importContacts();
                                },
                          style: !_isMobile
                              ? FilledButton.styleFrom(
                                  backgroundColor: Colors.grey)
                              : null,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const ThemedIcon(Symbols.contacts_rounded),
                          label: const Text('Import from Contacts'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort by upcoming birthday
              // We need to calculate days until next birthday
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);

              birthdays.sort((a, b) {
                final aNext = _nextBirthday(a.date, today);
                final bNext = _nextBirthday(b.date, today);
                return aNext.compareTo(bNext);
              });

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final birthday = birthdays[index];
                    final nextBirthday = _nextBirthday(birthday.date, today);
                    final daysUntil = nextBirthday.difference(today).inDays;

                    String subtitle;
                    if (daysUntil == 0) {
                      subtitle = 'Today!';
                    } else if (daysUntil == 1) {
                      subtitle = 'Tomorrow';
                    } else {
                      subtitle = 'In $daysUntil days';
                    }

                    // Format date
                    final dateStr =
                        "${_monthName(birthday.date.month)} ${birthday.date.day}";

                    return ListTile(
                      leading: const CircleAvatar(
                        child: ThemedIcon(Symbols.cake_rounded),
                      ),
                      title: Text(birthday.name),
                      subtitle: Text('$subtitle ($dateStr)'),
                      trailing: IconButton(
                        icon: const ThemedIcon(Symbols.delete_rounded),
                        onPressed: () => _handleDeleteBirthday(birthday),
                      ),
                    );
                  },
                  childCount: birthdays.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DateTime _nextBirthday(DateTime birthdayDate, DateTime today) {
    DateTime next = DateTime(today.year, birthdayDate.month, birthdayDate.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, birthdayDate.month, birthdayDate.day);
    }
    return next;
  }

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
}
