import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

/// Item de lista de UI pura para exibir um integrante.
/// Recebe apenas dados de exibição e callbacks.
class MemberListItem extends StatelessWidget {
  final String name;
  final String? email;
  final String? photoUrl;
  final bool isApproved;
  final bool isOwner;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  /// Indica se o item está selecionado (ex.: no MemberModal)
  final bool isSelected;

  const MemberListItem({
    super.key,
    required this.name,
    this.email,
    this.photoUrl,
    this.isApproved = false,
    this.isOwner = false,
    this.onTap,
    this.onRemove,
    this.isSelected = false,
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
        vertical: DSSize.height(12),
      ),
      customBorderRadius: BorderRadius.circular(DSSize.width(12)),
      onTap: onTap,
      child: Row(
        children: [
          CustomCircleAvatar(
            imageUrl: photoUrl,
            size: 44,
            showCameraIcon: false,
          ),
          DSSizedBoxSpacing.horizontal(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOwner) ...[
                      DSSizedBoxSpacing.horizontal(6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DSSize.width(6),
                          vertical: DSSize.height(2),
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(DSSize.width(4)),
                        ),
                        child: Text(
                          'Dono',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (email != null && email!.isNotEmpty) ...[
                  DSSizedBoxSpacing.vertical(2),
                  Text(
                    email!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onPrimary.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (!isOwner) ...[
                  DSSizedBoxSpacing.vertical(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        isApproved ? Icons.check_circle : Icons.warning_amber_rounded,
                        size: DSSize.width(14),
                        color: isApproved
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onTertiaryContainer,
                      ),
                      DSSizedBoxSpacing.horizontal(4),
                      Text(
                        isApproved ? 'Aprovado' : 'Pendente',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isApproved
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.close, color: onPrimaryContainer, size: DSSize.width(20)),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else if (isSelected)
            Icon(
              Icons.check_box,
              color: colorScheme.onPrimaryContainer,
              size: DSSize.width(24),
            ),
        ],
      ),
    );
  }
}
