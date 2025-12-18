import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // Verifica se a edição está removendo caracteres
    if (oldValue.text.length > newValue.text.length) {
      return newValue;
    }

    // Adiciona as barras conforme necessário
    if (text.length == 2 || text.length == 5) {
      text += '/';
    }

    // Limita o tamanho do texto a 10 caracteres (dd/MM/yyyy)
    if (text.length > 10) return oldValue;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (text.length > 9) return oldValue;

    if (text.length == 5) {
      text += '-';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
