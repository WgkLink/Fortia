import 'package:drift/drift.dart';
import '../../exercises/data/exercises_table.dart';
import '../../routines/data/routines_table.dart';

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().nullable().references(Routines, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId => integer().references(Workouts, #id)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get sortOrder => integer()();
  TextColumn get supersetGroup => text().nullable()();
}

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutExerciseId => integer().references(WorkoutExercises, #id)();
  IntColumn get sortOrder => integer()();
  RealColumn get weightKg => real().withDefault(const Constant(0.0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  TextColumn get setType => text().withDefault(const Constant('normal'))();
  IntColumn get restSeconds => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  RealColumn get rpe => real().nullable()();
}
