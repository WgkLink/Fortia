import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/enums.dart';
import 'exercises_provider.dart';

class ExerciseLibraryScreen extends ConsumerWidget {
  const ExerciseLibraryScreen({super.key, this.selectionMode = false});

  final bool selectionMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(filteredExercisesProvider);
    final searchQuery = ref.watch(exerciseSearchQueryProvider);
    final muscleFilter = ref.watch(selectedMuscleFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercicios'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar exercicio...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) {
                ref.read(exerciseSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: muscleFilter == null,
                  onSelected: (_) {
                    ref.read(selectedMuscleFilterProvider.notifier).state = null;
                  },
                ),
                ...MuscleGroup.values.map((mg) => _FilterChip(
                      label: mg.label,
                      selected: muscleFilter == mg.name,
                      onSelected: (_) {
                        ref.read(selectedMuscleFilterProvider.notifier).state =
                            mg.name;
                      },
                    )),
              ],
            ),
          ),
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return const Center(
                    child: Text('Nenhum exercicio encontrado'),
                  );
                }
                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.primaryMuscleGroup} • ${exercise.equipmentType}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: selectionMode
                          ? const Icon(Icons.add_circle_outline)
                          : const Icon(Icons.chevron_right),
                      onTap: () {
                        if (selectionMode) {
                          Navigator.of(context).pop(exercise);
                        } else {
                          context.push('/exercises/${exercise.id}');
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}
