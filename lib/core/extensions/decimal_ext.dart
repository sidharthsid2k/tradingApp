import 'package:decimal/decimal.dart';

/// Convenience extensions for [Decimal] — formatting and helpers.
extension DecimalFormatting on Decimal {
  // ─── Formatting helpers ─────────────────────────────────────────────────────

  /// Formats as Indian Rupee string, e.g. "₹2,945.50".
  String toINR({bool compact = false}) {
    if (compact) return '₹${_compactFormat(toDouble())}';
    return '₹${_formatWithCommas(toStringAsFixed(2))}';
  }

  /// Returns a signed string: "+123.45" or "-123.45".
  String toSignedString({int decimals = 2}) {
    final str = toStringAsFixed(decimals);
    return isNegative ? str : '+$str';
  }

  /// Formats as signed INR: "+₹2,945.50" or "-₹2,945.50".
  String toSignedINR() {
    final abs = isNegative ? -this : this;
    final prefix = isNegative ? '-₹' : '+₹';
    return '$prefix${_formatWithCommas(abs.toStringAsFixed(2))}';
  }

  /// Returns percentage string with 2 dp, e.g. "+1.23%" or "-0.45%".
  String toPercentString({bool signed = true}) {
    final str = toStringAsFixed(2);
    if (!signed) return '$str%';
    return isNegative ? '$str%' : '+$str%';
  }

  bool get isNegative => this < Decimal.zero;
  bool get isPositive => this > Decimal.zero;
  bool get isZero => this == Decimal.zero;
}

/// Parses a Decimal from a string, returning zero on failure.
Decimal parseDecimalSafe(String? s) {
  if (s == null || s.isEmpty) return Decimal.zero;
  try {
    return Decimal.parse(s);
  } catch (_) {
    return Decimal.zero;
  }
}

/// Weighted-average cost: (oldAvgCost × oldQty + newPrice × newQty) / totalQty.
///
/// Uses double arithmetic scaled to 4 decimal places for precision.
Decimal weightedAverageCost({
  required Decimal oldAvgCost,
  required int oldQty,
  required Decimal newPrice,
  required int newQty,
}) {
  final totalQty = oldQty + newQty;
  if (totalQty == 0) return Decimal.zero;

  final oldAvg = double.parse(oldAvgCost.toStringAsFixed(6));
  final newPr = double.parse(newPrice.toStringAsFixed(6));

  final totalValue = (oldAvg * oldQty) + (newPr * newQty);
  final avgCost = totalValue / totalQty;

  return Decimal.parse(avgCost.toStringAsFixed(4));
}

/// Formats "12345.67" → "12,345.67" and "89205367089" → "89,20,53,67,089" (Indian numbering system).
String _formatWithCommas(String numStr) {
  final parts = numStr.split('.');
  final intPart = parts[0];
  final decPart = parts.length > 1 ? '.${parts[1]}' : '';

  final digits = intPart.replaceAll('-', '');
  final neg = intPart.startsWith('-');

  if (digits.length <= 3) {
    return '${neg ? '-' : ''}$digits$decPart';
  }

  final lastThree = digits.substring(digits.length - 3);
  final remaining = digits.substring(0, digits.length - 3);

  final buf = StringBuffer();
  var count = 0;
  for (var i = remaining.length - 1; i >= 0; i--) {
    if (count > 0 && count % 2 == 0) buf.write(',');
    buf.write(remaining[i]);
    count++;
  }
  final remainingWithCommas = buf.toString().split('').reversed.join();

  return '${neg ? '-' : ''}$remainingWithCommas,$lastThree$decPart';
}

String _compactFormat(double value) {
  final abs = value.abs();
  final sign = value < 0 ? '-' : '';
  if (abs >= 10000000) return '$sign${(abs / 10000000).toStringAsFixed(2)}Cr';
  if (abs >= 100000) return '$sign${(abs / 100000).toStringAsFixed(2)}L';
  if (abs >= 1000) return '$sign${(abs / 1000).toStringAsFixed(2)}K';
  return '$sign${abs.toStringAsFixed(2)}';
}
