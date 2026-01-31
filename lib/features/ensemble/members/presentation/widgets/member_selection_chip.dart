import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

/// Chip de UI pura para exibir um integrante selecionado (ex.: na lista do NewEnsembleModal).
/// Recebe apenas dados de exibição e callbacks.
class MemberSelectionChip extends StatelessWidget {
  final String name;
  final String? email;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const MemberSelectionChip({
    super.key,
    required this.name,
    this.email,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(12),
        vertical: DSSize.height(10),
      ),
      customBorderRadius: BorderRadius.circular(DSSize.width(12)),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: DSSize.width(20), color: onPrimaryContainer),
          DSSizedBoxSpacing.horizontal(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (email != null && email!.isNotEmpty)
                  Text(
                    email!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onPrimary.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.close, color: onPrimaryContainer, size: DSSize.width(20)),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
