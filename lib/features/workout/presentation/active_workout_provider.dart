import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../data/workouts_table.dart';
import '../domain/enums.dart';

class ActiveSet {
  final int sortOrder;
  double weightKg;
  int reps;
  SetType setType;
  int restSeconds;
  bool isCompleted;
  double? rpe;

  // Previous performance
  final double? previousWeight;
  final int? previousReps;

  ActiveSet({
    required this.sortOrder,
    this.weightKg = 0,
    this.reps = 0,
    this.setType = SetType.normal,
    this.restSeconds = 90,
    this.isCompleted = false,
    this.rpe,
    this.previousWeight,
    this.previousReps,
  });

  ActiveSet copyWith({
    int? sortOrder,
    double? weightKg,
    int? reps,
    SetType? setType,
    int? restSeconds,
    bool? isCompleted,
    double? rpe,
  }) {
    return ActiveSet(
      sortOrder: sortOrder ?? this.sortOrder,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      setType: setType ?? this.setType,
      restSeconds: restSeconds ?? this.restSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      rpe: rpe ?? this.rpe,
      previousWeight: previousWeight,
      previousReps: previousReps,
    );
  }
}

class ActiveExercise {
  final int exerciseId;
  final String exerciseName;
  final int sortOrder;
  final List<ActiveSet> sets;
  final String? supersetGroup;
  String notes;

  ActiveExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sortOrder,
    required this.sets,
    this.supersetGroup,
    this.notes = '',
  });
}

class ActiveWorkoutState {
  final int? workoutId;
  final int? routineId;
  final String name;
  final DateTime startedAt;
  final List<ActiveExercise> exercises;
  final bool isFinishing;

  ActiveWorkoutState({
    this.workoutId,
    this.routineId,
    required this.name,
    required this.startedAt,
    required this.exercises,
    this.isFinishing = false,
  });

  int get elapsedSeconds =>
      DateTime.now().difference(startedAt).inSeconds;

  ActiveWorkoutState copyWith({
    int? workoutId,
    String? name,
    List<ActiveExercise>? exercises,
    bool? isFinishing,
  }) {
    return ActiveWorkoutState(
      workoutId: workoutId ?? this.workoutId,
      routineId: routineId,
      name: name ?? this.name,
      startedAt: startedAt,
      exercises: exercises ?? this.exercises,
      isFinishing: isFinishing ?? this.isFinishing,
    );
  }
}

class ActiveWorkoutNotifier extends AutoDisposeNotifier<ActiveWorkoutState?> {
  @override
  ActiveWorkoutState? build() => null;

  Future<void> startWorkout({int? routineId}) async {
    final name = 'Treino';
    final exercises = <ActiveExercise>[];

    if (routineId != null) {
      final dao = ref.read(routinesDaoProvider);
      final routine = await dao.getRoutineWithExercises(routineId);
      final workoutsDao = ref.read(workoutsDaoProvider);

      for (final (index, re) in routine.exercises.indexed) {
        final previousSets = await workoutsDao.getPreviousSetsForExercise(
            re.exercise.id, null);

        final sets = List.generate(re.routineExercise.targetSets, (i) {
          final prev = i < previousSets.length ? previousSets[i] : null;
          return ActiveSet(
            sortOrder: i,
            restSeconds: re.routineExercise.targetRestSeconds,
            previousWeight: prev?.weightKg,
            previousReps: prev?.reps,
          );
        });

        exercises.add(ActiveExercise(
          exerciseId: re.exercise.id,
          exerciseName: re.exercise.name,
          sortOrder: index,
          sets: sets,
          notes: re.routineExercise.notes,
        ));
      }
    }

    // Create workout record in DB
    final workoutsDao = ref.read(workoutsDaoProvider);
    final workoutId = await workoutsDao.insertWorkout(
      WorkoutsCompanion.insert(
        routineId: Value(routineId),
        name: routineId != null ? name : 'Treino Rapido',
        startedAt: DateTime.now(),
      ),
    );

    state = ActiveWorkoutState(
      workoutId: workoutId,
      routineId: routineId,
      name: routineId != null ? name : 'Treino Rapido',
      startedAt: DateTime.now(),
      exercises: exercises,
    );
  }

  void addExercise(Exercise exercise) {
    if (state == null) return;
    final exercises = [...state!.exercises];
    exercises.add(ActiveExercise(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      sortOrder: exercises.length,
      sets: [ActiveSet(sortOrder: 0)],
    ));
    state = state!.copyWith(exercises: exercises);
  }

  void addSet(int exerciseIndex) {
    if (state == null) return;
    final exercises = [...state!.exercises];
    final exercise = exercises[exerciseIndex];
    exercise.sets.add(ActiveSet(sortOrder: exercise.sets.length));
    state = state!.copyWith(exercises: exercises);
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (state == null) return;
    final exercises = [...state!.exercises];
    exercises[exerciseIndex].sets.removeAt(setIndex);
    state = state!.copyWith(exercises: exercises);
  }

