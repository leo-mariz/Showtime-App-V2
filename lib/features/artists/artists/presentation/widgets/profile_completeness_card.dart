import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/features/artists/artists/domain/entities/artist_completeness_entity.dart';
import 'package:app/features/artists/artists/domain/enums/artist_info_category_enum.dart';
import 'package:app/features/artists/artists/presentation/widgets/completeness_progress_bar.dart';
import 'package:app/features/artists/artists/presentation/widgets/incomplete_info_item.dart';
import 'package:flutter/material.dart';

/// Widget principal que exibe o status de completude do perfil do artista
/// 
/// Mostra:
/// - Banner compacto com status geral e progresso
/// - Card expansível com detalhes de cada informação
/// - Lista de informações incompletas organizadas por categoria
/// - Ações diretas para completar cada informação
class ProfileCompletenessCard extends StatefulWidget {
  final ArtistCompletenessEntity completeness;
  final VoidCallback? onNavigateToDocuments;
  final VoidCallback? onNavigateToBankAccount;
  final VoidCallback? onNavigateToProfilePicture;
  final VoidCallback? onNavigateToAvailability;
  final VoidCallback? onNavigateToProfessionalInfo;
  final VoidCallback? onNavigateToPresentations;

  const ProfileCompletenessCard({
    super.key,
    required this.completeness,
    this.onNavigateToDocuments,
    this.onNavigateToBankAccount,
    this.onNavigateToProfilePicture,
    this.onNavigateToAvailability,
    this.onNavigateToProfessionalInfo,
    this.onNavigateToPresentations,
  });

  @override
  State<ProfileCompletenessCard> createState() => _ProfileCompletenessCardState();
}

class _ProfileCompletenessCardState extends State<ProfileCompletenessCard> {
  bool _isExpanded = false;

  /// Retorna callback de navegação baseado no tipo de informação
  VoidCallback? _getNavigationCallback(String infoTypeName) {
    switch (infoTypeName) {
      case 'documents':
        return widget.onNavigateToDocuments;
      case 'bankAccount':
        return widget.onNavigateToBankAccount;
      case 'profilePicture':
        return widget.onNavigateToProfilePicture;
      case 'availability':
        return widget.onNavigateToAvailability;
      case 'professionalInfo':
        return widget.onNavigateToProfessionalInfo;
      case 'presentations':
        return widget.onNavigateToPresentations;
      default:
        return null;
    }
  }

  /// Retorna título da seção baseado na categoria
  String _getCategoryTitle(ArtistInfoCategory category) {
    switch (category) {
      case ArtistInfoCategory.approvalRequired:
        return 'Para Aprovação';
      case ArtistInfoCategory.exploreRequired:
        return 'Para Aparecer no Explorar';
      case ArtistInfoCategory.optional:
        return 'Para Melhorar Visibilidade';
    }
  }

  /// Retorna descrição da seção baseado na categoria
  String _getCategoryDescription(ArtistInfoCategory category) {
    switch (category) {
      case ArtistInfoCategory.approvalRequired:
        return 'Complete estas informações para receber aprovação da plataforma e começar a receber solicitações.';
      case ArtistInfoCategory.exploreRequired:
        return 'Complete estas informações para aparecer nas buscas e ser encontrado por clientes.';
      case ArtistInfoCategory.optional:
        return 'Complete estas informações para melhorar sua visibilidade e aparecer mais nas recomendações.';
    }
  }

  /// Retorna ícone da categoria
  IconData _getCategoryIcon(ArtistInfoCategory category) {
    switch (category) {
      case ArtistInfoCategory.approvalRequired:
        return Icons.verified_user;
      case ArtistInfoCategory.exploreRequired:
        return Icons.visibility;
      case ArtistInfoCategory.optional:
        return Icons.trending_up;
    }
  }

  /// Retorna cor da categoria
  Color _getCategoryColor(ColorScheme colorScheme, ArtistInfoCategory category) {
    switch (category) {
      case ArtistInfoCategory.approvalRequired:
        return colorScheme.error;
      case ArtistInfoCategory.exploreRequired:
        return Colors.orange;
      case ArtistInfoCategory.optional:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final completeness = widget.completeness;

    // Se está completo, não mostrar
    if (completeness.canBeApproved && 
        completeness.canAppearInExplore && 
        completeness.completenessScore == 100) {
      return const SizedBox.shrink();
    }

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
                    color: _getStatusColor(colorScheme).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(DSSize.width(6)),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    size: DSSize.width(24),
                    color: _getStatusColor(colorScheme),
                  ),
                ),
                DSSizedBoxSpacing.horizontal(12),

                // Mensagem resumida
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      DSSizedBoxSpacing.vertical(4),
                      Text(
                        _getStatusSubtitle(),
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

          DSSizedBoxSpacing.vertical(16),

          // Barra de progresso
          CompletenessProgressBar(completeness: completeness),

          // Detalhes expandidos
          if (_isExpanded) ...[
            DSSizedBoxSpacing.vertical(16),

            // Informações incompletas organizadas por categoria
            ...ArtistInfoCategory.values.map((category) {
              final incompleteByCategory = completeness.getIncompleteByCategory(category);
              
              // Só mostrar seção se houver itens incompletos
              if (incompleteByCategory.isEmpty) {
                return const SizedBox.shrink();
              }

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
                  ...incompleteByCategory.map((status) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: DSSize.height(8)),
                      child: IncompleteInfoItem(
                        status: status,
                        onComplete: _getNavigationCallback(status.type.name),
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

  Color _getStatusColor(ColorScheme colorScheme) {
    if (widget.completeness.canBeApproved && widget.completeness.canAppearInExplore) {
      return Colors.green;
    } else if (widget.completeness.canBeApproved) {
      return Colors.orange;
    } else {
      return colorScheme.error;
    }
  }

  IconData _getStatusIcon() {
    if (widget.completeness.canBeApproved && widget.completeness.canAppearInExplore) {
      return Icons.check_circle;
    } else if (widget.completeness.canBeApproved) {
      return Icons.info;
    } else {
      return Icons.warning_amber_rounded;
    }
  }

  String _getStatusTitle() {
    if (widget.completeness.canBeApproved && widget.completeness.canAppearInExplore) {
      return 'Perfil Completo!';
    } else if (widget.completeness.canBeApproved) {
      return 'Aprovado - Falta Explorar';
    } else {
      return 'Perfil Incompleto';
    }
  }

  String _getStatusSubtitle() {
    if (widget.completeness.canBeApproved && widget.completeness.canAppearInExplore) {
      return 'Você está aprovado e visível no explorar.';
    } else if (widget.completeness.canBeApproved) {
      return 'Complete suas informações para aparecer no explorar.';
    } else {
      return 'Complete as informações obrigatórias para aprovação.';
    }
  }
}
