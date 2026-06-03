import 'package:flutter/material.dart';

Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDatePicker(
    context: context,
    locale: const Locale('pt', 'BR'),
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: 'Selecione a data',
    cancelText: 'Cancelar',
    confirmText: 'OK',
    fieldLabelText: 'Data',
    fieldHintText: 'dd/mm/aaaa',
  );
}
