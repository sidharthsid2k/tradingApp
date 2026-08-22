import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:tradingapp/core/extensions/decimal_ext.dart';

void main() {
  group('DecimalFormatting - Indian Currency formatting', () {
    test('formats numbers according to Indian numbering system like Groww', () {
      expect(Decimal.parse('1121.00').toINR(), '₹1,121.00');
      expect(Decimal.parse('12345.67').toINR(), '₹12,345.67');
      expect(Decimal.parse('609560.00').toINR(), '₹6,09,560.00');
      expect(Decimal.parse('89205367089').toINR(), '₹89,20,53,67,089.00');
      expect(Decimal.parse('2625745699955434730').toINR(),
          '₹26,25,74,56,99,95,54,34,730.00');
    });

    test('formats negative amounts and zero properly', () {
      expect(Decimal.parse('-1.00').toSignedINR(), '-₹1.00');
      expect(Decimal.parse('0').toINR(), '₹0.00');
      expect(Decimal.parse('500').toINR(), '₹500.00');
    });
  });
}
