import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/enums/time_slot_status_enum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget de calendário simplificado para mostrar disponibilidades do artista
/// 
/// Mostra os dias disponíveis destacados e os preços médios
class ArtistAvailabilityCalendar extends StatelessWidget {
  final List<AvailabilityDayEntity> availabilities;
  final DateTime? selectedDate;
  final Function(DateTime)? onDateSelected;

  const ArtistAvailabilityCalendar({
    super.key,
    required this.availabilities,
    this.selectedDate,
    this.onDateSelected,
  });

  /// Retorna chave de data no formato YYYY-MM-DD
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Obtém disponibilidade para um dia específico
  AvailabilityDayEntity? _getAvailabilityForDay(DateTime day) {
    final dateKey = _getDateKey(day);
    try {
      return availabilities.firstWhere(
        (availability) => _getDateKey(availability.date) == dateKey,
      );
    } catch (_) {
      return null;
    }
  }

  /// Verifica se o dia tem disponibilidade
  bool _hasAvailability(DateTime day) {
    try {
      final availability = _getAvailabilityForDay(day);
      return availability != null && 
             availability.isActive &&
             (availability.slots?.any((slot) => slot.status == TimeSlotStatusEnum.available) ?? false);
    } catch (_) {
      return false;
    }
  }

  /// Calcula preço médio para um dia
  double? _getAveragePrice(DateTime day) {
    try {
      final availability = _getAvailabilityForDay(day);
      if (availability == null) return null;

      final availableSlots = availability.slots
          ?.where((slot) => 
              slot.status == TimeSlotStatusEnum.available && 
              slot.valorHora != null)
          .toList() ?? [];

      if (availableSlots.isEmpty) return null;

      final totalValue = availableSlots
          .map((slot) => slot.valorHora!)
          .reduce((a, b) => a + b);
      
      return totalValue / availableSlots.length;
    } catch (_) {
      return null;
    }
  }

  /// Verifica se o dia é hoje
  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && 
           day.month == now.month && 
           day.day == now.day;
  }

  /// Verifica se o dia é passado
  bool _isPast(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayOnly = DateTime(day.year, day.month, day.day);
    return dayOnly.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calcular range de datas (próximos 3 meses)
    final startDate = today;
    final endDate = today.add(const Duration(days: 90));
    
    // Agrupar disponibilidades por mês
    final months = <DateTime, List<AvailabilityDayEntity>>{};
    for (final availability in availabilities) {
      final monthKey = DateTime(availability.date.year, availability.date.month, 1);
      months.putIfAbsent(monthKey, () => []).add(availability);
    }

    if (months.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Nenhuma disponibilidade encontrada para este endereço',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final monthKey = months.keys.toList()..sort();
        final month = monthKey[index];
        final monthAvailabilities = months[month]!;
        
        return _buildMonthSection(
          context,
          month,
          monthAvailabilities,
          startDate,
          endDate,
        );
      },
    );
  }

  Widget _buildMonthSection(
    BuildContext context,
    DateTime month,
    List<AvailabilityDayEntity> monthAvailabilities,
    DateTime startDate,
    DateTime endDate,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Primeiro dia do mês
    final firstDay = DateTime(month.year, month.month, 1);
    // Último dia do mês
    final lastDay = DateTime(month.year, month.month + 1, 0);
    // Dia da semana do primeiro dia (0 = domingo, 6 = sábado)
    final firstDayWeekday = firstDay.weekday % 7;
    
    // Criar mapa de disponibilidades por dia
    final availabilityMap = <String, AvailabilityDayEntity>{};
    for (final availability in monthAvailabilities) {
      availabilityMap[_getDateKey(availability.date)] = availability;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título do mês
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DSPadding.horizontal(16),
            vertical: DSPadding.vertical(12),
          ),
          child: Text(
            DateFormat('MMMM yyyy', 'pt_BR').format(month),
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Grid de dias
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(16)),
          child: Column(
            children: [
              // Cabeçalho com dias da semana
              Row(
                children: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              DSSizedBoxSpacing.vertical(8),
              
              // Grid de dias
              ...List.generate(
                (lastDay.day + firstDayWeekday + 6) ~/ 7,
                (weekIndex) {
                  return Row(
                    children: List.generate(7, (dayIndex) {
                      final dayNumber = weekIndex * 7 + dayIndex - firstDayWeekday + 1;
                      
                      if (dayNumber < 1 || dayNumber > lastDay.day) {
                        return Expanded(child: const SizedBox());
                      }
                      
                      final day = DateTime(month.year, month.month, dayNumber);
                      final dateKey = _getDateKey(day);
                      final hasAvailability = availabilityMap.containsKey(dateKey) &&
                          _hasAvailability(day);
                      final isSelected = selectedDate != null &&
                          _getDateKey(selectedDate!) == dateKey;
                      final isToday = _isToday(day);
                      final isPast = _isPast(day);
                      final averagePrice = hasAvailability ? _getAveragePrice(day) : null;
                      
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(DSSize.width(2)),
                          child: GestureDetector(
                            onTap: hasAvailability && !isPast
                                ? () => onDateSelected?.call(day)
                                : null,
                            child: Container(
                              height: DSSize.height(60),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primaryContainer
                                    : hasAvailability && !isPast
                                        ? colorScheme.surfaceContainerHighest
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isToday
                                    ? Border.all(
                                        color: colorScheme.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayNumber.toString(),
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: hasAvailability && !isPast
                                          ? isSelected
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant.withOpacity(0.4),
                                      fontWeight: isToday || isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (averagePrice != null && hasAvailability && !isPast)
                                    Padding(
                                      padding: EdgeInsets.only(top: DSSize.height(2)),
                                      child: Text(
                                        'R\$ ${NumberFormat('#,##0', 'pt_BR').format(averagePrice)}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: isSelected
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.primary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
        DSSizedBoxSpacing.vertical(24),
      ],
    );
  }
}
