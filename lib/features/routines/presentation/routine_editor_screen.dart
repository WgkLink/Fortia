import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../exercises/presentation/exercise_library_screen.dart';
import 'routines_provider.dart';

class RoutineEditorScreen extends ConsumerStatefulWidget {
  const RoutineEditorScreen({super.key, this.routineId});

  final int? routineId;

  @override
  ConsumerState<RoutineEditorScreen> createState() =>
      _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  final _nameController = TextEditingController();
  int _selectedDay = 1;
  bool _isLoading = false;

  bool get _isEditing => widget.routineId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadRoutine();
    }
  }

  Future<void> _loadRoutine() async {
    final routine =
        await ref.read(routineByIdProvider(widget.routineId!).future);
    _nameController.text = routine.name;
    setState(() => _selectedDay = routine.dayOfWeek);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome da rotina e obrigatorio')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final existing =
            await ref.read(routineByIdProvider(widget.routineId!).future);
        await ref.read(routinesDaoProvider).updateRoutine(
              existing.copyWith(
                name: name,
                dayOfWeek: _selectedDay,
                updatedAt: DateTime.now(),
              ),
            );
      } else {
        final id = await ref.read(routineNotifierProvider.notifier).createRoutine(
              name: name,
              dayOfWeek: _selectedDay,
            );
        if (mounted) {
          context.go('/routines/$id');
          return;
        }
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addExercise() async {
    if (!_isEditing) return;

    final exercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => const ExerciseLibraryScreen(selectionMode: true),
      ),
    );

    if (exercise == null) return;

    final exercises =
        await ref.read(routineExercisesProvider(widget.routineId!).future);

    await ref.read(routineNotifierProvider.notifier).addExerciseToRoutine(
          routineId: widget.routineId!,
          exerciseId: exercise.id,
          sortOrder: exercises.length,
        );

    ref.invalidate(routineExercisesProvider(widget.routineId!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Rotina' : 'Nova Rotina'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Excluir Rotina?'),
                    content: const Text('Esta acao nao pode ser desfeita.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await ref
                      .read(routineNotifierProvider.notifier)
                      .deleteRoutine(widget.routineId!);
                  if (mounted) context.go('/routines');
                }
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _save,
        icon: const Icon(Icons.save),
        label: const Text('Salvar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome da Rotina',
              hintText: 'Ex: Peito e Triceps',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          Text('Dia da Semana',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final day = i + 1;
              return ChoiceChip(
                label: Text(Formatters.dayOfWeekShort(day)),
                selected: _selectedDay == day,
                onSelected: (_) => setState(() => _selectedDay = day),
              );
            }),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exercicios',
                    style: Theme.of(context).textTheme.titleSmall),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            Consumer(
              builder: (context, ref, _) {
                final exercisesAsync =
                    ref.watch(routineExercisesProvider(widget.routineId!));
                return exercisesAsync.when(
                  data: (exercises) {
                    if (exercises.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('Nenhum exercicio adicionado'),
                        ),
                      );
                    }
                    return ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exercises.length,
                      onReorder: (oldIndex, newIndex) {
                        // TODO: implement reorder
                      },
                      itemBuilder: (context, index) {
                        final item = exercises[index];
                        return Dismissible(
                          key: ValueKey(item.routineExercise.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.delete,
                                color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ref
                                .read(routineNotifierProvider.notifier)
                                .removeExerciseFromRoutine(
                                    item.routineExercise.id);
                            ref.invalidate(
                                routineExercisesProvider(widget.routineId!));
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(item.exercise.name),
                            subtitle: Text(
                              '${item.routineExercise.targetSets} series x '
                              '${item.routineExercise.targetReps} reps • '
                              '${item.routineExercise.targetRestSeconds}s descanso',
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erro: $e')),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
