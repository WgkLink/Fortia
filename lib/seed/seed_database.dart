import '../core/database/app_database.dart';
import 'exercise_seeds.dart';

Future<void> seedDatabase(AppDatabase db) async {
  final existing = await db.exercisesDao.getAllExercises();
  if (existing.isNotEmpty) return;
  await db.exercisesDao.insertMultipleExercises(exerciseSeeds);
}
