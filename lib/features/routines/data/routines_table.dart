import 'package:drift/drift.dart';
import '../../exercises/data/exercises_table.dart';

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get dayOfWeek => integer().check(dayOfWeek.isBetweenValues(1, 7))();
  TextColumn get colorHex => text().withDefault(const Constant('FF6C63FF'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class RoutineExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().references(Routines, #id)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get sortOrder => integer()();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  IntColumn get targetReps => integer().withDefault(const Constant(12))();
  IntColumn get targetRestSeconds => integer().withDefault(const Constant(90))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}
