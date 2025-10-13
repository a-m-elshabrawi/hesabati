/// Currency conversion utilities for relative rate calculations
class CurrencyConverter {
  /// Convert amount from one currency to another using relative rates
  /// 
  /// [rates] - Map of currency codes to their relative rates (KWD = 1.0)
  /// [from] - Source currency code
  /// [to] - Target currency code  
  /// [amount] - Amount to convert
  /// 
  /// Returns the converted amount
  /// Throws [ArgumentError] for invalid inputs
  static double convert(
    Map<String, double> rates,
    String from,
    String to,
    double amount,
  ) {
    _validateInputs(rates, from, to, amount);
    
    if (from == to) {
      return amount;
    }

    return _calculateConversion(rates, from, to, amount);
  }

  /// Get the exchange rate from one currency to another
  /// 
  /// [rates] - Map of currency codes to their relative rates
  /// [from] - Source currency code
  /// [to] - Target currency code
  /// 
  /// Returns the exchange rate (how many units of 'to' currency per 1 unit of 'from')
  static double getRate(
    Map<String, double> rates,
    String from,
    String to,
  ) {
    if (from == to) return 1.0;
    
    _validateCurrencies(rates, from, to);
    
    return _calculateRate(rates, from, to);
  }

  /// Validate that conversion is mathematically consistent in both directions
  /// 
  /// This is a utility method for testing to ensure our conversion logic
  /// doesn't introduce rounding drift when going X→Y→X
  static bool validateConsistency(
    Map<String, double> rates,
    String from,
    String to,
    double amount,
  ) {
    try {
      final double converted = convert(rates, from, to, amount);
      final double backConverted = convert(rates, to, from, converted);
      
      // Allow for minimal floating point precision differences
      return (amount - backConverted).abs() < 1e-10;
    } catch (e) {
      return false;
    }
  }

  /// Validate input parameters for conversion
  static void _validateInputs(
    Map<String, double> rates,
    String from,
    String to,
    double amount,
  ) {
    _validateCurrencies(rates, from, to);
    _validateAmount(amount);
  }

  /// Validate currency codes exist in rates
  static void _validateCurrencies(
    Map<String, double> rates,
    String from,
    String to,
  ) {
    if (!rates.containsKey(from)) {
      throw ArgumentError('Unknown source currency: $from');
    }
    if (!rates.containsKey(to)) {
      throw ArgumentError('Unknown target currency: $to');
    }
  }

  /// Validate amount is valid for conversion
  static void _validateAmount(double amount) {
    if (amount.isNaN || amount.isInfinite) {
      throw ArgumentError('Invalid amount: $amount');
    }
    if (amount < 0) {
      throw ArgumentError('Amount cannot be negative: $amount');
    }
  }

  /// Calculate the actual conversion using relative rates
  /// 
  /// Formula: amount * (toRate / fromRate)
  /// This ensures mathematical consistency in both directions
  static double _calculateConversion(
    Map<String, double> rates,
    String from,
    String to,
    double amount,
  ) {
    final double fromRate = rates[from]!;
    final double toRate = rates[to]!;

    if (fromRate == 0) {
      throw ArgumentError('Source currency rate is zero: $from');
    }

    final double crossRate = toRate / fromRate;
    return amount * crossRate;
  }

  /// Calculate the exchange rate between two currencies
  static double _calculateRate(
    Map<String, double> rates,
    String from,
    String to,
  ) {
    final double fromRate = rates[from]!;
    final double toRate = rates[to]!;
    
    if (fromRate == 0) {
      throw ArgumentError('Source currency rate is zero: $from');
    }
    
    return toRate / fromRate;
  }
}
