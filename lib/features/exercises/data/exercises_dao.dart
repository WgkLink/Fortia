import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import 'exercises_table.dart';

part 'exercises_dao.g.dart';

@DriftAccessor(tables: [Exercises])
class ExercisesDao extends DatabaseAccessor<AppDatabase>
    with _$ExercisesDaoMixin {
  ExercisesDao(super.db);

  Future<List<Exercise>> getAllExercises() => select(exercises).get();

  Stream<List<Exercise>> watchAllExercises() => select(exercises).watch();

  Future<Exercise> getExerciseById(int id) =>
      (select(exercises)..where((e) => e.id.equals(id))).getSingle();

  Stream<List<Exercise>> watchExercisesByMuscleGroup(String muscleGroup) {
    return (select(exercises)
          ..where((e) => e.primaryMuscleGroup.equals(muscleGroup)))
        .watch();
  }

  Future<List<Exercise>> searchExercises(String query) {
    return (select(exercises)
          ..where((e) => e.name.like('%$query%')))
        .get();
  }

  Future<int> insertExercise(ExercisesCompanion exercise) =>
      into(exercises).insert(exercise);

  Future<bool> updateExercise(Exercise exercise) =>
      update(exercises).replace(exercise);

  Future<int> deleteExercise(int id) =>
      (delete(exercises)..where((e) => e.id.equals(id))).go();

  Future<void> insertMultipleExercises(List<ExercisesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(exercises, entries);
    });
  }
}
