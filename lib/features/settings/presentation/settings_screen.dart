import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final weightUnitProvider = StateProvider<String>((ref) => 'kg');
final defaultRestSecondsProvider = StateProvider<int>((ref) => 90);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightUnit = ref.watch(weightUnitProvider);
    final defaultRest = ref.watch(defaultRestSecondsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracoes')),
      body: ListView(
        children: [
          const _SectionHeader('Unidades'),
          ListTile(
            title: const Text('Unidade de Peso'),
            subtitle: Text(weightUnit == 'kg' ? 'Quilogramas' : 'Libras'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'kg', label: Text('kg')),
                ButtonSegment(value: 'lbs', label: Text('lbs')),
              ],
              selected: {weightUnit},
              onSelectionChanged: (value) {
                ref.read(weightUnitProvider.notifier).state = value.first;
              },
            ),
          ),

          const _SectionHeader('Timer'),
          ListTile(
            title: const Text('Descanso Padrao'),
            subtitle: Text('$defaultRest segundos'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: defaultRest.toDouble(),
                min: 30,
                max: 300,
                divisions: 27,
                label: '${defaultRest}s',
                onChanged: (value) {
                  ref.read(defaultRestSecondsProvider.notifier).state =
                      value.round();
                },
              ),
            ),
          ),

          const _SectionHeader('Dados'),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Exportar Dados (JSON)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Em breve!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Exportar Dados (CSV)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Em breve!'),
                ),
              );
            },
          ),

          const _SectionHeader('Sobre'),
          const ListTile(
            title: Text('Fortia'),
            subtitle: Text('v1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
