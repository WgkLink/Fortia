import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../exercises/presentation/exercise_library_screen.dart';
import '../../progress/domain/pr_detector.dart';
import '../../progress/presentation/pr_celebration_dialog.dart';
import '../domain/enums.dart';
import 'active_workout_provider.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key, this.routineId});

  final int? routineId;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(activeWorkoutProvider);
      if (current == null) {
        ref
            .read(activeWorkoutProvider.notifier)
            .startWorkout(routineId: widget.routineId);
      }
    });
  }

  Future<void> _addExercise() async {
    final exercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => const ExerciseLibraryScreen(selectionMode: true),
      ),
    );
    if (exercise != null) {
      ref.read(activeWorkoutProvider.notifier).addExercise(exercise);
    }
  }

  Future<void> _finishWorkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Treino?'),
        content: const Text(
            'Series nao completadas serao salvas como estao.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final workoutId =
          await ref.read(activeWorkoutProvider.notifier).finishWorkout();
      if (mounted && workoutId != null) {
        // Detect PRs
        final prs = await PRDetector.detectPRs(
          workoutsDao: ref.read(workoutsDaoProvider),
          workoutId: workoutId,
        );
        if (mounted && prs.isNotEmpty) {
          await PRCelebrationDialog.show(context, prs);
        }
        if (mounted) context.go('/home');
      }
    }
  }

  Future<void> _discardWorkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar Treino?'),
        content: const Text('Todo o progresso sera perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(activeWorkoutProvider.notifier).discardWorkout();
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(activeWorkoutProvider);
    final durationAsync = ref.watch(workoutDurationProvider);
    final restTimer = ref.watch(restTimerProvider);

    if (workout == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _discardWorkout();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(workout.name),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _discardWorkout,
          ),
          actions: [
            TextButton(
              onPressed: workout.isFinishing ? null : _finishWorkout,
              child: const Text('Finalizar'),
            ),
          ],
        ),
        body: Column(
          children: [
            // Duration bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, size: 18),
                  const SizedBox(width: 8),
                  durationAsync.when(
                    data: (seconds) => Text(
                      Formatters.duration(seconds),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    loading: () => const Text('0m 00s'),
                    error: (_, __) => const Text('--'),
                  ),
                ],
              ),
            ),

            // Rest timer
            if (restTimer.isRunning)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Descanso: ${restTimer.remainingSeconds}s',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () =>
                          ref.read(restTimerProvider.notifier).addTime(15),
                      tooltip: '+15s',
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 18),
                      onPressed: () =>
                          ref.read(restTimerProvider.notifier).stop(),
                      tooltip: 'Pular',
                    ),
                  ],
                ),
              ),

            // Exercises list
            Expanded(
              child: workout.exercises.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Nenhum exercicio adicionado'),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _addExercise,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Exercicio'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: workout.exercises.length + 1,
                      itemBuilder: (context, index) {
                        if (index == workout.exercises.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: OutlinedButton.icon(
                              onPressed: _addExercise,
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar Exercicio'),
                            ),
                          );
                        }
                        return _ExerciseCard(
                          exerciseIndex: index,
                          exercise: workout.exercises[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends ConsumerWidget {
  const _ExerciseCard({
    required this.exerciseIndex,
    required this.exercise,
  });

  final int exerciseIndex;
  final ActiveExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remover Exercicio'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'remove') {
                      ref
                          .read(activeWorkoutProvider.notifier)
                          .removeExercise(exerciseIndex);
                    }
                  },
                ),
              ],
            ),
            if (exercise.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  exercise.notes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 36, child: Text('Serie')),
                  const SizedBox(width: 80, child: Text('Anterior')),
                  const Expanded(child: Text('Peso (kg)')),
                  const Expanded(child: Text('Reps')),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Sets
            ...exercise.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set_ = entry.value;

              return _SetRow(
                exerciseIndex: exerciseIndex,
                setIndex: setIndex,
                set_: set_,
              );
            }),

            // Add set button
            TextButton.icon(
              onPressed: () => ref
                  .read(activeWorkoutProvider.notifier)
                  .addSet(exerciseIndex),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Adicionar Serie'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends ConsumerStatefulWidget {
  const _SetRow({
    required this.exerciseIndex,
    required this.setIndex,
    required this.set_,
  });

  final int exerciseIndex;
  final int setIndex;
  final ActiveSet set_;

  @override
  ConsumerState<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends ConsumerState<_SetRow> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set_.weightKg > 0
          ? Formatters.weight(widget.set_.weightKg)
          : '',
    );
    _repsController = TextEditingController(
      text: widget.set_.reps > 0 ? widget.set_.reps.toString() : '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = widget.set_.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: isCompleted
          ? BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        children: [
          // Set number + type
          SizedBox(
            width: 36,
            child: GestureDetector(
              onTap: () => _showSetTypeMenu(context),
              child: Text(
                _setLabel(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _setLabelColor(theme),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Previous performance
          SizedBox(
            width: 80,
            child: Text(
              widget.set_.previousWeight != null
                  ? '${Formatters.weight(widget.set_.previousWeight!)}x${widget.set_.previousReps}'
                  : '-',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Weight input
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  isDense: true,
                ),
                onChanged: (value) {
                  final weight = double.tryParse(value) ?? 0;
                  ref.read(activeWorkoutProvider.notifier).updateSet(
                        widget.exerciseIndex,
                        widget.setIndex,
                        weight: weight,
                      );
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Reps input
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  isDense: true,
                ),
                onChanged: (value) {
                  final reps = int.tryParse(value) ?? 0;
                  ref.read(activeWorkoutProvider.notifier).updateSet(
                        widget.exerciseIndex,
                        widget.setIndex,
                        reps: reps,
                      );
                },
              ),
            ),
          ),

          // Complete button
          SizedBox(
            width: 48,
            child: IconButton(
              icon: Icon(
                isCompleted
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: isCompleted ? theme.colorScheme.primary : null,
              ),
              onPressed: () {
                ref
                    .read(activeWorkoutProvider.notifier)
                    .toggleSetCompleted(widget.exerciseIndex, widget.setIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _setLabel() {
    return switch (widget.set_.setType) {
      SetType.warmup => 'A',
      SetType.dropset => 'D',
      SetType.failure => 'F',
      SetType.normal => '${widget.setIndex + 1}',
    };
  }

  Color _setLabelColor(ThemeData theme) {
    return switch (widget.set_.setType) {
      SetType.warmup => Colors.orange,
      SetType.dropset => Colors.purple,
      SetType.failure => theme.colorScheme.error,
      SetType.normal => theme.colorScheme.onSurface,
    };
  }

  void _showSetTypeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: SetType.values.map((type) {
          return ListTile(
            title: Text(type.label),
            selected: widget.set_.setType == type,
            onTap: () {
              ref.read(activeWorkoutProvider.notifier).updateSet(
                    widget.exerciseIndex,
                    widget.setIndex,
                    setType: type,
                  );
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }
}
