import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../routines/presentation/routines_provider.dart';

final _todayRoutinesProvider = StreamProvider((ref) {
  final today = DateTime.now().weekday; // 1=Monday
  return ref.watch(routinesDaoProvider).watchRoutinesByDay(today);
});

final _recentWorkoutsProvider = StreamProvider((ref) {
  return ref.watch(workoutsDaoProvider).watchRecentWorkouts(limit: 5);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRoutines = ref.watch(_todayRoutinesProvider);
    final recentWorkouts = ref.watch(_recentWorkoutsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fortia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick start
          Card(
            color: theme.colorScheme.primaryContainer,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/workout/active'),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.bolt,
                        size: 32, color: theme.colorScheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Treino Rapido',
                              style: theme.textTheme.titleMedium),
                          Text('Iniciar treino sem rotina',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Today's routines
          Text('Rotina de Hoje',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          todayRoutines.when(
            data: (routines) {
              if (routines.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.event_available,
                            size: 48,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 8),
                        const Text('Nenhuma rotina para hoje'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.push('/routines/new'),
                          child: const Text('Criar Rotina'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: routines.map((routine) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Color(int.parse(routine.colorHex, radix: 16)),
                        child: const Icon(Icons.fitness_center,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(routine.name),
                      trailing: FilledButton(
                        onPressed: () => context.push(
                            '/workout/active?routineId=${routine.id}'),
                        child: const Text('Iniciar'),
                      ),
                      onTap: () => context.push('/routines/${routine.id}'),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro: $e'),
          ),

          const SizedBox(height: 24),

          // Recent activity
          Text('Atividade Recente',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          recentWorkouts.when(
            data: (workouts) {
              if (workouts.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('Nenhum treino registrado'),
                    ),
                  ),
                );
              }

              return Column(
                children: workouts.map((workout) {
                  return Card(
                    child: ListTile(
                      title: Text(workout.name),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy - HH:mm')
                            .format(workout.startedAt),
                      ),
                      trailing: workout.durationSeconds > 0
                          ? Text(
                              Formatters.duration(workout.durationSeconds),
                              style: theme.textTheme.bodySmall,
                            )
                          : null,
                      onTap: () =>
                          context.push('/workout/${workout.id}'),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro: $e'),
          ),
        ],
      ),
    );
  }
}
