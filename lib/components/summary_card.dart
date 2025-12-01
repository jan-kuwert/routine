import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';

/// A reusable summary card component for the home page
/// Uses a builder pattern to allow custom content while maintaining consistent styling
class SummaryCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget Function(BuildContext context) contentBuilder;

  const SummaryCard({
    super.key,
    required this.title,
    required this.contentBuilder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                  ),
                  const ThemedIcon(Symbols.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 12),
              contentBuilder(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to create empty state text
  static Widget emptyState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  /// Helper method to create a progress indicator widget
  static Widget progressContent({
    required BuildContext context,
    required double progress,
    Color? progressColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          color: progressColor ?? const Color(0xFFD4E157),
        ),
      ],
    );
  }

  /// Helper method to create a badge widget (like "+5 more")
  static Widget badge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
