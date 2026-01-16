import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/dialog_button.dart';

/// Dialog de confirmação para cancelamento de contrato
/// 
/// Exibe aviso sobre possíveis taxas e solicita confirmação do usuário
class CancelContractDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  const CancelContractDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  /// Método estático para exibir o diálogo de cancelamento
  /// 
  /// Retorna `true` se o usuário confirmou, `false` se cancelou
  static Future<bool?> show({
    required BuildContext context,
    bool isLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) => CancelContractDialog(
        isLoading: isLoading,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSSize.width(16)),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: colorScheme.error,
            size: DSSize.width(24),
          ),
          DSSizedBoxSpacing.horizontal(8),
          Expanded(
            child: Text(
              'Cancelar Evento',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(DSSize.width(8)),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(DSSize.width(8)),
              border: Border.all(
                color: colorScheme.onError.withOpacity(0.3),
                width: 1,
              ),
            ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Atenção: ',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: 'O cancelamento pode estar sujeito a taxas de acordo com os termos de uso do aplicativo. Deseja prosseguir com o cancelamento?',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
          ),
          DSSizedBoxSpacing.vertical(8),
          Text(
            'Esta ação não pode ser desfeita.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),

          DSSizedBoxSpacing.vertical(8),
          
          
        ],
      ),
      actions: [
        DialogButton.text(
          text: 'Voltar',
          onPressed: isLoading ? null : (onCancel ?? () => Navigator.of(context).pop(false)),
        ),
        DialogButton.primary(
          text: 'Cancelar',
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
          onPressed: isLoading ? null : (onConfirm ?? () => Navigator.of(context).pop(true)),
          isLoading: isLoading,
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: EdgeInsets.symmetric(
        horizontal: DSSize.width(16),
        vertical: DSSize.height(8),
      ),
      contentPadding: EdgeInsets.fromLTRB(
        DSSize.width(16),
        DSSize.height(20),
        DSSize.width(16),
        DSSize.height(8),
      ),
      titlePadding: EdgeInsets.fromLTRB(
        DSSize.width(16),
        DSSize.height(16),
        DSSize.width(16),
        DSSize.height(0),
      ),
    );
  }
}

