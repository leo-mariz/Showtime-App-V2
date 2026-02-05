import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

/// Card exibido quando o conjunto tem informações incompletas.
/// Mostra "Conjunto não habilitado", contagem de pendências e detalhes
/// (Aprovação / Visibilidade) em conteúdo expandível.
class EnsembleCompletenessCard extends StatefulWidget {
  final EnsembleEntity ensemble;

  const EnsembleCompletenessCard({
    super.key,
    required this.ensemble,
  });

  @override
  State<EnsembleCompletenessCard> createState() => _EnsembleCompletenessCardState();
}

class _EnsembleCompletenessCardState extends State<EnsembleCompletenessCard> {
  bool _isExpanded = false;

  int _pendingCount(EnsembleEntity e) {
    final sections = e.incompleteSections;
    if (sections == null) return 0;
    return sections.values.fold<int>(0, (sum, list) => sum + list.length);
  }

  // bool _hasIncomplete(EnsembleEntity e, String type) {
  //   final sections = e.incompleteSections;
  //   if (sections == null) return false;
  //   return sections.values.any((list) => list.contains(type));
  // }

  /// Uma mensagem por verificação incompleta (chave = tipo em incompleteSections).
  static const Map<String, String> _approvalMessages = {
    'memberDocuments': 'Cada integrante deve ter documentos (identidade e antecedentes) enviados ou aprovados.',
    'ownerDocuments': 'O administrador deve ter todos os documentos enviados.',
    'ownerBankAccount': 'O administrador deve ter PIX ou conta bancária preenchidos.',
  };

  static const Map<String, String> _visibilityMessages = {
    'members': 'O grupo precisa de pelo menos um integrante (além do administrador).',
    'profilePhoto': 'É necessário foto de perfil do grupo.',
    'presentations': 'É necessário o vídeo de apresentação do conjunto.',
    'professionalInfo': 'É necessário preencher todos os dados profissionais do conjunto.',
  };

  /// Mensagens de Aprovação: seções incompletas relacionadas a documentos/aprovação.
  List<String> _approvalItems(EnsembleEntity e) {
    final sections = e.incompleteSections;
    if (sections == null) return [];
    return sections.keys
        .where((k) => _approvalMessages.containsKey(k))
        .map((k) => _approvalMessages[k]!)
        .toList();
  }

  /// Mensagens de Visibilidade: seções incompletas que impedem visibilidade.
  List<String> _visibilityItems(EnsembleEntity e) {
    final sections = e.incompleteSections;
    if (sections == null) return [];
    return sections.keys
        .where((k) => _visibilityMessages.containsKey(k))
        .map((k) => _visibilityMessages[k]!)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ensemble = widget.ensemble;
    final count = _pendingCount(ensemble);
    final approvalItems = _approvalItems(ensemble);
    final visibilityItems = _visibilityItems(ensemble);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(DSSize.width(8)),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(DSSize.width(6)),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: DSSize.width(24),
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                DSSizedBoxSpacing.horizontal(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conjunto com informações pendentes',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      DSSizedBoxSpacing.vertical(4),
                      Text(
                        '$count informação${count != 1 ? 'ões' : ''} pendente${count != 1 ? 's' : ''}. Ver detalhes',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            DSSizedBoxSpacing.vertical(16),
            if (approvalItems.isNotEmpty) ...[
              _Section(
                title: 'Aprovação',
                icon: Icons.verified_user_outlined,
                iconColor: colorScheme.onSecondaryContainer,
                items: approvalItems,
              ),
              DSSizedBoxSpacing.vertical(16),
            ],
            if (visibilityItems.isNotEmpty) ...[
              _Section(
                title: 'Visibilidade',
                icon: Icons.visibility_outlined,
                iconColor: colorScheme.onPrimaryContainer,
                items: visibilityItems,
              ),
              DSSizedBoxSpacing.vertical(16),
            ],
            Text(
              'Prezamos pela excelência dos artistas presentes no app. Enquanto todas as informações não estiverem completas, o conjunto não poderá estar ativo no app.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> items;

  const _Section({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: DSSize.width(18), color: iconColor),
            DSSizedBoxSpacing.horizontal(8),
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        DSSizedBoxSpacing.vertical(8),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(left: DSSize.width(26), bottom: DSSize.height(4)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '→ ',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
