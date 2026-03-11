import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import '../../features/exercises/data/exercises_table.dart';
import '../../features/exercises/data/exercises_dao.dart';
import '../../features/routines/data/routines_table.dart';
import '../../features/routines/data/routines_dao.dart';
import '../../features/workout/data/workouts_table.dart';
import '../../features/workout/data/workouts_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Exercises,
    Routines,
    RoutineExercises,
    Workouts,
    WorkoutExercises,
    WorkoutSets,
  ],
  daos: [
    ExercisesDao,
    RoutinesDao,
    WorkoutsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      // Web uses in-memory database
      return NativeDatabase.memory();
    }
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fortia.db'));
    return NativeDatabase.createInBackground(file);
  });
}
