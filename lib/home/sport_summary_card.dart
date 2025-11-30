import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:collection/collection.dart';

class SportSummaryCard extends StatelessWidget {
  final FirestoreService firestoreService;
  final VoidCallback? onTap;

  const SportSummaryCard({
    super.key,
    required this.firestoreService,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return StreamBuilder<List<Workout>>(
      stream: firestoreService.workoutsAfterDateStream(
          startOfDay.subtract(const Duration(milliseconds: 1))),
      builder: (context, snapshot) {
        double progress = 0;
        bool hasWorkout = false;

        if (snapshot.hasData) {
          final todayWorkout = snapshot.data!.firstWhereOrNull((w) =>
              w.date.year == now.year &&
              w.date.month == now.month &&
              w.date.day == now.day);

          if (todayWorkout != null) {
            hasWorkout = true;
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
        }

        return Card(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sport',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                      ),
                      const ThemedIcon(Symbols.chevron_right_rounded),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (hasWorkout) ...[
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Serif',
                          ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      color: const Color(0xFFD4E157),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No workout today',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

