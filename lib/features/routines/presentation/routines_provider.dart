import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../data/routines_dao.dart';
import '../data/routines_table.dart';

final allRoutinesProvider = StreamProvider<List<Routine>>((ref) {
  return ref.watch(routinesDaoProvider).watchAllRoutines();
});

final routinesByDayProvider =
    StreamProvider.family<List<Routine>, int>((ref, day) {
  return ref.watch(routinesDaoProvider).watchRoutinesByDay(day);
});

final routineByIdProvider =
    FutureProvider.family<Routine, int>((ref, id) async {
  return ref.watch(routinesDaoProvider).getRoutineById(id);
});

final routineWithExercisesProvider =
    FutureProvider.family<RoutineWithExercises, int>((ref, id) async {
  return ref.watch(routinesDaoProvider).getRoutineWithExercises(id);
});

final routineExercisesProvider =
    StreamProvider.family<List<RoutineExerciseWithDetails>, int>((ref, id) {
  return ref.watch(routinesDaoProvider).watchRoutineExercises(id);
});

class RoutineNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<int> createRoutine({
    required String name,
    required int dayOfWeek,
    String colorHex = 'FF6C63FF',
  }) async {
    final dao = ref.read(routinesDaoProvider);
    return dao.insertRoutine(RoutinesCompanion.insert(
      name: name,
      dayOfWeek: dayOfWeek,
      colorHex: Value(colorHex),
    ));
  }

  Future<void> deleteRoutine(int id) async {
    final dao = ref.read(routinesDaoProvider);
    await dao.deleteRoutineExercisesByRoutine(id);
    await dao.deleteRoutine(id);
  }

  Future<void> addExerciseToRoutine({
    required int routineId,
    required int exerciseId,
    required int sortOrder,
    int targetSets = 3,
    int targetReps = 12,
    int targetRestSeconds = 90,
  }) async {
    final dao = ref.read(routinesDaoProvider);
    await dao.insertRoutineExercise(RoutineExercisesCompanion.insert(
      routineId: routineId,
      exerciseId: exerciseId,
      sortOrder: sortOrder,
      targetSets: Value(targetSets),
      targetReps: Value(targetReps),
      targetRestSeconds: Value(targetRestSeconds),
    ));
  }

  Future<void> removeExerciseFromRoutine(int routineExerciseId) async {
    final dao = ref.read(routinesDaoProvider);
    await dao.deleteRoutineExercise(routineExerciseId);
  }
}

final routineNotifierProvider =
    NotifierProvider<RoutineNotifier, void>(RoutineNotifier.new);
