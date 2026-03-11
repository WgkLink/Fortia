import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortia/features/exercises/presentation/exercise_library_screen.dart';

void main() {
  group('ExerciseLibraryScreen', () {
    testWidgets('renders search field', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExerciseLibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should find the search text field
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('renders with selection mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExerciseLibraryScreen(selectionMode: true),
          ),
        ),
      );

      await tester.pump();

      // Should render without errors
      expect(find.byType(ExerciseLibraryScreen), findsOneWidget);
    });
  });
}
