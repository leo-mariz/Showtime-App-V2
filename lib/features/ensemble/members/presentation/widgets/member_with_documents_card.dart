import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

/// Card de UI pura para exibir um integrante com status dos documentos
/// (identidade e antecedentes) e ações (documentos, remover).
class MemberWithDocumentsCard extends StatelessWidget {
  final String name;
  final String? email;
  final String? photoUrl;
  final bool isOwner;
  final bool isApproved;
  /// Callback ao tocar em "Documentos" (enviar/visualizar)
  final VoidCallback? onDocumentsTap;
  /// Callback ao remover integrante (se null, botão de remover não é exibido; dono não deve ter remoção)
  final VoidCallback? onRemove;

  const MemberWithDocumentsCard({
    super.key,
    required this.name,
    this.email,
    this.photoUrl,
    this.isOwner = false,
    this.isApproved = false,
    this.onDocumentsTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onPrimary = colorScheme.onPrimary;

    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(12),
        vertical: DSSize.height(14),
      ),
      customBorderRadius: BorderRadius.circular(DSSize.width(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCircleAvatar(
                imageUrl: photoUrl,
                size: DSSize.width(48),
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
                              borderRadius:
                                  BorderRadius.circular(DSSize.width(4)),
                            ),
                            child: Text(
                              'Administrador',
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
                    
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_forever),
                  color: colorScheme.error,
                  iconSize: DSSize.width(24),
                ),
            ],
          ),
          DSSizedBoxSpacing.vertical(12),

          if (isApproved && !isOwner) ...[
            DSSizedBoxSpacing.vertical(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: DSSize.width(14),
                  color: colorScheme.onSecondaryContainer,
                ),
                DSSizedBoxSpacing.horizontal(4),
                Text(
                  'Aprovado',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (!isApproved) ...[
            DSSizedBoxSpacing.vertical(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: DSSize.width(14),
                  color: colorScheme.onTertiaryContainer,
                ),
                DSSizedBoxSpacing.horizontal(4),
                Text(
                  'Documentos pendentes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),                
              ],
            ),
            DSSizedBoxSpacing.vertical(8),
            Divider(
              color: colorScheme.onSurfaceVariant.withOpacity(0.12),
              height: DSSize.height(1),
            ),
            DSSizedBoxSpacing.vertical(8),
            CustomButton(
              label: 'Enviar documentos',
              icon: Icons.upload_file,
              iconOnLeft: true,
              buttonType: CustomButtonType.default_,
              height: DSSize.height(40),
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }
}

// class _DocumentStatusChip extends StatelessWidget {
//   final String label;
//   final String statusLabel;
//   final Color color;

//   const _DocumentStatusChip({
//     required this.label,
//     required this.statusLabel,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).textTheme;

//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: DSSize.width(8),
//         vertical: DSSize.height(4),
//       ),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(DSSize.width(6)),
//         border: Border.all(color: color.withOpacity(0.5), width: 1),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             '$label: ',
//             style: theme.bodySmall?.copyWith(
//               color: color,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Text(
//             statusLabel,
//             style: theme.bodySmall?.copyWith(
//               color: color,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
