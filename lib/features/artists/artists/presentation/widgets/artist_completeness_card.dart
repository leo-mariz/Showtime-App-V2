import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

/// Card exibido quando o artista tem informações incompletas.
/// Mostra "Perfil com informações pendentes", contagem de pendências e detalhes
/// (Aprovação / Visibilidade) em conteúdo expandível, no mesmo padrão do ensemble.
class ArtistCompletenessCard extends StatefulWidget {
  final ArtistEntity artist;

  const ArtistCompletenessCard({
    super.key,
    required this.artist,
  });

  @override
  State<ArtistCompletenessCard> createState() => _ArtistCompletenessCardState();
}

class _ArtistCompletenessCardState extends State<ArtistCompletenessCard> {
  bool _isExpanded = false;

  int _pendingCount(ArtistEntity e) {
    final sections = e.incompleteSections;
    if (sections == null) return 0;
    return sections.values.fold<int>(0, (sum, list) => sum + list.length);
  }

  static const Map<String, String> _approvalMessages = {
    'documents': 'É necessário realizar o envio de todos os documentos obrigatórios para fazermos a verificação de sua identidade.',
    'bankAccount': 'É necessário cadastrar seu PIX ou conta bancária (agência, conta e tipo) para que possamos realizar os pagamentos.',
  };

  static const Map<String, String> _visibilityMessages = {
    'profilePicture': 'É necessário realizar o envio de uma foto de perfil.',
    'professionalInfo': 'É necessário preencher todos os dados profissionais (especialidade, duração mínima, tempo de preparação, bio).',
    'presentations': 'É necessário um vídeo de apresentação para cada talento cadastrado nos dados profissionais.',
  };

  List<String> _approvalItems(ArtistEntity e) {
    final sections = e.incompleteSections;
    if (sections == null) return [];
    return sections.keys
        .where((k) => _approvalMessages.containsKey(k))
        .map((k) => _approvalMessages[k]!)
        .toList();
  }

  List<String> _visibilityItems(ArtistEntity e) {
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
    final artist = widget.artist;
    final count = _pendingCount(artist);
    final approvalItems = _approvalItems(artist);
    final visibilityItems = _visibilityItems(artist);

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
                        'Perfil com informações pendentes',
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
                sectionName: 'Em Dados Cadastrais:',
                icon: Icons.verified_user_outlined,
                iconColor: colorScheme.onSecondaryContainer,
                items: approvalItems,
              ),
              DSSizedBoxSpacing.vertical(16),
            ],
            if (visibilityItems.isNotEmpty) ...[
              _Section(
                title: 'Visibilidade',
                sectionName: 'Em Área do Artista:',
                icon: Icons.visibility_outlined,
                iconColor: colorScheme.onPrimaryContainer,
                items: visibilityItems,
              ),
              DSSizedBoxSpacing.vertical(16),
            ],
            Text(
              'Prezamos pela excelência dos artistas presentes no Showtime. Enquanto todas as informações não estiverem completas, o perfil não poderá estar ativo no app.',
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
  final String sectionName;
  final IconData icon;
  final Color iconColor;
  final List<String> items;

  const _Section({
    required this.title,
    required this.sectionName,
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
        Text(
          '$sectionName:',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        DSSizedBoxSpacing.vertical(8),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(left: DSSize.width(12), bottom: DSSize.height(4)),
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
