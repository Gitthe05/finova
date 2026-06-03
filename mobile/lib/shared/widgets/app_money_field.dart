import 'package:flutter/material.dart';
import '../../core/utils/currency_input_formatter.dart';
import 'app_text_field.dart';

class AppMoneyField extends StatelessWidget {
  const AppMoneyField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '0,00',
    this.prefixIcon,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      errorText: errorText,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [CurrencyInputFormatter()],
    );
  }
}
