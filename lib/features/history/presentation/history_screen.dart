import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/formatters.dart';

final allWorkoutsProvider = StreamProvider<List<Workout>>((ref) {
  return ref.watch(workoutsDaoProvider).watchAllWorkouts();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(allWorkoutsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historico')),
      body: workoutsAsync.when(
        data: (workouts) {
          final completed =
              workouts.where((w) => w.finishedAt != null).toList();

          if (completed.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history,
                      size: 64,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('Nenhum treino no historico'),
                ],
              ),
            );
          }

          // Group by month
          final grouped = <String, List<Workout>>{};
          for (final w in completed) {
            final key = DateFormat('MMMM yyyy', 'pt_BR').format(w.startedAt);
            grouped.putIfAbsent(key, () => []).add(w);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final month = grouped.keys.elementAt(index);
              final monthWorkouts = grouped[month]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      month,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  ...monthWorkouts.map((workout) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            DateFormat('dd').format(workout.startedAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(workout.name),
                        subtitle: Text(
                          DateFormat('EEEE, dd/MM', 'pt_BR')
                              .format(workout.startedAt),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.duration(workout.durationSeconds),
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              DateFormat('HH:mm').format(workout.startedAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        onTap: () =>
                            context.push('/workout/${workout.id}'),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
