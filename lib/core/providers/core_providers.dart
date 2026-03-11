import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../../features/exercises/data/exercises_dao.dart';
import '../../features/routines/data/routines_dao.dart';
import '../../features/workout/data/workouts_dao.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final exercisesDaoProvider = Provider<ExercisesDao>((ref) {
  return ref.watch(databaseProvider).exercisesDao;
});

final routinesDaoProvider = Provider<RoutinesDao>((ref) {
  return ref.watch(databaseProvider).routinesDao;
});

final workoutsDaoProvider = Provider<WorkoutsDao>((ref) {
  return ref.watch(databaseProvider).workoutsDao;
});
