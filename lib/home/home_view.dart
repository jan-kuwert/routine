import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/components/summary_card.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/birthday.dart';
import 'package:routine/db/entities/todo.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/settings/settings_controller.dart';

import '../settings/settings_view.dart';

class HomeView extends StatefulWidget {
  final FirestoreService firestoreService;
  final SettingsController settingsController;
  final VoidCallback? onNavigateToSport;
  final VoidCallback? onNavigateToTodo;
  final VoidCallback? onNavigateToBirthday;

  const HomeView({
    super.key,
    required this.firestoreService,
    required this.settingsController,
    this.onNavigateToSport,
    this.onNavigateToTodo,
    this.onNavigateToBirthday,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  FirestoreService get firestoreService => widget.firestoreService;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: FutureBuilder<String?>(
              future:
                  Future.value(FirebaseAuth.instance.currentUser?.displayName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                return Text('Hi, ${snapshot.data ?? 'Welcome back'}');
              },
            ),
            actions: [
              IconButton(
                icon: const ThemedIcon(Symbols.settings_rounded),
                onPressed: () {
                  // Navigate to the settings page using a named route.
                  Navigator.restorablePushNamed(
                      context, SettingsView.routeName);
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildListDelegate([
                // Sport Summary Card
                StreamBuilder<List<Workout>>(
                  stream: firestoreService.workoutsAfterDateStream(
                    DateTime.now().subtract(const Duration(milliseconds: 1)),
                  ),
                  builder: (context, snapshot) {
                    final now = DateTime.now();
                    double progress = 0;
                    bool hasWorkout = false;

                    if (snapshot.hasData) {
                      final todayWorkout = snapshot.data!.firstWhere(
                        (w) =>
                            w.date.year == now.year &&
                            w.date.month == now.month &&
                            w.date.day == now.day,
                        orElse: () => Workout(id: '', date: now, exercises: []),
                      );

                      hasWorkout = todayWorkout.id.isNotEmpty;
                      if (todayWorkout.exercises.isNotEmpty) {
                        double total = 0;
                        for (var e in todayWorkout.exercises) {
                          double p = e.target > 0 ? e.counter / e.target : 0;
                          if (p > 1.0) p = 1.0;
                          total += p;
                        }
                        progress = total / todayWorkout.exercises.length;
                      }
                    }

                    return SummaryCard(
                      title: 'Sport',
                      onTap: widget.onNavigateToSport,
                      contentBuilder: (context) {
                        if (hasWorkout) {
                          return SummaryCard.progressContent(
                            context: context,
                            progress: progress,
                            progressColor: const Color(0xFFD4E157),
                          );
                        }
                        return SummaryCard.emptyState(
                            context, 'No workout today');
                      },
                    );
                  },
                ),
                // Todo Summary Card
                StreamBuilder<List<Todo>>(
                  stream: firestoreService.getTodosStream(),
                  builder: (context, snapshot) {
                    final todos = snapshot.data ?? [];
                    final remainingCount =
                        todos.length > 1 ? todos.length - 1 : 0;
                    final hasData = snapshot.hasData;

                    return SummaryCard(
                      title: 'Todos',
                      onTap: widget.onNavigateToTodo,
                      contentBuilder: (context) {
                        if (hasData && todos.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todos.first.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              if (remainingCount > 0) ...[
                                const SizedBox(height: 8),
                                SummaryCard.badge(
                                    context, '+$remainingCount more'),
                              ],
                            ],
                          );
                        }
                        return SummaryCard.emptyState(context, 'No todos');
                      },
                    );
                  },
                ),
                // Birthday Summary Card (only if enabled in settings)
                if (widget.settingsController.isBirthdayEnabled)
                  StreamBuilder<List<Birthday>>(
                    stream: firestoreService.getBirthdaysStream(),
                    builder: (context, snapshot) {
                      final birthdays = snapshot.data ?? [];
                      final hasData = snapshot.hasData;

                      Birthday? nextBirthday;
                      int? daysUntil;

                      if (birthdays.isNotEmpty) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);

                        birthdays.sort((a, b) {
                          final aNext = _nextBirthday(a.date, today);
                          final bNext = _nextBirthday(b.date, today);
                          return aNext.compareTo(bNext);
                        });

                        nextBirthday = birthdays.first;
                        final nextDate =
                            _nextBirthday(nextBirthday.date, today);
                        daysUntil = nextDate.difference(today).inDays;
                      }

                      return SummaryCard(
                        title: 'Birthdays',
                        onTap: widget.onNavigateToBirthday,
                        contentBuilder: (context) {
                          if (hasData && nextBirthday != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const ThemedIcon(
                                      Symbols.cake_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        nextBirthday.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  daysUntil == 0
                                      ? 'Today! 🎉'
                                      : daysUntil == 1
                                          ? 'Tomorrow'
                                          : 'In $daysUntil days',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: daysUntil == 0
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                        fontWeight: daysUntil == 0
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_monthName(nextBirthday.date.month)} ${nextBirthday.date.day}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            );
                          }
                          return SummaryCard.emptyState(
                              context, 'No birthdays');
                        },
                      );
                    },
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
