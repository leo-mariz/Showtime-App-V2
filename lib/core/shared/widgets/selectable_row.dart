import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';

/// Widget reutilizável para campos selecionáveis em formato de linha
/// com label à esquerda e campo clicável à direita
class SelectableRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final String? errorMessage;

  const SelectableRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSSize.width(12),
                    vertical: DSSize.height(12),
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(DSSize.width(12)),
                    border: Border.all(
                      color: errorMessage != null
                          ? colorScheme.error
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          value.isEmpty ? 'Selecione' : value,
                          style: textTheme.bodyMedium?.copyWith(
                            color: value.isEmpty
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onPrimary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      DSSizedBoxSpacing.horizontal(8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: DSSize.width(12),
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorMessage != null) ...[
          DSSizedBoxSpacing.vertical(4),
          Padding(
            padding: EdgeInsets.only(left: DSSize.width(140)),
            child: Text(
              errorMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

