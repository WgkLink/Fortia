import 'package:flutter_test/flutter_test.dart';
import 'package:fortia/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('duration', () {
      test('formats seconds only', () {
        expect(Formatters.duration(45), '0m 45s');
      });

      test('formats minutes and seconds', () {
        expect(Formatters.duration(125), '2m 05s');
      });

      test('formats hours and minutes', () {
        expect(Formatters.duration(3725), '1h 02m');
      });

      test('formats zero', () {
        expect(Formatters.duration(0), '0m 00s');
      });
    });

    group('weight', () {
      test('formats whole number', () {
        expect(Formatters.weight(100.0), '100');
      });

      test('formats decimal', () {
        expect(Formatters.weight(52.5), '52.5');
      });
    });

    group('volume', () {
      test('formats under 1000', () {
        expect(Formatters.volume(500), '500kg');
      });

      test('formats over 1000 as tonnes', () {
        expect(Formatters.volume(1500), '1.5t');
      });
    });

    group('dayOfWeek', () {
      test('returns correct day names', () {
        expect(Formatters.dayOfWeek(1), 'Segunda');
        expect(Formatters.dayOfWeek(7), 'Domingo');
      });

      test('returns short day names', () {
        expect(Formatters.dayOfWeekShort(1), 'Seg');
        expect(Formatters.dayOfWeekShort(6), 'Sab');
      });
    });

    group('estimated1RM', () {
      test('returns weight for 1 rep', () {
        expect(Formatters.estimated1RM(100, 1), 100.0);
      });

      test('calculates Epley formula', () {
        // 100 * (1 + 10/30) = 100 * 1.333 = 133.3
        expect(Formatters.estimated1RM(100, 10), closeTo(133.3, 0.1));
      });

      test('returns 0 for invalid input', () {
        expect(Formatters.estimated1RM(0, 10), 0);
        expect(Formatters.estimated1RM(100, 0), 0);
      });
    });
  });
}
