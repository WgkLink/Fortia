import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/providers/core_providers.dart';
import 'seed/seed_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  final container = ProviderContainer();
  final db = container.read(databaseProvider);
  await seedDatabase(db);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FortiaApp(),
    ),
  );
}
