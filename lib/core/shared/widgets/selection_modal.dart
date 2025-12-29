import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';

/// Opção do modal de seleção
class SelectionModalOption<T> {
  final IconData icon;
  final String title;
  final T value;
  final bool isDestructive;

  const SelectionModalOption({
    required this.icon,
    required this.title,
    required this.value,
    this.isDestructive = false,
  });
}

/// Widget reutilizável para modais de seleção
/// 
/// Permite criar modais de seleção com opções customizáveis,
/// mantendo a estilização padrão do app.
class SelectionModal<T> extends StatelessWidget {
  final String title;
  final List<SelectionModalOption<T>> options;
  final bool showCancelButton;
  final String? cancelButtonLabel;

  const SelectionModal({
    super.key,
    required this.title,
    required this.options,
    this.showCancelButton = true,
    this.cancelButtonLabel,
  });

  /// Método estático para mostrar o modal
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<SelectionModalOption<T>> options,
    bool showCancelButton = true,
    String? cancelButtonLabel,
    Color? backgroundColor,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    return await showModalBottomSheet<T>(
      context: context,
      backgroundColor: backgroundColor ?? colorScheme.surface.withOpacity(0.8),
      builder: (context) => SelectionModal<T>(
        title: title,
        options: options,
        showCancelButton: showCancelButton,
        cancelButtonLabel: cancelButtonLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
          // Opções
          ...options.map((option) {
            return Column(
              children: [
                _buildOptionTile(
                  context,
                  icon: option.icon,
                  title: option.title,
                  isDestructive: option.isDestructive,
                  onTap: () => Navigator.of(context).pop(option.value),
                ),
                if (option != options.last) DSSizedBoxSpacing.vertical(8),
              ],
            );
          }).toList(),
          if (showCancelButton) ...[
            DSSizedBoxSpacing.vertical(12),
            CustomButton(
              label: cancelButtonLabel ?? 'Cancelar',
              filled: false,
              textColor: onPrimary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          DSSizedBoxSpacing.vertical(8),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;

    final iconColor = isDestructive 
        ? colorScheme.error 
        : colorScheme.onPrimaryContainer;
    final textColor = isDestructive 
        ? colorScheme.error 
        : onPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DSSize.width(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: DSSize.width(16),
          vertical: DSSize.height(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: DSSize.width(24),
            ),
            DSSizedBoxSpacing.horizontal(16),
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

