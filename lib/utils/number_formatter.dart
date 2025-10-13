import 'package:intl/intl.dart';

class NumberFormatter {
  /// Format a number with thousand separators
  /// For Arabic: uses Arabic-Indic digits and right-to-left formatting
  /// For English: uses standard digits and left-to-right formatting
  static String formatNumber(double number, {bool isArabic = false}) {
    final locale = isArabic ? 'ar_KW' : 'en_US';
    final formatter = NumberFormat('#,##0.00', locale);
    return formatter.format(number);
  }

  /// Format a number with thousand separators (no decimal places)
  static String formatWholeNumber(double number, {bool isArabic = false}) {
    final locale = isArabic ? 'ar_KW' : 'en_US';
    final formatter = NumberFormat('#,##0', locale);
    return formatter.format(number);
  }

  /// Format a percentage with thousand separators
  static String formatPercentage(double percentage, {bool isArabic = false}) {
    final locale = isArabic ? 'ar_KW' : 'en_US';
    final formatter = NumberFormat('#,##0.0', locale);
    return '${formatter.format(percentage)}%';
  }

  /// Format currency with thousand separators
  static String formatCurrency(double amount, String currency, {bool isArabic = false}) {
    final formattedNumber = formatNumber(amount, isArabic: isArabic);
    
    if (isArabic) {
      return '$formattedNumber $currency';
    } else {
      return '$formattedNumber $currency';
    }
  }
}
