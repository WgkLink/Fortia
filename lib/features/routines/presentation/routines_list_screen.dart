import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import 'routines_provider.dart';

class RoutinesListScreen extends ConsumerWidget {
  const RoutinesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(allRoutinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rotinas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/routines/new'),
        child: const Icon(Icons.add),
      ),
      body: routinesAsync.when(
        data: (routines) {
          if (routines.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('Nenhuma rotina criada'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => context.push('/routines/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Rotina'),
                  ),
                ],
              ),
            );
          }

          // Group by day of week
          final grouped = <int, List<dynamic>>{};
          for (final r in routines) {
            grouped.putIfAbsent(r.dayOfWeek, () => []).add(r);
          }

          final sortedDays = grouped.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDays.length,
            itemBuilder: (context, index) {
              final day = sortedDays[index];
              final dayRoutines = grouped[day]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      Formatters.dayOfWeek(day),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  ...dayRoutines.map((routine) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(
                                int.parse(routine.colorHex, radix: 16)),
                            child: Text(
                              routine.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(routine.name),
                          subtitle: Text(Formatters.dayOfWeek(routine.dayOfWeek)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/routines/${routine.id}'),
                        ),
                      )),
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
