import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final _numberFormat = NumberFormat('#,##0.00', 'en_US');
  static final _wholeFormat = NumberFormat('#,##0', 'en_US');

  static String formatLkr(num amount, {bool showDecimals = false}) {
    final formatted = showDecimals
        ? _numberFormat.format(amount)
        : _wholeFormat.format(amount);
    return 'LKR $formatted';
  }

  static String formatMinor(int amountMinor, {bool showDecimals = false}) {
    final amount = amountMinor / 100.0;
    return formatLkr(amount, showDecimals: showDecimals);
  }
}
