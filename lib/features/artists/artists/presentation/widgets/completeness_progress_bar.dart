import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/features/artists/artists/domain/entities/artist_completeness_entity.dart';
import 'package:flutter/material.dart';

/// Widget que exibe a barra de progresso visual da completude do perfil
/// 
/// Mostra o percentual de completude e usa cores diferentes baseadas no status:
/// - Vermelho: < 50% (muito incompleto)
/// - Laranja: 50-79% (parcialmente completo)
/// - Verde: 80-100% (quase completo/completo)
class CompletenessProgressBar extends StatelessWidget {
  final ArtistCompletenessEntity completeness;

  const CompletenessProgressBar({
    super.key,
    required this.completeness,
  });

  /// Retorna a cor baseada no score de completude
  Color _getProgressColor(ColorScheme colorScheme) {
    if (completeness.completenessScore < 50) {
      return colorScheme.error;
    } else if (completeness.completenessScore < 80) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// Retorna a cor de fundo baseada no score
  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (completeness.completenessScore < 50) {
      return colorScheme.errorContainer.withOpacity(0.3);
    } else if (completeness.completenessScore < 80) {
      return Colors.orange.withOpacity(0.2);
    } else {
      return Colors.green.withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progressColor = _getProgressColor(colorScheme);
    final backgroundColor = _getBackgroundColor(colorScheme);
    final progressValue = completeness.completenessPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Percentual e label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completude do Perfil',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${completeness.completenessScore}%',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        DSSizedBoxSpacing.vertical(8),

        // Barra de progresso
        Stack(
          children: [
            // Background da barra
            Container(
              height: DSSize.height(8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(DSSize.width(4)),
              ),
            ),
            // Progresso
            FractionallySizedBox(
              widthFactor: progressValue.clamp(0.0, 1.0),
              child: Container(
                height: DSSize.height(8),
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(DSSize.width(4)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
