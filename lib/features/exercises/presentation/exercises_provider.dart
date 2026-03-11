import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/database/app_database.dart';

final allExercisesProvider = StreamProvider<List<Exercise>>((ref) {
  return ref.watch(exercisesDaoProvider).watchAllExercises();
});

final exerciseByIdProvider =
    FutureProvider.family<Exercise, int>((ref, id) async {
  return ref.watch(exercisesDaoProvider).getExerciseById(id);
});

final exerciseSearchProvider =
    FutureProvider.family<List<Exercise>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(exercisesDaoProvider).getAllExercises();
  }
  return ref.watch(exercisesDaoProvider).searchExercises(query);
});

final exercisesByMuscleGroupProvider =
    StreamProvider.family<List<Exercise>, String>((ref, muscleGroup) {
  return ref.watch(exercisesDaoProvider).watchExercisesByMuscleGroup(muscleGroup);
});

final selectedMuscleFilterProvider = StateProvider<String?>((ref) => null);
final selectedEquipmentFilterProvider = StateProvider<String?>((ref) => null);
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final query = ref.watch(exerciseSearchQueryProvider);
  final muscleFilter = ref.watch(selectedMuscleFilterProvider);
  final equipmentFilter = ref.watch(selectedEquipmentFilterProvider);

  var exercises = await ref.watch(exercisesDaoProvider).getAllExercises();

  if (query.isNotEmpty) {
    final lowerQuery = query.toLowerCase();
    exercises = exercises
        .where((e) => e.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  if (muscleFilter != null) {
    exercises = exercises
        .where((e) => e.primaryMuscleGroup == muscleFilter)
        .toList();
  }

  if (equipmentFilter != null) {
    exercises = exercises
        .where((e) => e.equipmentType == equipmentFilter)
        .toList();
  }

  return exercises;
});
