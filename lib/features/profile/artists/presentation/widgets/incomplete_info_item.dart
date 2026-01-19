import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/profile/artists/domain/entities/artist_info_status_entity.dart';
import 'package:app/features/profile/artists/domain/enums/artist_info_category_enum.dart';
import 'package:flutter/material.dart';

/// Widget que exibe um item individual de informação incompleta
/// 
/// Mostra:
/// - Ícone de status (⚠️ incompleto / ✓ completo)
/// - Nome da informação
/// - O que falta (específico)
/// - Impacto (por que é importante)
/// - Botão de ação (Completar / Verificar)
class IncompleteInfoItem extends StatelessWidget {
  final ArtistInfoStatusEntity status;
  final VoidCallback? onComplete;
  final bool showActionButton;

  const IncompleteInfoItem({
    super.key,
    required this.status,
    this.onComplete,
    this.showActionButton = true,
  });

  /// Retorna ícone baseado no status
  IconData _getIcon() {
    if (status.isComplete) {
      return Icons.check_circle;
    }
    return Icons.warning_amber_rounded;
  }

  /// Retorna cor do ícone baseado no status
  Color _getIconColor(ColorScheme colorScheme) {
    if (status.isComplete) {
      return Colors.green;
    }
    return colorScheme.error;
  }

  /// Retorna cor do texto de impacto baseado na categoria
  Color _getImpactColor(ColorScheme colorScheme) {
    switch (status.category) {
      case ArtistInfoCategory.approvalRequired:
        return colorScheme.error;
      case ArtistInfoCategory.exploreRequired:
        return Colors.orange;
      case ArtistInfoCategory.optional:
        return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final iconColor = _getIconColor(colorScheme);
    final impactColor = _getImpactColor(colorScheme);

    return Container(
      padding: EdgeInsets.all(DSSize.width(12)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DSSize.width(8)),
        border: Border.all(
          color: status.isComplete 
              ? Colors.green.withOpacity(0.3)
              : iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone e título
          Row(
            children: [
              Icon(
                _getIcon(),
                size: DSSize.width(20),
                color: iconColor,
              ),
              DSSizedBoxSpacing.horizontal(8),
              Expanded(
                child: Text(
                  status.typeDescription,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(8),

          // O que falta
          if (!status.isComplete && status.missingItems.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DSSize.width(8),
                vertical: DSSize.height(4),
              ),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DSSize.width(4)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: DSSize.width(14),
                    color: iconColor,
                  ),
                  DSSizedBoxSpacing.horizontal(4),
                  Expanded(
                    child: Text(
                      status.explanationMessage,
                      style: textTheme.bodySmall?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DSSizedBoxSpacing.vertical(6),
          ],

          // Impacto
          Row(
            children: [
              Icon(
                _getImpactIcon(),
                size: DSSize.width(14),
                color: impactColor,
              ),
              DSSizedBoxSpacing.horizontal(4),
              Expanded(
                child: Text(
                  status.impactMessage,
                  style: textTheme.bodySmall?.copyWith(
                    color: impactColor,
                  ),
                ),
              ),
            ],
          ),

          // Botão de ação
          if (!status.isComplete && showActionButton && onComplete != null) ...[
            DSSizedBoxSpacing.vertical(12),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Completar',
                onPressed: onComplete,
                buttonType: CustomButtonType.default_,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getImpactIcon() {
    switch (status.category) {
      case ArtistInfoCategory.approvalRequired:
        return Icons.verified_user;
      case ArtistInfoCategory.exploreRequired:
        return Icons.visibility;
      case ArtistInfoCategory.optional:
        return Icons.trending_up;
    }
  }
}
