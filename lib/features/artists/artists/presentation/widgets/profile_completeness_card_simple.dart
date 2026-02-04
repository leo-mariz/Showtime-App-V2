import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/features/artists/artists/domain/enums/artist_incomplete_info_type_enum.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Widget simplificado que exibe informações de completude baseado no ArtistEntity
/// 
/// Usa apenas os campos `hasIncompleteSections` e `incompleteSections` do ArtistEntity
/// para exibir informações básicas sem precisar calcular a completude completa.
class ProfileCompletenessCardSimple extends StatefulWidget {
  final ArtistEntity? artist;

  const ProfileCompletenessCardSimple({
    super.key,
    this.artist,
  });

  @override
  State<ProfileCompletenessCardSimple> createState() => _ProfileCompletenessCardSimpleState();
}

class _ProfileCompletenessCardSimpleState extends State<ProfileCompletenessCardSimple> {
  bool _isExpanded = false;

  /// Retorna callback de navegação baseado no tipo de informação
  VoidCallback? _getNavigationCallback(String infoTypeName, BuildContext context) {
    final infoType = ArtistIncompleteInfoType.fromString(infoTypeName);
    if (infoType == null) return null;
    
    switch (infoType) {
      case ArtistIncompleteInfoType.documents:
        return () => AutoRouter.of(context).push(const DocumentsRoute());
      case ArtistIncompleteInfoType.bankAccount:
        return () => AutoRouter.of(context).push(const BankAccountRoute());
      case ArtistIncompleteInfoType.profilePicture:
        return null; // TODO: Navegar para tela de edição de foto
      case ArtistIncompleteInfoType.availability:
        return null; // TODO: Navegar para tela de edição de disponibilidade
      case ArtistIncompleteInfoType.professionalInfo:
        return () => AutoRouter.of(context).push(const ProfessionalInfoRoute());
      case ArtistIncompleteInfoType.presentations:
        return () {
          AutoRouter.of(context).push(PresentationsRoute());
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final artist = widget.artist;

    // Se não há artista ou não há informações incompletas, não mostrar
    if (artist == null || artist.hasIncompleteSections != true || artist.incompleteSections == null || artist.incompleteSections!.isEmpty) {
      return const SizedBox.shrink();
    }

    final incompleteSections = artist.incompleteSections!;
    final totalIncomplete = incompleteSections.values.fold<int>(0, (sum, list) => sum + list.length);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner compacto (sempre visível)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                // Ícone de status
                Container(
                  padding: EdgeInsets.all(DSSize.width(8)),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(DSSize.width(6)),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: DSSize.width(24),
                    color: colorScheme.error,
                  ),
                ),
                DSSizedBoxSpacing.horizontal(12),

                // Mensagem resumida
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perfil Incompleto',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      DSSizedBoxSpacing.vertical(4),
                      Text(
                        '$totalIncomplete informação${totalIncomplete > 1 ? 'ões' : ''} pendente${totalIncomplete > 1 ? 's' : ''}. Toque para ver detalhes.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ícone de expandir/colapsar
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),

          // Detalhes expandidos
          if (_isExpanded) ...[
            DSSizedBoxSpacing.vertical(16),

            // Informações incompletas organizadas por categoria
            ...incompleteSections.entries.map((entry) {
              final category = entry.key;
              final incompleteTypes = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título da categoria
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: DSSize.width(18),
                        color: _getCategoryColor(colorScheme, category),
                      ),
                      DSSizedBoxSpacing.horizontal(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCategoryTitle(category),
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            DSSizedBoxSpacing.vertical(2),
                            Text(
                              _getCategoryDescription(category),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  DSSizedBoxSpacing.vertical(12),

                  // Lista de itens incompletos desta categoria
                  ...incompleteTypes.map((infoType) {
                    final onTap = _getNavigationCallback(infoType, context);

                    return Padding(
                      padding: EdgeInsets.only(bottom: DSSize.height(8)),
                      child: _buildIncompleteItem(
                        context,
                        infoType,
                        _getCategoryColor(colorScheme, category),
                        onTap,
                      ),
                    );
                  }),

                  DSSizedBoxSpacing.vertical(16),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildIncompleteItem(
    BuildContext context,
    String infoType,
    Color color,
    VoidCallback? onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(DSSize.width(12)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DSSize.width(8)),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: DSSize.width(20),
            color: color,
          ),
          DSSizedBoxSpacing.horizontal(8),
          Expanded(
            child: Text(
              _getInfoTypeName(infoType),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (onTap != null)
            IconButton(
              onPressed: onTap,
              icon: Icon(Icons.arrow_right, size: DSSize.width(20), color: colorScheme.onSurface,),
            ),
        ],
      ),
    );
  }

  String _getInfoTypeName(String infoType) {
    final infoTypeEnum = ArtistIncompleteInfoType.fromString(infoType);
    return infoTypeEnum?.displayName ?? infoType;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'approvalRequired':
        return Icons.verified_user;
      case 'exploreRequired':
        return Icons.visibility;
      case 'optional':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }

  Color _getCategoryColor(ColorScheme colorScheme, String category) {
    switch (category) {
      case 'approvalRequired':
        return colorScheme.onTertiaryContainer;
      case 'exploreRequired':
        return Colors.orange;
      case 'optional':
        return colorScheme.onPrimaryContainer;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'approvalRequired':
        return 'Aprovação';
      case 'exploreRequired':
        return 'Ativação';
      case 'optional':
        return 'Visibilidade';
      default:
        return category;
    }
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'approvalRequired':
        return 'Para ser aprovado na plataforma, precisamos que você complete as informações abaixo:';
      case 'exploreRequired':
        return 'Para ser um artista ativo no explorar, precisamos que você complete as informações abaixo:';
      case 'optional':
        return 'Para melhorar sua visibilidade e aparecer mais nas recomendações, precisamos que você complete as informações abaixo:';
      default:
        return '';
    }
  }
}
