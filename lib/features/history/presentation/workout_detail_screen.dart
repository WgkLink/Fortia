import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../workout/data/workouts_dao.dart';

final workoutDetailProvider =
    FutureProvider.family<WorkoutWithDetails, int>((ref, id) async {
  return ref.watch(workoutsDaoProvider).getWorkoutWithDetails(id);
});

class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.workoutId});

  final int workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workoutDetailProvider(workoutId));
    final theme = Theme.of(context);

    return detailAsync.when(
      data: (detail) => Scaffold(
        appBar: AppBar(title: Text(detail.workout.name)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.timer,
                      label: 'Duracao',
                      value: Formatters.duration(
                          detail.workout.durationSeconds),
                    ),
                    _StatItem(
                      icon: Icons.fitness_center,
                      label: 'Exercicios',
                      value: '${detail.exercises.length}',
                    ),
                    _StatItem(
                      icon: Icons.repeat,
                      label: 'Series',
                      value: '${detail.totalSetsCompleted}',
                    ),
                    _StatItem(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Volume',
                      value: Formatters.volume(detail.totalVolume),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  DateFormat('EEEE, dd/MM/yyyy - HH:mm', 'pt_BR')
                      .format(detail.workout.startedAt),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Exercises
            ...detail.exercises.map((exerciseData) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseData.exercise.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Header
                      Row(
                        children: [
                          const SizedBox(
                              width: 36, child: Text('Serie')),
                          const Expanded(child: Text('Peso')),
                          const Expanded(child: Text('Reps')),
                          const SizedBox(width: 36),
                        ],
                      ),
                      const Divider(),
                      ...exerciseData.sets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final set_ = entry.value;
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 36,
                                child: Text('${index + 1}'),
                              ),
                              Expanded(
                                child: Text(
                                    '${Formatters.weight(set_.weightKg)} kg'),
                              ),
                              Expanded(
                                child: Text('${set_.reps}'),
                              ),
                              SizedBox(
                                width: 36,
                                child: Icon(
                                  set_.isCompleted
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 18,
                                  color: set_.isCompleted
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),

            if (detail.workout.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notas',
                          style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(detail.workout.notes),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20,
            color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
