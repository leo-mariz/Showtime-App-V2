import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:intl/intl.dart';

class Validators {
  static String? validateBoolean(bool? value) {
    if (value == null) {
      return 'Preenchimento obrigatório';
    }
    if (value == false) {
      return 'Aceite os termos para continuar';
    }
    return null;
  }

  static String? validateIsNull(String? value) {
    if (value == null || value.isEmpty) {
      return 'Preenchimento obrigatório';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    // Remove todos os caracteres não numéricos (parênteses, espaço, hífen)
    String numbersOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (numbersOnly.length != 11 && numbersOnly.length != 10) {
      return 'Digite um número de telefone válido';
    }

    return null;
  }

  static String? validateCPForCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF ou CNPJ é obrigatório';
    }
    final isCpfValid = CPFValidator.isValid(value);
    final isCnpjValid = CNPJValidator.isValid(value);
    return isCpfValid || isCnpjValid ? null : 'CPF ou CNPJ inválido';
  }

  static String? validateCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) {
      return 'CPF é obrigatório';
    }
    final isCpfValid = CPFValidator.isValid(cpf);
    return isCpfValid ? null : 'CPF inválido';
  }

  static String? validateCNPJ(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) {
      return 'CNPJ é obrigatório';
    }
    
    final isCnpjValid = CNPJValidator.isValid(cnpj);

    // Verifica se os dígitos calculados são iguais aos dígitos informados
    return isCnpjValid ? null : 'CNPJ inválido';
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Mínimo de 8 caracteres e possuir letras e números';
    }
    if (!RegExp(r'[a-z]').hasMatch(value) || !RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter letras e números';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  static String? validateBirthdate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data de nascimento é obrigatória';
    }

    try {
      // Formata a data no formato esperado (ajuste conforme o formato usado)
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      final DateTime birthDate = formatter.parseStrict(value);

      final DateTime today = DateTime.now();
      final DateTime eighteenYearsAgo = DateTime(today.year - 18, today.month, today.day);

      if (birthDate.isAfter(eighteenYearsAgo)) {
        return 'Você deve ter 18 anos';
      }
    } catch (e) {
      return 'Data de nascimento inválida';
    }

    return null; // Validação bem-sucedida
  }

  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gênero é obrigatório';
    }
    return null;
  }
}