import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../exercises/data/exercises_table.dart';
import '../../routines/data/routines_table.dart';
import 'workouts_table.dart';

part 'workouts_dao.g.dart';

class WorkoutWithDetails {
  final Workout workout;
  final List<WorkoutExerciseWithSets> exercises;

  WorkoutWithDetails({required this.workout, required this.exercises});

  int get totalVolume {
    var vol = 0.0;
    for (final ex in exercises) {
      for (final s in ex.sets) {
        if (s.isCompleted) {
          vol += s.weightKg * s.reps;
        }
      }
    }
    return vol.round();
  }

  int get totalSetsCompleted {
    var count = 0;
    for (final ex in exercises) {
      for (final s in ex.sets) {
        if (s.isCompleted) count++;
      }
    }
    return count;
  }
}

class WorkoutExerciseWithSets {
  final WorkoutExercise workoutExercise;
  final Exercise exercise;
  final List<WorkoutSet> sets;

  WorkoutExerciseWithSets({
    required this.workoutExercise,
    required this.exercise,
    required this.sets,
  });
}

@DriftAccessor(
    tables: [Workouts, WorkoutExercises, WorkoutSets, Exercises, Routines])
class WorkoutsDao extends DatabaseAccessor<AppDatabase>
    with _$WorkoutsDaoMixin {
  WorkoutsDao(super.db);

  // Workouts
  Future<List<Workout>> getAllWorkouts() =>
      (select(workouts)..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
          .get();

  Stream<List<Workout>> watchAllWorkouts() =>
      (select(workouts)..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
          .watch();

  Stream<List<Workout>> watchRecentWorkouts({int limit = 10}) {
    return (select(workouts)
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)])
          ..limit(limit))
        .watch();
  }

  Future<Workout> getWorkoutById(int id) =>
      (select(workouts)..where((w) => w.id.equals(id))).getSingle();

  Future<int> insertWorkout(WorkoutsCompanion workout) =>
      into(workouts).insert(workout);

  Future<bool> updateWorkout(Workout workout) =>
      update(workouts).replace(workout);

  Future<int> deleteWorkout(int id) =>
      (delete(workouts)..where((w) => w.id.equals(id))).go();

  // Workout exercises
  Future<int> insertWorkoutExercise(WorkoutExercisesCompanion entry) =>
      into(workoutExercises).insert(entry);

  Future<void> deleteWorkoutExercisesByWorkout(int workoutId) =>
      (delete(workoutExercises)..where((we) => we.workoutId.equals(workoutId)))
          .go();

  // Workout sets
  Future<int> insertWorkoutSet(WorkoutSetsCompanion entry) =>
      into(workoutSets).insert(entry);

  Future<bool> updateWorkoutSet(WorkoutSet entry) =>
      update(workoutSets).replace(entry);

  Future<void> deleteWorkoutSetsByExercise(int workoutExerciseId) =>
      (delete(workoutSets)
            ..where((ws) => ws.workoutExerciseId.equals(workoutExerciseId)))
          .go();

  // Full workout details
  Future<WorkoutWithDetails> getWorkoutWithDetails(int workoutId) async {
    final workout = await getWorkoutById(workoutId);

    final exerciseQuery = select(workoutExercises).join([
      innerJoin(
          exercises, exercises.id.equalsExp(workoutExercises.exerciseId)),
    ])
      ..where(workoutExercises.workoutId.equals(workoutId))
      ..orderBy([OrderingTerm.asc(workoutExercises.sortOrder)]);

    final exerciseRows = await exerciseQuery.get();

    final exercisesWithSets = <WorkoutExerciseWithSets>[];
    for (final row in exerciseRows) {
      final we = row.readTable(workoutExercises);
      final ex = row.readTable(exercises);

      final sets = await (select(workoutSets)
            ..where((s) => s.workoutExerciseId.equals(we.id))
            ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
          .get();

      exercisesWithSets.add(WorkoutExerciseWithSets(
        workoutExercise: we,
        exercise: ex,
        sets: sets,
      ));
    }

    return WorkoutWithDetails(workout: workout, exercises: exercisesWithSets);
  }

  // Previous performance for an exercise
  Future<List<WorkoutSet>> getPreviousSetsForExercise(
      int exerciseId, int? excludeWorkoutId) async {
    final weQuery = select(workoutExercises).join([
      innerJoin(workouts, workouts.id.equalsExp(workoutExercises.workoutId)),
    ])
      ..where(workoutExercises.exerciseId.equals(exerciseId) &
          workouts.finishedAt.isNotNull())
      ..orderBy([OrderingTerm.desc(workouts.startedAt)])
      ..limit(1);

    if (excludeWorkoutId != null) {
      weQuery.where(workouts.id.equals(excludeWorkoutId).not());
    }

    final weRows = await weQuery.get();
    if (weRows.isEmpty) return [];

    final weId = weRows.first.readTable(workoutExercises).id;
    return (select(workoutSets)
          ..where((s) => s.workoutExerciseId.equals(weId))
          ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
        .get();
  }

  // Stats
  Future<List<Workout>> getWorkoutsInRange(
      DateTime start, DateTime end) async {
    return (select(workouts)
          ..where((w) =>
              w.startedAt.isBiggerOrEqualValue(start) &
              w.startedAt.isSmallerOrEqualValue(end) &
              w.finishedAt.isNotNull())
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
        .get();
  }

  // Personal records for an exercise
  Future<WorkoutSet?> getPersonalRecord(int exerciseId) async {
    final query = select(workoutSets).join([
      innerJoin(workoutExercises,
          workoutExercises.id.equalsExp(workoutSets.workoutExerciseId)),
    ])
      ..where(workoutExercises.exerciseId.equals(exerciseId) &
          workoutSets.isCompleted.equals(true))
      ..orderBy([OrderingTerm.desc(workoutSets.weightKg)])
      ..limit(1);

    final rows = await query.get();
    if (rows.isEmpty) return null;
    return rows.first.readTable(workoutSets);
  }

  // Exercise history (for progress charts)
  Future<List<({DateTime date, double maxWeight, int maxReps})>>
      getExerciseHistory(int exerciseId) async {
    final query = select(workoutSets).join([
      innerJoin(workoutExercises,
          workoutExercises.id.equalsExp(workoutSets.workoutExerciseId)),
      innerJoin(workouts, workouts.id.equalsExp(workoutExercises.workoutId)),
    ])
      ..where(workoutExercises.exerciseId.equals(exerciseId) &
          workoutSets.isCompleted.equals(true) &
          workouts.finishedAt.isNotNull())
      ..orderBy([OrderingTerm.asc(workouts.startedAt)]);

    final rows = await query.get();

    final Map<DateTime, ({double maxWeight, int maxReps})> grouped = {};
    for (final row in rows) {
      final workout = row.readTable(workouts);
      final set_ = row.readTable(workoutSets);
      final date = DateTime(
        workout.startedAt.year,
        workout.startedAt.month,
        workout.startedAt.day,
      );

      final existing = grouped[date];
      if (existing == null || set_.weightKg > existing.maxWeight) {
        grouped[date] = (maxWeight: set_.weightKg, maxReps: set_.reps);
      }
    }

    return grouped.entries
        .map((e) => (date: e.key, maxWeight: e.value.maxWeight, maxReps: e.value.maxReps))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