  void updateSet(int exerciseIndex, int setIndex,
      {double? weight, int? reps, SetType? setType, bool? isCompleted}) {
    if (state == null) return;
    final exercises = [...state!.exercises];
    final set_ = exercises[exerciseIndex].sets[setIndex];

    exercises[exerciseIndex].sets[setIndex] = set_.copyWith(
      weightKg: weight,
      reps: reps,
      setType: setType,
      isCompleted: isCompleted,
    );
    state = state!.copyWith(exercises: exercises);
  }

  void toggleSetCompleted(int exerciseIndex, int setIndex) {
    if (state == null) return;
    final set_ = state!.exercises[exerciseIndex].sets[setIndex];
    updateSet(exerciseIndex, setIndex, isCompleted: !set_.isCompleted);

    // Start rest timer if completing a set
    if (!set_.isCompleted) {
      ref.read(restTimerProvider.notifier).start(set_.restSeconds);
    }
  }

  void removeExercise(int exerciseIndex) {
    if (state == null) return;
    final exercises = [...state!.exercises];
    exercises.removeAt(exerciseIndex);
    state = state!.copyWith(exercises: exercises);
  }

  /// Finishes the workout, saves to DB, returns the workout ID for PR detection.
  Future<int?> finishWorkout() async {
    if (state == null) return null;
    state = state!.copyWith(isFinishing: true);
    final workoutId = state!.workoutId!;

    try {
      final workoutsDao = ref.read(workoutsDaoProvider);
      final now = DateTime.now();
      final duration = now.difference(state!.startedAt).inSeconds;

      // Update workout record
      final workout = await workoutsDao.getWorkoutById(workoutId);
      await workoutsDao.updateWorkout(workout.copyWith(
        finishedAt: Value(now),
        durationSeconds: duration,
      ));

      // Save exercises and sets
      for (final exercise in state!.exercises) {
        final weId = await workoutsDao.insertWorkoutExercise(
          WorkoutExercisesCompanion.insert(
            workoutId: workoutId,
            exerciseId: exercise.exerciseId,
            sortOrder: exercise.sortOrder,
            supersetGroup: Value(exercise.supersetGroup),
          ),
        );

        for (final set_ in exercise.sets) {
          await workoutsDao.insertWorkoutSet(
            WorkoutSetsCompanion.insert(
              workoutExerciseId: weId,
              sortOrder: set_.sortOrder,
              weightKg: Value(set_.weightKg),
              reps: Value(set_.reps),
              setType: Value(set_.setType.name),
              restSeconds: Value(set_.restSeconds),
              isCompleted: Value(set_.isCompleted),
              rpe: Value(set_.rpe),
            ),
          );
        }
      }

      state = null;
      return workoutId;
    } catch (e) {
      state = state!.copyWith(isFinishing: false);
      rethrow;
    }
  }

  Future<void> discardWorkout() async {
    if (state?.workoutId != null) {
      final workoutsDao = ref.read(workoutsDaoProvider);
      await workoutsDao.deleteWorkout(state!.workoutId!);
    }
    state = null;
  }
}

final activeWorkoutProvider =
    AutoDisposeNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState?>(
        ActiveWorkoutNotifier.new);

// Rest Timer
class RestTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;

  const RestTimerState({
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
    this.isRunning = false,
  });
}

class RestTimerNotifier extends AutoDisposeNotifier<RestTimerState> {
  Timer? _timer;

  @override
  RestTimerState build() {
    ref.onDispose(() => _timer?.cancel());
    return const RestTimerState();
  }

  void start(int seconds) {
    _timer?.cancel();
    state = RestTimerState(
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isRunning: true,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 0) {
        _timer?.cancel();
        state = const RestTimerState();
        return;
      }
      state = RestTimerState(
        totalSeconds: state.totalSeconds,
        remainingSeconds: state.remainingSeconds - 1,
        isRunning: true,
      );
    });
  }

  void stop() {
    _timer?.cancel();
    state = const RestTimerState();
  }

  void addTime(int seconds) {
    if (!state.isRunning) return;
    state = RestTimerState(
      totalSeconds: state.totalSeconds + seconds,
      remainingSeconds: state.remainingSeconds + seconds,
      isRunning: true,
    );
  }
}

final restTimerProvider =
    AutoDisposeNotifierProvider<RestTimerNotifier, RestTimerState>(
        RestTimerNotifier.new);

// Workout duration timer
final workoutDurationProvider = StreamProvider.autoDispose<int>((ref) {
  final workout = ref.watch(activeWorkoutProvider);
  if (workout == null) return const Stream.empty();

  return Stream.periodic(const Duration(seconds: 1), (_) {
    return DateTime.now().difference(workout.startedAt).inSeconds;
  });
});
