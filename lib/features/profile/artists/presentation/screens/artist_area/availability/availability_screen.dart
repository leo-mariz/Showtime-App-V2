import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/artists/presentation/widgets/availability/availability_card.dart';
import 'package:app/features/profile/artists/presentation/widgets/availability/availability_form_dialog.dart';
import 'package:app/features/profile/artists/presentation/widgets/availability/day_events_list.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Tela principal de gerenciamento de disponibilidade do artista
/// 
/// Exibe um calendário com disponibilidades e shows, além de uma lista
/// de disponibilidades para edição detalhada
@RoutePage(deferredLoading: true)
class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // TODO: Substituir por dados reais do Bloc/Repository
  List<AvailabilityEntity> _availabilities = [];
  
  // Mock de shows confirmados
  final List<Map<String, dynamic>> _confirmedShows = [
    {
      'id': 'show1',
      'date': DateTime(2024, 12, 19),
      'startTime': '18:30',
      'duration': Duration(hours: 1, minutes: 30),
      'hostName': 'João Silva',
      'location': 'Rua das Flores, 123',
    },
  ];
  
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAvailabilities();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAvailabilities() {
    // TODO: Carregar disponibilidades do artista
    setState(() {
      // Mock data - exemplo para 19/12
      _availabilities = [
        AvailabilityEntity(
          id: 'avail1',
          dataInicio: DateTime(2024, 12, 19),
          dataFim: DateTime(2024, 12, 19),
          horarioInicio: '18:00',
          horarioFim: '23:00',
          diasDaSemana: [],
          valorShow: 200.0,
          endereco: _getMockAddress(),
          raioAtuacao: 10.0,
          repetir: false,
        ),
      ];
    });
  }

  AddressInfoEntity _getMockAddress() {
    return AddressInfoEntity(
      title: 'Casa',
      zipCode: '01310-100',
      street: 'Avenida Paulista',
      number: '1578',
      district: 'Bela Vista',
      city: 'São Paulo',
      state: 'SP',
      latitude: -23.5505,
      longitude: -46.6333,
      isPrimary: true,
    );
  }

  CalendarDataSource _getCalendarDataSource() {
    final List<Appointment> appointments = [];
    
    // Agrupa disponibilidades e shows por data
    final Map<DateTime, List<Appointment>> appointmentsByDate = {};
    
    // Adiciona disponibilidades
    for (final availability in _availabilities) {
      final appointment = availability.toAppointment();
      final date = DateTime(
        appointment.startTime.year,
        appointment.startTime.month,
        appointment.startTime.day,
      );
      
      if (!appointmentsByDate.containsKey(date)) {
        appointmentsByDate[date] = [];
      }
      appointmentsByDate[date]!.add(appointment);
      appointments.add(appointment);
    }
    
    // Adiciona shows confirmados
    for (final show in _confirmedShows) {
      final showDate = show['date'] as DateTime;
      final startTimeStr = show['startTime'] as String;
      final duration = show['duration'] as Duration;
      final parts = startTimeStr.split(':');
      final startDateTime = DateTime(
        showDate.year,
        showDate.month,
        showDate.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      final endDateTime = startDateTime.add(duration);
      
      final appointment = Appointment(
        startTime: startDateTime,
        endTime: endDateTime,
        subject: 'Show: ${show['hostName']}',
        notes: show['location'] as String,
        color: Colors.orange, // Cor diferente para shows
      );
      
      appointments.add(appointment);
    }
    
    return _AvailabilityDataSource(appointments);
  }

  List<Appointment> _getAppointmentsForDate(DateTime date) {
    final appointments = _getCalendarDataSource().appointments as List<Appointment>;
    return appointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.startTime.year,
        appointment.startTime.month,
        appointment.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return appointmentDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  bool _hasAvailabilityOnDate(DateTime date) {
    return _availabilities.any((availability) {
      final availDate = DateTime(
        availability.dataInicio.year,
        availability.dataInicio.month,
        availability.dataInicio.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return availDate.isAtSameMomentAs(targetDate);
    });
  }

  bool _hasShowOnDate(DateTime date) {
    return _confirmedShows.any((show) {
      final showDate = show['date'] as DateTime;
      return DateTime(date.year, date.month, date.day)
          .isAtSameMomentAs(DateTime(showDate.year, showDate.month, showDate.day));
    });
  }

  void _onCalendarTap(CalendarTapDetails details) {
    if (details.date != null) {
      setState(() {
        _selectedDate = details.date;
      });
    }
    
    if (details.appointments != null && details.appointments!.isNotEmpty) {
      final appointment = details.appointments!.first;
      // Verifica se é uma disponibilidade (não é show confirmado)
      final availability = _availabilities.firstWhere(
        (av) => av.toAppointment().subject == appointment.subject,
        orElse: () => _availabilities.first,
      );
      
      if (_availabilities.contains(availability)) {
        _showEditAvailabilityDialog(availability);
      }
    } else if (details.date != null) {
      // Data vazia clicada - criar nova disponibilidade
      _showNewAvailabilityDialog(details.date!);
    }
  }

  void _showNewAvailabilityDialog(DateTime selectedDate) {
    AvailabilityFormDialog.show(
      context: context,
      initialDate: selectedDate,
      onSave: (availability) {
        setState(() {
          _availabilities.add(availability);
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _showEditAvailabilityDialog(AvailabilityEntity availability) {
    AvailabilityFormDialog.show(
      context: context,
      availability: availability,
      onSave: (updatedAvailability) {
        setState(() {
          final index = _availabilities.indexWhere(
            (av) => av.id == availability.id,
          );
          if (index != -1) {
            _availabilities[index] = updatedAvailability;
          }
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _onDeleteAvailability(AvailabilityEntity availability) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Disponibilidade'),
        content: const Text('Tem certeza que deseja excluir esta disponibilidade?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _availabilities.remove(availability);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Disponibilidade',
      showAppBarBackButton: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewAvailabilityDialog(DateTime.now()),
        backgroundColor: colorScheme.onPrimaryContainer,
        foregroundColor: colorScheme.primaryContainer,
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.onPrimaryContainer,
            labelStyle: textTheme.bodyMedium,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.onPrimaryContainer,
            tabs: const [
              Tab(text: 'Disponibilidades', icon: Icon(Icons.list)),
              Tab(text: 'Agenda', icon: Icon(Icons.calendar_month)),
            ],
          ),
          
          // Conteúdo das tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 2: Lista
                _buildListTab(colorScheme, textTheme),
                // Tab 1: Calendário
                _buildCalendarTab(colorScheme, textTheme),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        // Calendário
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SfCalendar(
                view: CalendarView.month,
                dataSource: _getCalendarDataSource(),
                onTap: _onCalendarTap,
                onSelectionChanged: (CalendarSelectionDetails details) {
                  if (details.date != null) {
                    setState(() {
                      _selectedDate = details.date;
                    });
                  }
                },
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                  showAgenda: false,
                  numberOfWeeksInView: 6,
                ),
                headerStyle: CalendarHeaderStyle(
                  textStyle: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                todayHighlightColor: colorScheme.onPrimaryContainer,
                cellBorderColor: colorScheme.outline.withOpacity(0.2),
                selectionDecoration: BoxDecoration(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.3),
                  border: Border.all(
                    color: colorScheme.onPrimaryContainer,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                monthCellBuilder: (context, details) {
                  final date = details.date;
                  final hasAvailability = _hasAvailabilityOnDate(date);
                  final hasShow = _hasShowOnDate(date);
                  final isSelected = _selectedDate != null &&
                      DateTime(date.year, date.month, date.day).isAtSameMomentAs(
                          DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day));
                  final isToday = DateTime(date.year, date.month, date.day).isAtSameMomentAs(
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
                  
                  return Container(
                    decoration: isSelected
                        ? BoxDecoration(
                            color: colorScheme.onPrimaryContainer.withOpacity(0.3),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Data
                        Text(
                          '${date.day}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: isToday
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onPrimary,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        // Marcadores visuais
                        Positioned(
                          bottom: 2,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasAvailability)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (hasAvailability && hasShow)
                                const SizedBox(width: 2),
                              if (hasShow)
                                Icon(
                                  Icons.star,
                                  size: 8,
                                  color: Colors.orange,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Lista de eventos do dia selecionado
        Expanded(
          flex: 2,
          child: _selectedDate != null
              ? DayEventsList(
                  date: _selectedDate!,
                  appointments: _getAppointmentsForDate(_selectedDate!),
                  availabilities: _availabilities.where((av) {
                    final availDate = DateTime(
                      av.dataInicio.year,
                      av.dataInicio.month,
                      av.dataInicio.day,
                    );
                    final selected = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                    );
                    return availDate.isAtSameMomentAs(selected);
                  }).toList(),
                  confirmedShows: _confirmedShows.where((show) {
                    final showDate = show['date'] as DateTime;
                    final selected = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                    );
                    return DateTime(showDate.year, showDate.month, showDate.day)
                        .isAtSameMomentAs(selected);
                  }).toList(),
                )
              : Center(
                  child: Text(
                    'Selecione um dia no calendário',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildListTab(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
              Text(
                '${_availabilities.length}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _availabilities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      DSSizedBoxSpacing.vertical(16),
                      Text(
                        'Nenhuma disponibilidade cadastrada',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      DSSizedBoxSpacing.vertical(8),
                      Text(
                        'Toque no botão + para adicionar',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _availabilities.length,
                  itemBuilder: (context, index) {
                    final availability = _availabilities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AvailabilityCard(
                        availability: availability,
                        onTap: () => _showEditAvailabilityDialog(availability),
                        onDelete: () => _onDeleteAvailability(availability),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// DataSource customizado para o calendário
class _AvailabilityDataSource extends CalendarDataSource {
  _AvailabilityDataSource(List<Appointment> source) {
    appointments = source;
  }
}
