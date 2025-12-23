import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Widget para exibir lista de eventos (disponibilidades e shows) de um dia
class DayEventsList extends StatelessWidget {
  final DateTime date;
  final List<Appointment> appointments;
  final List<AvailabilityEntity> availabilities;
  final List<Map<String, dynamic>> confirmedShows;

  const DayEventsList({
    super.key,
    required this.date,
    required this.appointments,
    required this.availabilities,
    required this.confirmedShows,
  });

  List<TimeSlot> _buildTimeSlots() {
    final List<TimeSlot> slots = [];
    
    if (availabilities.isEmpty) {
      // Se não há disponibilidade, só mostra os shows
      for (final show in confirmedShows) {
        final startTimeStr = show['startTime'] as String;
        final duration = show['duration'] as Duration;
        final parts = startTimeStr.split(':');
        final start = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        final startMinutes = start.hour * 60 + start.minute;
        final endMinutes = startMinutes + duration.inMinutes;
        final end = TimeOfDay(
          hour: endMinutes ~/ 60,
          minute: endMinutes % 60,
        );
        
        slots.add(TimeSlot(
          start: start,
          end: end,
          type: 'show',
          data: show,
        ));
      }
      return slots;
    }
    
    // Para cada disponibilidade, calcula os slots considerando shows
    for (final availability in availabilities) {
      final availStartParts = availability.horarioInicio.split(':');
      final availEndParts = availability.horarioFim.split(':');
      final availStart = TimeOfDay(
        hour: int.parse(availStartParts[0]),
        minute: int.parse(availStartParts[1]),
      );
      final availEnd = TimeOfDay(
        hour: int.parse(availEndParts[0]),
        minute: int.parse(availEndParts[1]),
      );
      final availStartMinutes = _timeOfDayToMinutes(availStart);
      final availEndMinutes = _timeOfDayToMinutes(availEnd);
      
      // Busca shows que estão dentro do período de disponibilidade
      final List<Map<String, dynamic>> showsInPeriod = [];
      for (final show in confirmedShows) {
        final startTimeStr = show['startTime'] as String;
        final duration = show['duration'] as Duration;
        final parts = startTimeStr.split(':');
        final showStart = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        final showStartMinutes = _timeOfDayToMinutes(showStart);
        final showEndMinutes = showStartMinutes + duration.inMinutes;
        final showEnd = TimeOfDay(
          hour: showEndMinutes ~/ 60,
          minute: showEndMinutes % 60,
        );
        
        // Verifica se o show está dentro do período de disponibilidade
        if (showStartMinutes >= availStartMinutes && showEndMinutes <= availEndMinutes) {
          showsInPeriod.add({
            'start': showStart,
            'end': showEnd,
            'startMinutes': showStartMinutes,
            'endMinutes': showEndMinutes,
            'data': show,
          });
        }
      }
      
      // Ordena shows por horário
      showsInPeriod.sort((a, b) => a['startMinutes'].compareTo(b['startMinutes']));
      
      // Cria slots: disponível -> show -> disponível -> show -> ...
      int currentTime = availStartMinutes;
      
      for (final show in showsInPeriod) {
        final showStart = show['startMinutes'] as int;
        final showEnd = show['endMinutes'] as int;
        
        // Se há espaço antes do show, adiciona slot disponível
        if (showStart > currentTime) {
          slots.add(TimeSlot(
            start: _minutesToTimeOfDay(currentTime),
            end: _minutesToTimeOfDay(showStart),
            type: 'available',
            data: availability,
          ));
        }
        
        // Adiciona o show
        slots.add(TimeSlot(
          start: show['start'] as TimeOfDay,
          end: show['end'] as TimeOfDay,
          type: 'show',
          data: show['data'],
        ));
        
        currentTime = showEnd;
      }
      
      // Adiciona slot disponível após o último show (se houver)
      if (currentTime < availEndMinutes) {
        slots.add(TimeSlot(
          start: _minutesToTimeOfDay(currentTime),
          end: availEnd,
          type: 'available',
          data: availability,
        ));
      }
    }
    
    // Ordena todos os slots por horário
    slots.sort((a, b) => _timeOfDayToMinutes(a.start).compareTo(_timeOfDayToMinutes(b.start)));
    
    return slots;
  }

  TimeOfDay _minutesToTimeOfDay(int minutes) {
    return TimeOfDay(
      hour: minutes ~/ 60,
      minute: minutes % 60,
    );
  }

  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final slots = _buildTimeSlots();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayFormat = DateFormat('EEEE', 'pt_BR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(date),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
              Text(
                dayFormat.format(date),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: slots.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum evento neste dia',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSlotCard(context, slot, colorScheme, textTheme),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(
    BuildContext context,
    TimeSlot slot,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (slot.type == 'available') {
      return CustomCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disponível',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    '${_formatTime(slot.start)} - ${_formatTime(slot.end)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (slot.type == 'show') {
      final show = slot.data as Map<String, dynamic>;
      return CustomCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Show: ${show['hostName']}',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_formatTime(slot.start)} - ${_formatTime(slot.end)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    show['location'] as String,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Disponibilidade completa (não cortada por show)
      return CustomCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disponível',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    '${_formatTime(slot.start)} - ${_formatTime(slot.end)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}

class TimeSlot {
  final TimeOfDay start;
  final TimeOfDay end;
  final String type; // 'available', 'show', 'availability'
  final dynamic data;

  TimeSlot({
    required this.start,
    required this.end,
    required this.type,
    this.data,
  });
}

