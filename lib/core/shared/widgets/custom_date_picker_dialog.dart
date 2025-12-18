import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

/// Widget reutilizável para exibir um DatePicker com tema customizado
/// 
/// Encapsula a lógica do showDatePicker com o tema do design system do app
class CustomDatePickerDialog {
  /// Exibe um DatePicker com tema customizado
  /// 
  /// [context] - BuildContext necessário para exibir o dialog
  /// [initialDate] - Data inicial selecionada (padrão: hoje)
  /// [firstDate] - Primeira data disponível para seleção (padrão: hoje)
  /// [lastDate] - Última data disponível para seleção (padrão: 1 ano a partir de hoje)
  /// 
  /// Retorna a data selecionada ou null se o usuário cancelar
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? now,
      lastDate: lastDate ?? now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: colorScheme.onPrimaryContainer,
              onPrimary: colorScheme.primaryContainer,
              surface: colorScheme.surface,
              onSurface: colorScheme.onPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onPrimaryContainer,
                padding: EdgeInsets.symmetric(
                  horizontal: DSSize.width(20),
                  vertical: DSSize.height(12),
                ),
                minimumSize: Size(DSSize.width(80), DSSize.height(40)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            dialogTheme: DialogThemeData(
              actionsPadding: EdgeInsets.only(
                left: DSSize.width(24),
                right: DSSize.width(24),
                bottom: DSSize.height(28),
                top: DSSize.height(8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

