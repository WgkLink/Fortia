import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';

class PersonalRecord {
  final int exerciseId;
  final String exerciseName;
  final PRType type;
  final double value;
  final double? previousValue;

  PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.value,
    this.previousValue,
  });

  String get description {
    return switch (type) {
      PRType.maxWeight => '${Formatters.weight(value)} kg (Peso Maximo)',
      PRType.maxVolume =>
        '${Formatters.volume(value.round())} (Volume Maximo)',
      PRType.max1RM =>
        '${Formatters.weight(value)} kg (1RM Estimado)',
    };
  }
}

enum PRType { maxWeight, maxVolume, max1RM }

class PRDetector {
  /// Detects PRs from a completed workout by comparing against history.
  static Future<List<PersonalRecord>> detectPRs({
    required WorkoutsDao workoutsDao,
    required int workoutId,
  }) async {
    final prs = <PersonalRecord>[];
    final details = await workoutsDao.getWorkoutWithDetails(workoutId);

    for (final exerciseData in details.exercises) {
      final exerciseId = exerciseData.exercise.id;
      final completedSets =
          exerciseData.sets.where((s) => s.isCompleted).toList();
      if (completedSets.isEmpty) continue;

      // Max weight PR
      final maxWeight =
          completedSets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);
      final previousPR = await workoutsDao.getPersonalRecord(exerciseId);

      if (previousPR == null || maxWeight > previousPR.weightKg) {
        prs.add(PersonalRecord(
          exerciseId: exerciseId,
          exerciseName: exerciseData.exercise.name,
          type: PRType.maxWeight,
          value: maxWeight,
          previousValue: previousPR?.weightKg,
        ));
      }

      // Max estimated 1RM PR
      double maxE1RM = 0;
      for (final s in completedSets) {
        final e1rm = Formatters.estimated1RM(s.weightKg, s.reps);
        if (e1rm > maxE1RM) maxE1RM = e1rm;
      }

      if (previousPR != null) {
        final prevE1RM =
            Formatters.estimated1RM(previousPR.weightKg, previousPR.reps);
        if (maxE1RM > prevE1RM) {
          prs.add(PersonalRecord(
            exerciseId: exerciseId,
            exerciseName: exerciseData.exercise.name,
            type: PRType.max1RM,
            value: maxE1RM,
            previousValue: prevE1RM,
          ));
        }
      }
    }

    return prs;
  }
}
