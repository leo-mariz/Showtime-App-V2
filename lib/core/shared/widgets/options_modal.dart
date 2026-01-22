import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';

/// Opção do modal de opções
class OptionsModalAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final bool isDestructive;

  const OptionsModalAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.isDestructive = false,
  });
}

/// Widget reutilizável para modais de opções
/// 
/// Exibe um modal bottom sheet com título, botões de ação e opção de cancelar.
/// 
/// Exemplo de uso:
/// ```dart
/// OptionsModal.show(
///   context: context,
///   title: 'Opções do Endereço',
///   actions: [
///     OptionsModalAction(
///       label: 'Excluir',
///       icon: Icons.delete_forever,
///       backgroundColor: colorScheme.error.withOpacity(0.8),
///       textColor: colorScheme.onError,
///       iconColor: colorScheme.onError,
///       isDestructive: true,
///       onPressed: () {
///         Navigator.of(context).pop();
///         onDelete();
///       },
///     ),
///     OptionsModalAction(
///       label: 'Editar',
///       icon: Icons.edit,
///       backgroundColor: colorScheme.onPrimaryContainer.withOpacity(0.8),
///       textColor: colorScheme.primaryContainer,
///       iconColor: colorScheme.primaryContainer,
///       onPressed: () {
///         Navigator.of(context).pop();
///         onEdit();
///       },
///     ),
///   ],
/// );
/// ```
class OptionsModal extends StatelessWidget {
  final String title;
  final List<OptionsModalAction> actions;
  final bool showCancelButton;
  final String? cancelButtonLabel;
  final VoidCallback? onCancel;

  const OptionsModal({
    super.key,
    required this.title,
    required this.actions,
    this.showCancelButton = true,
    this.cancelButtonLabel,
    this.onCancel,
  });

  /// Método estático para exibir o modal de opções
  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<OptionsModalAction> actions,
    bool showCancelButton = true,
    String? cancelButtonLabel,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      builder: (context) => OptionsModal(
        title: title,
        actions: actions,
        showCancelButton: showCancelButton,
        cancelButtonLabel: cancelButtonLabel,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final surfaceContainerHighest = colorScheme.surfaceContainerHighest;
    final onPrimary = colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      padding: EdgeInsets.all(DSSize.width(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: DSSize.width(40),
            height: DSSize.height(4),
            margin: EdgeInsets.only(bottom: DSSize.height(16)),
            decoration: BoxDecoration(
              color: onPrimary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(DSSize.width(2)),
            ),
          ),
          
          // Título
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: onPrimary,
            ),
          ),
          
          DSSizedBoxSpacing.vertical(24),
          
          // Botões de ação
          if (actions.length == 1)
            // Se houver apenas uma ação, exibir em largura total
            CustomButton(
              label: actions.first.label,
              icon: actions.first.icon,
              iconOnLeft: true,
              iconColor: actions.first.iconColor,
              backgroundColor: actions.first.backgroundColor,
              textColor: actions.first.textColor,
              onPressed: () {
                Navigator.of(context).pop();
                actions.first.onPressed();
              },
            )
          else if (actions.length == 2)
            // Se houver duas ações, exibir lado a lado
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: actions[0].label,
                    icon: actions[0].icon,
                    iconOnLeft: true,
                    iconColor: actions[0].iconColor,
                    backgroundColor: actions[0].backgroundColor,
                    textColor: actions[0].textColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                      actions[0].onPressed();
                    },
                  ),
                ),
                DSSizedBoxSpacing.horizontal(12),
                Expanded(
                  child: CustomButton(
                    label: actions[1].label,
                    icon: actions[1].icon,
                    iconOnLeft: true,
                    iconColor: actions[1].iconColor,
                    backgroundColor: actions[1].backgroundColor,
                    textColor: actions[1].textColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                      actions[1].onPressed();
                    },
                  ),
                ),
              ],
            )
          else
            // Se houver mais de duas ações, exibir em coluna
            ...actions.map((action) => Padding(
              padding: EdgeInsets.only(bottom: DSSize.height(12)),
              child: CustomButton(
                label: action.label,
                icon: action.icon,
                iconOnLeft: true,
                iconColor: action.iconColor,
                backgroundColor: action.backgroundColor,
                textColor: action.textColor,
                onPressed: () {
                  Navigator.of(context).pop();
                  action.onPressed();
                },
              ),
            )),
          
          if (showCancelButton) ...[
            DSSizedBoxSpacing.vertical(12),
            // Botão Cancelar
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (onCancel != null) {
                    onCancel!();
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  cancelButtonLabel ?? 'Cancelar',
                  style: textTheme.bodyMedium?.copyWith(
                    color: onPrimary,
                  ),
                ),
              ),
            ),
          ],
          
          DSSizedBoxSpacing.vertical(8),
        ],
      ),
    );
  }
}
