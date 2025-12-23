import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/shared/widgets/dialog_button.dart';

/// Widget de diálogo de confirmação reutilizável
/// 
/// USO:
/// ```dart
/// final confirmed = await ConfirmationDialog.show(
///   context: context,
///   title: 'Confirmar ação',
///   message: 'Deseja realmente continuar?',
///   confirmText: 'Confirmar',
///   cancelText: 'Cancelar',
/// );
/// ```
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool barrierDismissible;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
    this.confirmButtonColor,
    this.cancelButtonColor,
  });

  /// Método estático para exibir o diálogo de confirmação
  /// 
  /// Retorna `true` se o usuário confirmou, `false` se cancelou, ou `null` se fechou o diálogo
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool barrierDismissible = true,
    Color? confirmButtonColor,
    Color? cancelButtonColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSSize.width(16)),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
      actions: [
        DialogButton.text(
          text: cancelText,
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
        ),
        DialogButton.primary(
          text: confirmText,
          backgroundColor: confirmButtonColor ?? colorScheme.onPrimaryContainer,
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: EdgeInsets.symmetric(
        horizontal: DSSize.width(16),
        vertical: DSSize.height(8),
      ),
      contentPadding: EdgeInsets.fromLTRB(
        DSSize.width(24),
        DSSize.height(20),
        DSSize.width(24),
        DSSize.height(8),
      ),
      titlePadding: EdgeInsets.fromLTRB(
        DSSize.width(24),
        DSSize.height(24),
        DSSize.width(24),
        DSSize.height(0),
      ),
    );
  }
}

