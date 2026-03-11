import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import 'routines_provider.dart';

class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({super.key, required this.routineId});

  final int routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineAsync = ref.watch(routineWithExercisesProvider(routineId));

    return routineAsync.when(
      data: (data) => Scaffold(
        appBar: AppBar(
          title: Text(data.routine.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/routines/$routineId/edit'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () =>
              context.push('/workout/active?routineId=$routineId'),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Iniciar Treino'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      Formatters.dayOfWeek(data.routine.dayOfWeek),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '${data.exercises.length} exercicios',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...data.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item.exercise.name),
                  subtitle: Text(
                    '${item.routineExercise.targetSets} series x '
                    '${item.routineExercise.targetReps} reps\n'
                    'Descanso: ${item.routineExercise.targetRestSeconds}s',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push('/exercises/${item.exercise.id}'),
                ),
              );
            }),
          ],
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }
}
