import 'package:intl/intl.dart';

class MoneyFormatter {
  static final NumberFormat _realFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

  static String formatReal(double value) {
    return _realFormat.format(value);
  }
}

class NumberFormatter {
  static final NumberFormat decimalFormat = NumberFormat.decimalPattern('pt_BR');

  static String formatDecimal(double value, {int decimalDigits = 2}) {
    final format = NumberFormat.decimalPattern('pt_BR');
    format.minimumFractionDigits = decimalDigits;
    format.maximumFractionDigits = decimalDigits;
    return format.format(value);
  }

  static String formatPercent(double value) {
    final format = NumberFormat.percentPattern('pt_BR');
    return format.format(value);
  }
}
