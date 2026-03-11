import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/exercises/presentation/exercise_library_screen.dart';
import '../../features/exercises/presentation/exercise_detail_screen.dart';
import '../../features/exercises/presentation/exercise_progress_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/workout_detail_screen.dart';
import '../../features/progress/presentation/progress_dashboard_screen.dart';
import '../../features/routines/presentation/routines_list_screen.dart';
import '../../features/routines/presentation/routine_editor_screen.dart';
import '../../features/routines/presentation/routine_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/workout/presentation/active_workout_screen.dart';
import '../../features/workout/presentation/screens/home_screen.dart';
import '../widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/routines',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RoutinesListScreen(),
            ),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProgressDashboardScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/workout/active',
        builder: (context, state) {
          final routineId = state.uri.queryParameters['routineId'];
          return ActiveWorkoutScreen(
            routineId: routineId != null ? int.parse(routineId) : null,
          );
        },
      ),
      GoRoute(
        path: '/workout/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return WorkoutDetailScreen(workoutId: id);
        },
      ),
      GoRoute(
        path: '/routines/new',
        builder: (context, state) => const RoutineEditorScreen(),
      ),
      GoRoute(
        path: '/routines/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return RoutineEditorScreen(routineId: id);
        },
      ),
      GoRoute(
        path: '/routines/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return RoutineDetailScreen(routineId: id);
        },
      ),
      GoRoute(
        path: '/exercises',
        builder: (context, state) => const ExerciseLibraryScreen(),
      ),
      GoRoute(
        path: '/exercises/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ExerciseDetailScreen(exerciseId: id);
        },
      ),
      GoRoute(
        path: '/exercises/:id/progress',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ExerciseProgressScreen(exerciseId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
