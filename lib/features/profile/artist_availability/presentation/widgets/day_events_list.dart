import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Widget para exibir lista de eventos (disponibilidades e shows) de um dia
class DayEventsList extends StatelessWidget {
  final DateTime date;
  final List<Appointment> appointments;

  const DayEventsList({
    super.key,
    required this.date,
    required this.appointments,
  });

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  bool _isShowAppointment(Appointment appointment) {
    // Shows têm subject começando com "Show:"
    return appointment.subject.startsWith('Show:');
  }

  /// Agrupa appointments por disponibilidade (mesmo subject)
  List<GroupedAppointment> _groupAppointments(List<Appointment> appointments) {
    final Map<String, List<Appointment>> grouped = {};
    
    for (final appointment in appointments) {
      // Para shows, não agrupa (cada show é único)
      if (_isShowAppointment(appointment)) {
        grouped[appointment.subject] = [appointment];
      } else {
        // Para disponibilidades, agrupa por subject (mesma disponibilidade fragmentada)
        if (!grouped.containsKey(appointment.subject)) {
          grouped[appointment.subject] = [];
        }
        grouped[appointment.subject]!.add(appointment);
      }
    }
    
    return grouped.entries.map((entry) {
      final appointmentsList = entry.value
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      return GroupedAppointment(
        subject: entry.key,
        appointments: appointmentsList,
        notes: appointmentsList.first.notes,
      );
    }).toList()
      ..sort((a, b) => a.appointments.first.startTime.compareTo(b.appointments.first.startTime));
  }

  /// Extrai informações do subject
  Map<String, String?> _extractSubjectInfo(String subject) {
    // Subject formato: "Disponível para Shows - {titulo} - Raio: {raio}km - R$ {valor}/hora"
    final parts = subject.split(' - ');
    String? addressTitle;
    String? radius;
    String? value;
    
    if (parts.length >= 2) {
      addressTitle = parts[1];
    }
    if (parts.length >= 3) {
      // Extrai raio: "Raio: 0.1km"
      final radiusPart = parts[2];
      if (radiusPart.contains('Raio: ')) {
        final radiusStr = radiusPart.replaceAll('Raio: ', '').replaceAll('km', '').trim();
        // Formata para 1 casa decimal
        final radiusValue = double.tryParse(radiusStr);
        if (radiusValue != null) {
          radius = '${radiusValue.toStringAsFixed(1)}km';
        } else {
          radius = radiusPart.replaceAll('Raio: ', '');
        }
      }
    }
    if (parts.length >= 4) {
      // Extrai valor: "R$ 2.0/hora"
      final valuePart = parts[3];
      if (valuePart.contains('R\$ ')) {
        value = valuePart.replaceAll('R\$ ', '').replaceAll('/hora', '');
      }
    }
    
    return {
      'addressTitle': addressTitle,
      'radius': radius,
      'value': value,
    };
  }

  /// Formata múltiplos horários como "09:00-13:00 / 15:00-18:00"
  String _formatTimeRanges(List<Appointment> appointments) {
    return appointments
        .map((apt) => '${_formatTime(apt.startTime)}-${_formatTime(apt.endTime)}')
        .join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayFormat = DateFormat('EEEE', 'pt_BR');

    // Agrupa appointments por disponibilidade
    final groupedAppointments = _groupAppointments(appointments);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            // horizontal: DSPadding.horizontal(16),
            // vertical: DSPadding.vertical(8),
          ),
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
        DSSizedBoxSpacing.vertical(8),
        Expanded(
          child: groupedAppointments.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum evento neste dia',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: groupedAppointments.length,
                  itemBuilder: (context, index) {
                    final grouped = groupedAppointments[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: DSPadding.vertical(12)),
                      child: _buildGroupedAppointmentCard(
                        context,
                        grouped,
                        colorScheme,
                        textTheme,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGroupedAppointmentCard(
    BuildContext context,
    GroupedAppointment grouped,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final firstAppointment = grouped.appointments.first;
    final isShow = _isShowAppointment(firstAppointment);
    final cardColor = isShow ? colorScheme.tertiary : Colors.green;
    
    // Extrai informações do subject para disponibilidades
    Map<String, String?>? subjectInfo;
    String displaySubject = grouped.subject;
    
    if (!isShow) {
      // Para disponibilidades, simplifica o título
      displaySubject = 'Disponível para Shows';
      
      // Extrai informações detalhadas do subject original
      subjectInfo = _extractSubjectInfo(grouped.subject);
    }

    return CustomCard(
      // padding: EdgeInsets.all(DSPadding.horizontal(16)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra lateral colorida
            Container(
              width: DSSize.width(4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
            DSSizedBoxSpacing.horizontal(12),
            
            // Ícone
            Container(
              padding: EdgeInsets.all(DSPadding.horizontal(8)),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isShow ? Icons.star : Icons.check_circle,
                color: cardColor,
                size: DSSize.width(20),
              ),
            ),
            DSSizedBoxSpacing.horizontal(12),
            
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject (título principal)
                  Text(
                    displaySubject,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  DSSizedBoxSpacing.vertical(4),
                  
                  // Horários (pode ser múltiplos)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: DSSize.width(14),
                        color: colorScheme.onSurfaceVariant,
                      ),
                      DSSizedBoxSpacing.horizontal(4),
                      Expanded(
                        child: Text(
                          _formatTimeRanges(grouped.appointments),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                // Informações adicionais para disponibilidades
                if (!isShow && subjectInfo != null) ...[
                  DSSizedBoxSpacing.vertical(4),
                  _buildAvailabilityInfo(
                    subjectInfo,
                    textTheme,
                    colorScheme,
                  ),
                ],
                
                // Notes para shows
                if (isShow && grouped.notes != null && grouped.notes!.isNotEmpty) ...[
                  DSSizedBoxSpacing.vertical(4),
                  Text(
                    grouped.notes!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityInfo(
    Map<String, String?> subjectInfo,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final addressTitle = subjectInfo['addressTitle'];
    final radius = subjectInfo['radius'];
    final value = subjectInfo['value'];
    
    if (addressTitle == null && radius == null && value == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Endereço e Raio na mesma linha
        if (addressTitle != null || radius != null)
          Row(
            children: [
              if (addressTitle != null && addressTitle.isNotEmpty) ...[
                Icon(
                  Icons.place,
                  size: DSSize.width(14),
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
                DSSizedBoxSpacing.horizontal(4),
                Text(
                    addressTitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (radius != null && radius.isNotEmpty) ...[
                  DSSizedBoxSpacing.horizontal(24),
                  Text(
                    '$radius',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
                  ),
                ],
              ] else if (radius != null && radius.isNotEmpty)
                Text(
                  '$radius',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        
        // Valor em linha separada
        if (value != null && value.isNotEmpty) ...[
          if (addressTitle != null || radius != null) DSSizedBoxSpacing.vertical(4),
          Text(
            'R\$ $value/h',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }
}

/// Classe para agrupar appointments da mesma disponibilidade
class GroupedAppointment {
  final String subject;
  final List<Appointment> appointments;
  final String? notes;

  GroupedAppointment({
    required this.subject,
    required this.appointments,
    this.notes,
  });
}

