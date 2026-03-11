import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/formatters.dart';
import 'muscle_heatmap.dart';
import 'streak_graph.dart';

// Weekly volume data
final weeklyVolumeProvider = FutureProvider<List<({String label, int volume})>>((ref) async {
  final dao = ref.watch(workoutsDaoProvider);
  final now = DateTime.now();
  final results = <({String label, int volume})>[];

  for (var i = 3; i >= 0; i--) {
    final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final workouts = await dao.getWorkoutsInRange(weekStart, weekEnd);

    var totalVolume = 0;
    for (final w in workouts) {
      final details = await dao.getWorkoutWithDetails(w.id);
      totalVolume += details.totalVolume;
    }

    results.add((
      label: '${weekStart.day}/${weekStart.month}',
      volume: totalVolume,
    ));
  }

  return results;
});

// Training streak
final trainingStreakProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(workoutsDaoProvider);
  final workouts = await dao.getAllWorkouts();
  final completed = workouts.where((w) => w.finishedAt != null).toList();
  if (completed.isEmpty) return 0;

  var streak = 0;
  var currentDate = DateTime.now();

  while (true) {
    final dayStart = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final hasWorkout = completed.any((w) =>
        w.startedAt.isAfter(dayStart) && w.startedAt.isBefore(dayEnd));

    if (!hasWorkout && streak > 0) break;
    if (hasWorkout) streak++;

    currentDate = currentDate.subtract(const Duration(days: 1));
    if (currentDate.isBefore(completed.last.startedAt.subtract(const Duration(days: 1)))) break;
  }

  return streak;
});

// Workout count last 30 days
final recentWorkoutCountProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(workoutsDaoProvider);
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  final workouts = await dao.getWorkoutsInRange(thirtyDaysAgo, now);
  return workouts.length;
});

// Workout dates for streak graph
final workoutDatesProvider = FutureProvider<Set<DateTime>>((ref) async {
  final dao = ref.watch(workoutsDaoProvider);
  final workouts = await dao.getAllWorkouts();
  return workouts
      .where((w) => w.finishedAt != null)
      .map((w) => DateTime(w.startedAt.year, w.startedAt.month, w.startedAt.day))
      .toSet();
});

// Muscle volume heatmap data
final muscleHeatmapProvider = FutureProvider<MuscleHeatmapData>((ref) async {
  final dao = ref.watch(workoutsDaoProvider);
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));
  final workouts = await dao.getWorkoutsInRange(weekStart, weekEnd);

  final volumeByMuscle = <String, int>{};
  for (final w in workouts) {
    final details = await dao.getWorkoutWithDetails(w.id);
    for (final ex in details.exercises) {
      final muscle = ex.exercise.primaryMuscleGroup;
      var vol = 0.0;
      for (final s in ex.sets) {
        if (s.isCompleted) vol += s.weightKg * s.reps;
      }
      volumeByMuscle[muscle] = (volumeByMuscle[muscle] ?? 0) + vol.round();
    }
  }

  return MuscleHeatmapData(volumeByMuscle);
});

class ProgressDashboardScreen extends ConsumerWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weeklyVolume = ref.watch(weeklyVolumeProvider);
    final streak = ref.watch(trainingStreakProvider);
    final workoutCount = ref.watch(recentWorkoutCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progresso')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Streak',
                  value: streak.when(
                    data: (s) => '$s dias',
                    loading: () => '...',
                    error: (_, __) => '-',
                  ),
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Treinos (30d)',
                  value: workoutCount.when(
                    data: (c) => '$c',
                    loading: () => '...',
                    error: (_, __) => '-',
                  ),
                  icon: Icons.fitness_center,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Weekly volume chart
          Text('Volume Semanal (kg)',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          weeklyVolume.when(
            data: (data) {
              if (data.every((d) => d.volume == 0)) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Dados insuficientes'),
                    ),
                  ),
                );
              }

              final maxY = data
                  .map((d) => d.volume.toDouble())
                  .reduce((a, b) => a > b ? a : b);

              return SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            Formatters.volume(rod.toY.round()),
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= data.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(data[idx].label,
                                  style: const TextStyle(fontSize: 10)),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: data.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.volume.toDouble(),
                            color: theme.colorScheme.primary,
                            width: 24,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Erro: $e'),
          ),

          const SizedBox(height: 24),

          // Streak graph
          ref.watch(workoutDatesProvider).when(
                data: (dates) => StreakGraph(workoutDates: dates),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

          const SizedBox(height: 16),

          // Muscle heatmap
          ref.watch(muscleHeatmapProvider).when(
                data: (data) => MuscleHeatmap(data: data),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

          const SizedBox(height: 24),

          // Exercise library link for individual progress
          Text('Progresso por Exercicio',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar Exercicio'),
              subtitle: const Text('Ver grafico de peso ao longo do tempo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/exercises'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context).textTheme.headlineSmall),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
