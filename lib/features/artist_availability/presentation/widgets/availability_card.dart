import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Card para exibir uma disponibilidade na lista
class AvailabilityCard extends StatelessWidget {
  final AvailabilityEntity availability;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AvailabilityCard({
    super.key,
    required this.availability,
    required this.onTap,
    required this.onEdit,
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
    
    if (availability.diasDaSemana.isEmpty) {
      return 'Sem recorrência definida';
    }
    
    if (availability.diasDaSemana.length == 7) {
      return 'Todos os dias';
    }
    
    // Converter códigos para nomes abreviados em português
    final dayMap = {
      'SU': 'Dom',
      'MO': 'Seg',
      'TU': 'Ter',
      'WE': 'Qua',
      'TH': 'Qui',
      'FR': 'Sex',
      'SA': 'Sáb',
    };
    
    final selectedDays = availability.diasDaSemana
        .map((day) => dayMap[day] ?? day)
        .toList();
    
    if (selectedDays.length == 1) {
      return selectedDays.first;
    } else {
      return selectedDays.join(', ');
    }
  }

  void _showOptionsModal(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final surfaceContainerHighest = colorScheme.surfaceContainerHighest;
    final onPrimary = colorScheme.onPrimary;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final primaryContainer = colorScheme.primaryContainer;
    final onError = colorScheme.onError;
    final error = colorScheme.error;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceContainerHighest,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DSSize.width(20)),
            topRight: Radius.circular(DSSize.width(20)),
          ),
        ),
        padding: EdgeInsets.all(DSSize.width(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              decoration: BoxDecoration(
                color: onPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
            // Título
            Text(
              _formatPeriod(),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onPrimary,
              ),
            ),
            DSSizedBoxSpacing.vertical(24),
            // Botões Excluir e Editar lado a lado
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Excluir',
                    icon: Icons.delete_forever,
                    iconOnLeft: true,
                    iconColor: onError,
                    backgroundColor: error.withOpacity(0.8),
                    textColor: onError,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                  ),
                ),
                DSSizedBoxSpacing.horizontal(12),
                Expanded(
                  child: CustomButton(
                    label: 'Editar',
                    icon: Icons.edit,
                    iconOnLeft: true,
                    iconColor: primaryContainer,
                    backgroundColor: onPrimaryContainer.withOpacity(0.8),
                    textColor: primaryContainer,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEdit();
                    },
                  ),
                ),
              ],
            ),
            DSSizedBoxSpacing.vertical(12),
            // Botão Cancelar
            SizedBox(
              width: double.infinity,
              child: TextButton(
                child: Text(
                  'Cancelar',
                  style: textTheme.bodyMedium?.copyWith(
                    color: onPrimary,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            DSSizedBoxSpacing.vertical(8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomCard(
      padding: EdgeInsets.only(left: DSPadding.horizontal(16), right: DSPadding.horizontal(0), top: DSPadding.vertical(8), bottom: DSPadding.vertical(16)),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com período e menu de 3 pontos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: DSSize.width(20),
                      color: colorScheme.onPrimaryContainer,
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                    Expanded(
                      child: Text(
                        _formatPeriod(),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.onPrimaryContainer,
                ),
                onPressed: () => _showOptionsModal(context),
                iconSize: DSSize.width(24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          DSSizedBoxSpacing.vertical(4),
          
          // Horário
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: DSSize.width(18),
                color: colorScheme.onSurfaceVariant,
              ),
              DSSizedBoxSpacing.horizontal(8),
              Text(
                _formatTime(),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          DSSizedBoxSpacing.vertical(4),
          
          // Recorrência
          Row(
            children: [
              Icon(
                Icons.repeat,
                size: DSSize.width(18),
                color: colorScheme.onSurfaceVariant,
              ),
              DSSizedBoxSpacing.horizontal(8),
              Expanded(
                child: Text(
                  _formatRecurrence(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          
          DSSizedBoxSpacing.vertical(8),
          
          
          // Endereço
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.place,
                size: DSSize.width(18),
                color: colorScheme.onSurfaceVariant,
              ),
              DSSizedBoxSpacing.horizontal(8),
              Text(
                availability.endereco.title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              DSSizedBoxSpacing.horizontal(16),
              if (availability.raioAtuacao > 0) ...[
                Icon(
                  Icons.crisis_alert_rounded,
                  size: DSSize.width(18),
                  color: colorScheme.onSurfaceVariant,
                ),
                DSSizedBoxSpacing.horizontal(4),
              Expanded(
                child: Text(
                  '${availability.raioAtuacao.toStringAsFixed(1)}km',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          DSSizedBoxSpacing.vertical(4),
          // Valor e Raio
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: DSSize.width(18),
                color: colorScheme.onSurfaceVariant,
              ),
              DSSizedBoxSpacing.horizontal(8),
              Text(
                'R\$ ${availability.valorShow.toStringAsFixed(2)}/h',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          // Horários fechados (se houver)
          if (availability.blockedSlots.isNotEmpty) ...[
            DSSizedBoxSpacing.vertical(8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DSPadding.horizontal(8),
                vertical: DSPadding.vertical(4),
              ),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(DSSize.width(8)),
                border: Border.all(
                  color: colorScheme.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: DSSize.width(16),
                    color: colorScheme.error,
                  ),
                  DSSizedBoxSpacing.horizontal(4),
                  Text(
                    availability.blockedSlots.length == 1
                        ? '1 horário fechado'
                        : '${availability.blockedSlots.length} horários fechados',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
