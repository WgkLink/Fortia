import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortia/core/widgets/app_shell.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppShell', () {
    testWidgets('renders navigation bar with 4 destinations', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) => AppShell(child: child),
            routes: [
              GoRoute(
                  path: '/home',
                  builder: (_, __) => const Text('Home')),
              GoRoute(
                  path: '/history',
                  builder: (_, __) => const Text('History')),
              GoRoute(
                  path: '/routines',
                  builder: (_, __) => const Text('Routines')),
              GoRoute(
                  path: '/progress',
                  builder: (_, __) => const Text('Progress')),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Historico'), findsOneWidget);
      expect(find.text('Rotinas'), findsOneWidget);
      expect(find.text('Progresso'), findsOneWidget);
    });
  });
}
