import '../../../core/database/app_database.dart';

class OverloadSuggestion {
  final String exerciseName;
  final double suggestedWeight;
  final int suggestedReps;
  final String reason;

  OverloadSuggestion({
    required this.exerciseName,
    required this.suggestedWeight,
    required this.suggestedReps,
    required this.reason,
  });
}

class OverloadCalculator {
  /// Suggests progressive overload based on recent performance.
  /// Rules:
  /// - If all target reps were hit in last 2 sessions: increase weight by 2.5kg
  /// - If reps are improving but not at target: suggest same weight, aim higher reps
  /// - If reps decreased: suggest same weight, consolidate
  static OverloadSuggestion? suggest({
    required String exerciseName,
    required List<List<WorkoutSet>> lastSessions, // most recent first
    required int targetReps,
  }) {
    if (lastSessions.isEmpty) return null;

    final latest = lastSessions.first;
    if (latest.isEmpty) return null;

    final completedSets = latest.where((s) => s.isCompleted).toList();
    if (completedSets.isEmpty) return null;

    final avgWeight =
        completedSets.map((s) => s.weightKg).reduce((a, b) => a + b) /
            completedSets.length;
    final avgReps =
        completedSets.map((s) => s.reps).reduce((a, b) => a + b) /
            completedSets.length;

    // Check if target reps consistently hit
    final allHitTarget = completedSets.every((s) => s.reps >= targetReps);

    if (lastSessions.length >= 2) {
      final previous = lastSessions[1].where((s) => s.isCompleted).toList();
      final prevAllHit = previous.every((s) => s.reps >= targetReps);

      if (allHitTarget && prevAllHit) {
        // Two sessions hitting target -> increase weight
        final increment = avgWeight >= 40 ? 2.5 : 1.25;
        return OverloadSuggestion(
          exerciseName: exerciseName,
          suggestedWeight: avgWeight + increment,
          suggestedReps: targetReps,
          reason:
              'Reps alvo atingidas nas ultimas 2 sessoes. Aumente o peso!',
        );
      }
    }

    if (allHitTarget) {
      return OverloadSuggestion(
        exerciseName: exerciseName,
        suggestedWeight: avgWeight,
        suggestedReps: targetReps,
        reason: 'Mantenha o peso e tente manter na proxima sessao tambem.',
      );
    }

    if (avgReps < targetReps * 0.8) {
      return OverloadSuggestion(
        exerciseName: exerciseName,
        suggestedWeight: avgWeight,
        suggestedReps: targetReps,
        reason:
            'Consolide com o peso atual. Foque em atingir ${targetReps} reps.',
      );
    }

    return OverloadSuggestion(
      exerciseName: exerciseName,
      suggestedWeight: avgWeight,
      suggestedReps: targetReps,
      reason: 'Quase la! Continue com o peso atual ate atingir o alvo.',
    );
  }
}
