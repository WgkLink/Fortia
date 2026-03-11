import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../exercises/data/exercises_table.dart';
import 'routines_table.dart';

part 'routines_dao.g.dart';

class RoutineWithExercises {
  final Routine routine;
  final List<RoutineExerciseWithDetails> exercises;

  RoutineWithExercises({required this.routine, required this.exercises});
}

class RoutineExerciseWithDetails {
  final RoutineExercise routineExercise;
  final Exercise exercise;

  RoutineExerciseWithDetails({
    required this.routineExercise,
    required this.exercise,
  });
}

@DriftAccessor(tables: [Routines, RoutineExercises, Exercises])
class RoutinesDao extends DatabaseAccessor<AppDatabase>
    with _$RoutinesDaoMixin {
  RoutinesDao(super.db);

  Future<List<Routine>> getAllRoutines() => select(routines).get();

  Stream<List<Routine>> watchAllRoutines() => select(routines).watch();

  Stream<List<Routine>> watchRoutinesByDay(int dayOfWeek) {
    return (select(routines)..where((r) => r.dayOfWeek.equals(dayOfWeek)))
        .watch();
  }

  Future<Routine> getRoutineById(int id) =>
      (select(routines)..where((r) => r.id.equals(id))).getSingle();

  Future<int> insertRoutine(RoutinesCompanion routine) =>
      into(routines).insert(routine);

  Future<bool> updateRoutine(Routine routine) =>
      update(routines).replace(routine);

  Future<int> deleteRoutine(int id) =>
      (delete(routines)..where((r) => r.id.equals(id))).go();

  // Routine exercises
  Future<List<RoutineExerciseWithDetails>> getRoutineExercises(
      int routineId) async {
    final query = select(routineExercises).join([
      innerJoin(exercises, exercises.id.equalsExp(routineExercises.exerciseId)),
    ])
      ..where(routineExercises.routineId.equals(routineId))
      ..orderBy([OrderingTerm.asc(routineExercises.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) {
      return RoutineExerciseWithDetails(
        routineExercise: row.readTable(routineExercises),
        exercise: row.readTable(exercises),
      );
    }).toList();
  }

  Stream<List<RoutineExerciseWithDetails>> watchRoutineExercises(
      int routineId) {
    final query = select(routineExercises).join([
      innerJoin(exercises, exercises.id.equalsExp(routineExercises.exerciseId)),
    ])
      ..where(routineExercises.routineId.equals(routineId))
      ..orderBy([OrderingTerm.asc(routineExercises.sortOrder)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return RoutineExerciseWithDetails(
          routineExercise: row.readTable(routineExercises),
          exercise: row.readTable(exercises),
        );
      }).toList();
    });
  }

  Future<int> insertRoutineExercise(RoutineExercisesCompanion entry) =>
      into(routineExercises).insert(entry);

  Future<bool> updateRoutineExercise(RoutineExercise entry) =>
      update(routineExercises).replace(entry);

  Future<int> deleteRoutineExercise(int id) =>
      (delete(routineExercises)..where((re) => re.id.equals(id))).go();

  Future<void> deleteRoutineExercisesByRoutine(int routineId) =>
      (delete(routineExercises)
            ..where((re) => re.routineId.equals(routineId)))
          .go();

  Future<RoutineWithExercises> getRoutineWithExercises(int routineId) async {
    final routine = await getRoutineById(routineId);
    final exercisesList = await getRoutineExercises(routineId);
    return RoutineWithExercises(routine: routine, exercises: exercisesList);
  }
}
