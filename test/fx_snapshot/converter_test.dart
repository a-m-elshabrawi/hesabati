import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_unicode/features/fx_snapshot/domain/converter.dart';

void main() {
  group('CurrencyConverter Tests', () {
    // Test data with relative rates (KWD = 1.0)
    const Map<String, double> testRates = {
      'USD': 3.26,
      'EUR': 3.00,
      'KWD': 1.00,
      'JPY': 488.60,
    };

    group('Basic Conversion Tests', () {
      test('convert EUR to KWD', () {
        final result = CurrencyConverter.convert(testRates, 'EUR', 'KWD', 1);
        const expected = 1.00 / 3.00; // rates[KWD] / rates[EUR]
        expect(result, closeTo(expected, 0.0001));
      });

      test('convert KWD to EUR', () {
        final result = CurrencyConverter.convert(testRates, 'KWD', 'EUR', 1);
        const expected = 3.00 / 1.00; // rates[EUR] / rates[KWD]
        expect(result, closeTo(expected, 0.0001));
      });

      test('convert USD to JPY', () {
        final result = CurrencyConverter.convert(testRates, 'USD', 'JPY', 1);
        const expected = 488.60 / 3.26; // rates[JPY] / rates[USD]
        expect(result, closeTo(expected, 0.0001));
      });

      test('convert JPY to USD', () {
        final result = CurrencyConverter.convert(testRates, 'JPY', 'USD', 1);
        const expected = 3.26 / 488.60; // rates[USD] / rates[JPY]
        expect(result, closeTo(expected, 0.0001));
      });

      test('convert same currency returns same amount', () {
        final result = CurrencyConverter.convert(testRates, 'USD', 'USD', 100);
        expect(result, equals(100));
      });
    });

    group('Rate Calculation Tests', () {
      test('getRate EUR to KWD', () {
        final rate = CurrencyConverter.getRate(testRates, 'EUR', 'KWD');
        const expected = 1.00 / 3.00;
        expect(rate, closeTo(expected, 0.0001));
      });

      test('getRate KWD to EUR', () {
        final rate = CurrencyConverter.getRate(testRates, 'KWD', 'EUR');
        const expected = 3.00 / 1.00;
        expect(rate, closeTo(expected, 0.0001));
      });

      test('getRate same currency returns 1', () {
        final rate = CurrencyConverter.getRate(testRates, 'USD', 'USD');
        expect(rate, equals(1.0));
      });
    });

    group('Mathematical Consistency Tests', () {
      test('EUR to KWD to EUR consistency', () {
        final isValid = CurrencyConverter.validateConsistency(testRates, 'EUR', 'KWD', 100);
        expect(isValid, isTrue);
      });

      test('KWD to EUR to KWD consistency', () {
        final isValid = CurrencyConverter.validateConsistency(testRates, 'KWD', 'EUR', 50);
        expect(isValid, isTrue);
      });

      test('USD to JPY to USD consistency', () {
        final isValid = CurrencyConverter.validateConsistency(testRates, 'USD', 'JPY', 10);
        expect(isValid, isTrue);
      });

      test('JPY to USD to JPY consistency', () {
        final isValid = CurrencyConverter.validateConsistency(testRates, 'JPY', 'USD', 1000);
        expect(isValid, isTrue);
      });
    });

    group('Error Handling Tests', () {
      test('throws error for unknown source currency', () {
        expect(
          () => CurrencyConverter.convert(testRates, 'UNKNOWN', 'USD', 1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws error for unknown target currency', () {
        expect(
          () => CurrencyConverter.convert(testRates, 'USD', 'UNKNOWN', 1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws error for NaN amount', () {
        expect(
          () => CurrencyConverter.convert(testRates, 'USD', 'EUR', double.nan),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws error for infinite amount', () {
        expect(
          () => CurrencyConverter.convert(testRates, 'USD', 'EUR', double.infinity),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws error for negative amount', () {
        expect(
          () => CurrencyConverter.convert(testRates, 'USD', 'EUR', -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws error for zero source rate', () {
        final ratesWithZero = Map<String, double>.from(testRates);
        ratesWithZero['ZERO'] = 0.0;
        
        expect(
          () => CurrencyConverter.convert(ratesWithZero, 'ZERO', 'USD', 1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Edge Cases', () {
      test('convert zero amount', () {
        final result = CurrencyConverter.convert(testRates, 'USD', 'EUR', 0);
        expect(result, equals(0));
      });

      test('convert very small amount', () {
        final result = CurrencyConverter.convert(testRates, 'USD', 'EUR', 0.0001);
        const expected = 0.0001 * (3.00 / 3.26);
        expect(result, closeTo(expected, 1e-10));
      });

      test('convert very large amount', () {
        final result = CurrencyConverter.convert(testRates, 'USD', 'EUR', 1000000);
        const expected = 1000000 * (3.00 / 3.26);
        expect(result, closeTo(expected, 0.01));
      });
    });

    group('Cross-Rate Formula Verification', () {
      test('verify X→Y = rates[Y] / rates[X] formula', () {
        // Test multiple currency pairs to ensure formula is correct
        const testCases = [
          ('EUR', 'KWD', 1.00 / 3.00),
          ('KWD', 'EUR', 3.00 / 1.00),
          ('USD', 'JPY', 488.60 / 3.26),
          ('JPY', 'USD', 3.26 / 488.60),
          ('EUR', 'JPY', 488.60 / 3.00),
          ('JPY', 'EUR', 3.00 / 488.60),
        ];

        for (final (from, to, expected) in testCases) {
          final rate = CurrencyConverter.getRate(testRates, from, to);
          expect(rate, closeTo(expected, 0.0001), 
            reason: 'Rate from $from to $to should be $expected');
        }
      });
    });
  });
}
