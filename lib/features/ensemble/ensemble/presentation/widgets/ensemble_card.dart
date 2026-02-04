import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

/// Card de UI pura para exibir um conjunto (ensemble).
/// Recebe apenas dados de exibição e callbacks.
class EnsembleCard extends StatelessWidget {
  /// Nome ou título do conjunto para exibição (ex.: "Nome + 2")
  final String displayName;
  /// URL da foto do conjunto (opcional)
  final String? photoUrl;
  /// Primeiros nomes dos integrantes (exceto dono), separados por vírgula; exibido como "+ João, Maria"
  final String? membersFirstNames;
  /// Se todos os integrantes estão aprovados
  final bool allApproved;
  /// Callback ao tocar no card
  final VoidCallback? onTap;
  /// Callback ao tocar no ícone de três pontos (opções); a tela decide o que exibir (ex.: modal)
  final VoidCallback? onOptionsTap;

  const EnsembleCard({
    super.key,
    required this.displayName,
    this.photoUrl,
    this.membersFirstNames,
    this.allApproved = false,
    this.onTap,
    this.onOptionsTap,
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
        vertical: DSSize.height(16),
      ),
      customBorderRadius: BorderRadius.circular(DSSize.width(16)),
      onTap: onTap,
      child: Row(
        children: [
          CustomCircleAvatar(
            imageUrl: photoUrl,
            size: DSSize.width(56),
            showCameraIcon: false,
          ),
          DSSizedBoxSpacing.horizontal(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (membersFirstNames != null && membersFirstNames!.isNotEmpty) ...[
                  DSSizedBoxSpacing.vertical(4),
                  Text(
                    '+ ${membersFirstNames!}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (allApproved) ...[
                  DSSizedBoxSpacing.vertical(8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: DSSize.width(14),
                        color: colorScheme.onSecondaryContainer,
                      ),
                      DSSizedBoxSpacing.horizontal(4),
                      Text(
                        'Membros aprovados',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onOptionsTap != null)
            IconButton(
              icon: Icon(Icons.more_vert, color: onPrimaryContainer),
              onPressed: onOptionsTap,
              iconSize: DSSize.width(24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
