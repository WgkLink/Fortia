import 'package:flutter/material.dart';
import '../../exercises/domain/enums.dart';

class MuscleHeatmapData {
  final Map<String, int> volumeByMuscle;

  MuscleHeatmapData(this.volumeByMuscle);

  int get maxVolume {
    if (volumeByMuscle.isEmpty) return 1;
    return volumeByMuscle.values.reduce((a, b) => a > b ? a : b);
  }

  double intensityFor(String muscle) {
    final vol = volumeByMuscle[muscle] ?? 0;
    if (maxVolume == 0) return 0;
    return vol / maxVolume;
  }
}

class MuscleHeatmap extends StatelessWidget {
  const MuscleHeatmap({super.key, required this.data});

  final MuscleHeatmapData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muscles = MuscleGroup.values;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Volume Muscular da Semana',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: muscles.map((muscle) {
                final intensity = data.intensityFor(muscle.name);
                return _MuscleChip(
                  label: muscle.label,
                  intensity: intensity,
                  volume: data.volumeByMuscle[muscle.name] ?? 0,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _LegendDot(color: Colors.grey.shade800, label: 'Nenhum'),
                const SizedBox(width: 12),
                _LegendDot(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    label: 'Baixo'),
                const SizedBox(width: 12),
                _LegendDot(
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    label: 'Medio'),
                const SizedBox(width: 12),
                _LegendDot(
                    color: theme.colorScheme.primary, label: 'Alto'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  const _MuscleChip({
    required this.label,
    required this.intensity,
    required this.volume,
  });

  final String label;
  final double intensity;
  final int volume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = intensity == 0
        ? Colors.grey.shade800
        : theme.colorScheme.primary
            .withValues(alpha: 0.2 + (intensity * 0.8));

    return Tooltip(
      message: '$label: ${volume}kg',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: intensity > 0.5 ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: intensity > 0.7 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
