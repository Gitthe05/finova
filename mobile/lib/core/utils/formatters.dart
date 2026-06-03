import 'package:intl/intl.dart';

class AppFormatters {
  static final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final date = DateFormat('dd/MM/yyyy');
  static final monthYear = DateFormat('MMMM yyyy', 'pt_BR');
  static final dateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String money(double value) => currency.format(value);

  static String moneyInput(double value) {
    if (value == 0) return '';
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    ).format(value).trim();
  }

  static double? parseMoney(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return null;

    if (!trimmed.contains(',') && !trimmed.contains('.')) {
      return int.parse(digitsOnly) / 100;
    }

    final normalized = trimmed
        .replaceAll(RegExp(r'[^\d,.]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}
