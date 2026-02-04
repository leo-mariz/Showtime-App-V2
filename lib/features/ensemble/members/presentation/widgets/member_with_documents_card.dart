import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

/// Status dos documentos para exibição no card.
/// 0 = pending, 1 = submitted, 2 = approved, 3 = rejected.
enum _DocumentDisplayStatus {
  pending,
  inReview,
  approved,
}

/// Card de UI pura para exibir um integrante com status dos documentos
/// (identidade e antecedentes), talentos no grupo e ações (documentos, remover).
class MemberWithDocumentsCard extends StatelessWidget {
  final String name;
  final String? email;
  final String? photoUrl;
  final bool isOwner;
  final bool isApproved;
  /// Talentos do integrante neste conjunto (especialidades no grupo).
  final List<String>? talents;
  /// Documentos do integrante (identidade e antecedentes). Se null/vazio ou algum pendente/rejeitado, mostra botão "Enviar documentos".
  final List<MemberDocumentEntity>? memberDocuments;
  /// Callback ao tocar em "Editar talentos" (se null, não exibe; dono pode não ter edição).
  final VoidCallback? onEditTalentsTap;
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
    this.talents,
    this.memberDocuments,
    this.onEditTalentsTap,
    this.onDocumentsTap,
    this.onRemove,
  });

  /// 0 pending, 1 submitted, 2 approved, 3 rejected.
  static _DocumentDisplayStatus _documentDisplayStatus(List<MemberDocumentEntity>? docs) {
    if (docs == null || docs.isEmpty || docs.length != 2) return _DocumentDisplayStatus.pending;
    final hasPendingOrRejected = docs.any((d) => d.status == 0 || d.status == 3);
    if (hasPendingOrRejected) return _DocumentDisplayStatus.pending;
    final bothApproved = docs.length >= 2 && docs.every((d) => d.status == 2);
    if (bothApproved) return _DocumentDisplayStatus.approved;
    return _DocumentDisplayStatus.inReview;
  }

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
                    if (talents != null && talents!.isNotEmpty) ...[
                      DSSizedBoxSpacing.vertical(6),
                      Wrap(
                        spacing: DSSize.width(6),
                        runSpacing: DSSize.height(4),
                        children: [
                          for (final t in talents!)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: DSSize.width(8),
                                vertical: DSSize.height(4),
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(DSSize.width(6)),
                              ),
                              child: Text(
                                t,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (onEditTalentsTap != null) ...[
                      DSSizedBoxSpacing.vertical(4),
                      GestureDetector(
                        onTap: onEditTalentsTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (talents == null || talents!.isEmpty) ...[
                              Icon(
                                Icons.add_outlined,
                                size: DSSize.width(14),
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ] else ...[
                              Icon(
                                Icons.edit_outlined,
                                size: DSSize.width(14),
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ],
                            DSSizedBoxSpacing.horizontal(4),
                            Text(
                              talents == null || talents!.isEmpty
                                  ? 'Adicionar talentos'
                                  : 'Editar talentos',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
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

          if (!isOwner && onDocumentsTap != null) ...[
            Builder(
              builder: (context) {
                final docStatus = _documentDisplayStatus(memberDocuments);
                final showButton = docStatus == _DocumentDisplayStatus.pending;
                final String statusLabel;
                final IconData statusIcon;
                switch (docStatus) {
                  case _DocumentDisplayStatus.pending:
                    statusLabel = 'Documentos pendentes';
                    statusIcon = Icons.warning_amber_rounded;
                    break;
                  case _DocumentDisplayStatus.inReview:
                    statusLabel = 'Documentos em análise';
                    statusIcon = Icons.hourglass_top_rounded;
                    break;
                  case _DocumentDisplayStatus.approved:
                    statusLabel = 'Integrante aprovado';
                    statusIcon = Icons.check_circle;
                    break;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DSSizedBoxSpacing.vertical(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          statusIcon,
                          size: DSSize.width(14),
                          color: docStatus == _DocumentDisplayStatus.approved
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onTertiaryContainer,
                        ),
                        DSSizedBoxSpacing.horizontal(4),
                        Text(
                          statusLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (showButton) ...[
                      DSSizedBoxSpacing.vertical(8),
                      Divider(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.12),
                        height: DSSize.height(1),
                      ),
                      DSSizedBoxSpacing.vertical(8),
                      CustomButton(
                        label: 'Enviar documentos',
                        icon: Icons.arrow_forward_ios,
                        iconOnRight: true,
                        buttonType: CustomButtonType.default_,
                        height: DSSize.height(40),
                        onPressed: onDocumentsTap,
                      ),
                    ],
                  ],
                );
              },
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
