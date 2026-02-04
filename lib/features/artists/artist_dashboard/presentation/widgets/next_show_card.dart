import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/features/artists/artist_dashboard/domain/entities/next_show_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextShowCard extends StatelessWidget {
  final NextShowEntity nextShow;
  final VoidCallback? onTap;

  const NextShowCard({
    super.key,
    required this.nextShow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Formatar data
    final dateFormat = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'pt_BR');
    final formattedDate = dateFormat.format(nextShow.date);
    final formattedDuration = _formatDuration(nextShow.duration ?? '0');

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
             
              Text(
                nextShow.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // Título do evento
          
          DSSizedBoxSpacing.vertical(8),

          // Nome do anfitrião
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: DSSize.width(16),
                color: colorScheme.onSurfaceVariant,
              ),
              DSSizedBoxSpacing.horizontal(8),
              Expanded(
                child: Text(
                  nextShow.clientName,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(8),

          // Data e hora
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: DSSize.width(16),
                color: colorScheme.onSurfaceVariant,
              ),
              DSSizedBoxSpacing.horizontal(8),
              Expanded(
                child: Text(
                  formattedDate,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(4),
          Row(
            children: [
              DSSizedBoxSpacing.horizontal(24), // Espaço para alinhar com o ícone acima
              Text(
                '${nextShow.time} • $formattedDuration',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(8),

          // Localização
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: DSSize.width(16),
                color: colorScheme.onSurfaceVariant,
              ),
              DSSizedBoxSpacing.horizontal(8),
              Expanded(
                child: Text(
                  nextShow.location,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(String duration) {
    final int durationInt = int.parse(duration);
    final hours = durationInt ~/ 60;
    final minutes = durationInt % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }
}
