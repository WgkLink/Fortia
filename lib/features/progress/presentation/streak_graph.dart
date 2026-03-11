import 'package:flutter/material.dart';

class StreakGraph extends StatelessWidget {
  const StreakGraph({
    super.key,
    required this.workoutDates,
    this.weeks = 12,
  });

  final Set<DateTime> workoutDates;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Build grid: 7 rows (Mon-Sun) x N weeks
    final startDate =
        today.subtract(Duration(days: (weeks * 7) - 1 + today.weekday - 1));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consistencia', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day labels
                Column(
                  children: [
                    _dayLabel(''),
                    _dayLabel('Seg'),
                    _dayLabel(''),
                    _dayLabel('Qua'),
                    _dayLabel(''),
                    _dayLabel('Sex'),
                    _dayLabel(''),
                  ],
                ),
                const SizedBox(width: 4),
                // Grid
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      children: List.generate(weeks, (weekIdx) {
                        return Column(
                          children: List.generate(7, (dayIdx) {
                            final date = startDate.add(
                                Duration(days: weekIdx * 7 + dayIdx));
                            final hasWorkout = workoutDates.contains(
                                DateTime(date.year, date.month, date.day));
                            final isFuture = date.isAfter(today);

                            return Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: isFuture
                                    ? Colors.transparent
                                    : hasWorkout
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surfaceContainerHighest,
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayLabel(String text) {
    return SizedBox(
      height: 15,
      child: Text(text, style: const TextStyle(fontSize: 9)),
    );
  }
}
