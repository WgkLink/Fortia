import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/formatters.dart';
import 'exercises_provider.dart';

final exerciseHistoryProvider = FutureProvider.family<
    List<({DateTime date, double maxWeight, int maxReps})>, int>((ref, id) {
  return ref.watch(workoutsDaoProvider).getExerciseHistory(id);
});

class ExerciseProgressScreen extends ConsumerWidget {
  const ExerciseProgressScreen({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseByIdProvider(exerciseId));
    final historyAsync = ref.watch(exerciseHistoryProvider(exerciseId));

    return Scaffold(
      appBar: AppBar(
        title: exerciseAsync.when(
          data: (e) => Text(e.name),
          loading: () => const Text('Progresso'),
          error: (_, __) => const Text('Progresso'),
        ),
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Text('Nenhum dado de progresso ainda'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Peso Maximo ao Longo do Tempo',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= history.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              DateFormat('dd/MM').format(history[idx].date),
                              style: const TextStyle(fontSize: 9),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: history
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                e.key.toDouble(), e.value.maxWeight))
                            .toList(),
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('1RM Estimado',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= history.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              DateFormat('dd/MM').format(history[idx].date),
                              style: const TextStyle(fontSize: 9),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: history
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                e.key.toDouble(),
                                Formatters.estimated1RM(
                                    e.value.maxWeight, e.value.maxReps)))
                            .toList(),
                        isCurved: true,
                        color: Theme.of(context).colorScheme.secondary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Historico', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...history.reversed.map((entry) => ListTile(
                    title: Text(
                        '${Formatters.weight(entry.maxWeight)} kg x ${entry.maxReps} reps'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(entry.date)),
                    trailing: Text(
                      '1RM: ${Formatters.weight(Formatters.estimated1RM(entry.maxWeight, entry.maxReps))} kg',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
