import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Card para exibir uma disponibilidade na lista
class AvailabilityCard extends StatelessWidget {
  final AvailabilityEntity availability;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AvailabilityCard({
    super.key,
    required this.availability,
    required this.onTap,
    required this.onDelete,
  });

  String _formatPeriod() {
    final startFormat = DateFormat('dd/MM/yyyy');
    final endFormat = DateFormat('dd/MM/yyyy');
    final start = startFormat.format(availability.dataInicio);
    final end = endFormat.format(availability.dataFim);
    
    if (availability.dataInicio.year == availability.dataFim.year &&
        availability.dataInicio.month == availability.dataFim.month &&
        availability.dataInicio.day == availability.dataFim.day) {
      return start;
    }
    
    return '$start - $end';
  }

  String _formatTime() {
    return '${availability.horarioInicio} - ${availability.horarioFim}';
  }

  String _formatRecurrence() {
    if (!availability.repetir) {
      return 'Apenas este dia';
    }
    
    if (availability.diasDaSemana.length == 7) {
      return 'Todos os dias';
    }
    
    final ptDays = AvailabilityEntityOptions.daysOfWeek();
    final selectedDays = availability.diasDaSemana
        .map((day) {
          final index = AvailabilityEntityOptions.daysOfWeekList().indexOf(day);
          return index != -1 ? ptDays[index] : day;
        })
        .toList();
    
    if (selectedDays.length == 1) {
      return selectedDays.first;
    } else if (selectedDays.length <= 3) {
      return selectedDays.join(', ');
    } else {
      return '${selectedDays.length} dias por semana';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: DSSize.width(16),
                      color: colorScheme.onPrimaryContainer,
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                    Expanded(
                      child: Text(
                        _formatPeriod(),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                DSSizedBoxSpacing.vertical(8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: DSSize.width(16),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                    Text(
                      _formatTime(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                DSSizedBoxSpacing.vertical(4),
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: DSSize.width(16),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                    Expanded(
                      child: Text(
                        _formatRecurrence(),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                DSSizedBoxSpacing.vertical(4),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: DSSize.width(16),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                    Text(
                      'R\$ ${availability.valorShow.toStringAsFixed(2)}/h',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DSSizedBoxSpacing.horizontal(16),
                    Icon(
                      Icons.location_on,
                      size: DSSize.width(16),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    DSSizedBoxSpacing.horizontal(4),
                    Expanded(
                      child: Text(
                        '${availability.endereco.title} (${availability.raioAtuacao}km)',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: colorScheme.error,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

