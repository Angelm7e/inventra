import 'package:intl/intl.dart';

/// Formateo de precios y números para la app (cotización, catálogo, etc.).
class NumberFormatter {
  static final NumberFormat _currency = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Formato de moneda: ej. \$1,234.56
  static String currency(double value) {
    return _currency.format(value);
  }
}
