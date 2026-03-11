import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../domain/pr_detector.dart';

class PRCelebrationDialog extends StatelessWidget {
  const PRCelebrationDialog({super.key, required this.prs});

  final List<PersonalRecord> prs;

  static Future<void> show(BuildContext context, List<PersonalRecord> prs) {
    if (prs.isEmpty) return Future.value();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PRCelebrationDialog(prs: prs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon with animation
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber)
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .shimmer(duration: 1200.ms, delay: 400.ms),
            const SizedBox(height: 16),
            Text(
              'Novo Recorde Pessoal!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 16),
            ...prs.asMap().entries.map((entry) {
              final pr = entry.value;
              final delay = (entry.key * 200).ms;
              return ListTile(
                leading: Icon(
                  Icons.star,
                  color: Colors.amber.shade600,
                ),
                title: Text(pr.exerciseName),
                subtitle: Text(pr.description),
              )
                  .animate()
                  .fadeIn(delay: delay, duration: 300.ms)
                  .slideX(begin: 0.2, end: 0);
            }),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
