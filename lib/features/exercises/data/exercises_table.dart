import 'package:drift/drift.dart';

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get primaryMuscleGroup => text()();
  TextColumn get secondaryMuscleGroups => text().withDefault(const Constant(''))();
  TextColumn get equipmentType => text()();
  TextColumn get category => text()();
  TextColumn get instructions => text().withDefault(const Constant(''))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}
