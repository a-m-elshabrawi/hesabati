import 'package:intl/intl.dart';
import '../domain/models.dart';
import '../data/iso4217_meta.dart';

/// Currency formatting utilities with proper minor unit precision
class CurrencyFormatter {
  /// Format a number with the appropriate decimal places for a currency
  /// 
  /// [amount] - The amount to format
  /// [currencyCode] - The target currency code
  /// [showSymbol] - Whether to include currency symbol
  /// 
  /// Returns formatted string with proper decimal places
  static String formatAmount(
    double amount,
    String currencyCode, {
    bool showSymbol = false,
  }) {
    final IsoMeta meta = getIsoMeta(currencyCode);
    final NumberFormat formatter = NumberFormat.currency(
      decimalDigits: meta.minorUnit,
      symbol: showSymbol ? currencyCode : '',
    );
    
    return formatter.format(amount);
  }

  /// Format an exchange rate with proper decimal places
  /// 
  /// [rate] - The exchange rate
  /// [targetCurrency] - The target currency for decimal precision
  /// 
  /// Returns formatted rate string
  static String formatRate(double rate, String targetCurrency) {
    final IsoMeta meta = getIsoMeta(targetCurrency);
    
    // For very small rates, show more precision
    if (rate < 0.01) {
      return NumberFormat('#,##0.######', 'en_US').format(rate);
    }
    
    // For very large rates, show fewer decimal places
    if (rate > 1000) {
      return NumberFormat('#,##0.##', 'en_US').format(rate);
    }
    
    // Standard formatting based on target currency's minor unit
    return NumberFormat('#,##0.${'#' * meta.minorUnit}', 'en_US').format(rate);
  }

  /// Format a conversion result with proper decimal places
  /// 
  /// [amount] - The converted amount
  /// [currencyCode] - The target currency code
  /// 
  /// Returns formatted conversion result
  static String formatConversion(double amount, String currencyCode) {
    final IsoMeta meta = getIsoMeta(currencyCode);
    
    // Use locale-aware formatting with proper decimal places
    final NumberFormat formatter = NumberFormat('#,##0.${'#' * meta.minorUnit}', 'en_US');
    return formatter.format(amount);
  }

  /// Format currency name with code
  /// 
  /// [currencyCode] - The currency code
  /// 
  /// Returns formatted string like "US Dollar (USD)"
  static String formatCurrencyName(String currencyCode) {
    final IsoMeta meta = getIsoMeta(currencyCode);
    return '${meta.name} (${meta.code})';
  }

  /// Format a conversion line for display
  /// 
  /// [fromAmount] - Amount in source currency
  /// [fromCurrency] - Source currency code
  /// [toAmount] - Amount in target currency
  /// [toCurrency] - Target currency code
  /// 
  /// Returns formatted conversion line
  static String formatConversionLine(
    double fromAmount,
    String fromCurrency,
    double toAmount,
    String toCurrency,
  ) {
    final String formattedFrom = formatConversion(fromAmount, fromCurrency);
    final String formattedTo = formatConversion(toAmount, toCurrency);
    
    return '$formattedFrom $fromCurrency = $formattedTo $toCurrency';
  }

  /// Format timestamp for display
  /// 
  /// [dateTime] - The timestamp to format
  /// 
  /// Returns formatted timestamp string
  static String formatTimestamp(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MMM d, yyyy HH:mm (z)');
    return formatter.format(dateTime);
  }

  /// Get minor unit info for display
  /// 
  /// [currencyCode] - The currency code
  /// 
  /// Returns minor unit information string
  static String getMinorUnitInfo(String currencyCode) {
    final IsoMeta meta = getIsoMeta(currencyCode);
    return 'Minor unit: ${meta.minorUnit}';
  }
}
