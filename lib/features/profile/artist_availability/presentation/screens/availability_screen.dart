import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/confirmation_dialog.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/availability_bloc.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/availability_card.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/availability_form_modal.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/day_events_list.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  
  // Armazena a disponibilidade pendente para adicionar/atualizar após verificação
  AvailabilityEntity? _pendingAvailability;
  
  // Flag para distinguir se a verificação é para add ou update
  bool _isPendingUpdate = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleGetAvailabilities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleGetAvailabilities({bool forceRefresh = false}) {
    context.read<AvailabilityBloc>().add(GetAvailabilitiesEvent());
  }

  /// Fragmenta uma disponibilidade em múltiplos appointments baseado nos blockedSlots
  List<Appointment> _getFragmentedAppointments(AvailabilityEntity availability, DateTime date, ColorScheme colorScheme) {
    final List<Appointment> appointments = [];
    
    // Parse horários
    final startParts = availability.horarioInicio.split(':');
    final endParts = availability.horarioFim.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);
    
    final dateStart = DateTime(date.year, date.month, date.day, startHour, startMinute);
    final dateEnd = DateTime(date.year, date.month, date.day, endHour, endMinute);
    
    // Buscar blockedSlots para esta data específica
    final blockedSlotsForDate = availability.blockedSlots.where((blocked) {
      final blockedDate = DateTime(
        blocked.date.year,
        blocked.date.month,
        blocked.date.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return blockedDate.isAtSameMomentAs(targetDate);
    }).toList();
    
    if (blockedSlotsForDate.isEmpty) {
      // Sem bloqueios, cria um appointment completo
      final appointment = Appointment(
        startTime: dateStart,
        endTime: dateEnd,
        subject: 'Disponível para Shows - ${availability.endereco.title} - Raio: ${availability.raioAtuacao}km - R\$ ${availability.valorShow}/hora',
        notes: 'Valor: R\$${availability.valorShow}/h - Endereço: ${availability.endereco.toString()}',
        color: Colors.green,
      );
      appointments.add(appointment);
    } else {
      // Ordenar bloqueios por horário de início
      blockedSlotsForDate.sort((a, b) {
        final aStart = _timeStringToMinutes(a.startTime);
        final bStart = _timeStringToMinutes(b.startTime);
        return aStart.compareTo(bStart);
      });
      
      // Criar appointments fragmentados
      int currentTime = startHour * 60 + startMinute;
      final endTimeMinutes = endHour * 60 + endMinute;
      
      for (final blocked in blockedSlotsForDate) {
        final blockedStartMinutes = _timeStringToMinutes(blocked.startTime);
        final blockedEndMinutes = _timeStringToMinutes(blocked.endTime);
        
        // Se há espaço antes do bloqueio, cria appointment
        if (blockedStartMinutes > currentTime) {
          final fragStart = DateTime(date.year, date.month, date.day, currentTime ~/ 60, currentTime % 60);
          final fragEnd = DateTime(date.year, date.month, date.day, blockedStartMinutes ~/ 60, blockedStartMinutes % 60);
          
          appointments.add(Appointment(
            startTime: fragStart,
            endTime: fragEnd,
            subject: 'Disponível para Shows - ${availability.endereco.title} - Raio: ${availability.raioAtuacao}km - R\$ ${availability.valorShow}/hora',
            notes: 'Valor: R\$${availability.valorShow}/h - Endereço: ${availability.endereco.toString()}',
            color: Colors.green,
          ));
        }
        
        currentTime = blockedEndMinutes;
      }
      
      // Adiciona appointment após o último bloqueio (se houver espaço)
      if (currentTime < endTimeMinutes) {
        final fragStart = DateTime(date.year, date.month, date.day, currentTime ~/ 60, currentTime % 60);
        
        appointments.add(Appointment(
          startTime: fragStart,
          endTime: dateEnd,
          subject: 'Disponível para Shows - ${availability.endereco.title} - Raio: ${availability.raioAtuacao}km - R\$ ${availability.valorShow}/hora',
          notes: 'Valor: R\$${availability.valorShow}/h - Endereço: ${availability.endereco.toString()}',
          color: Colors.green,
        ));
      }
    }
    
    return appointments;
  }
  
  int _timeStringToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
  
  /// Obtém todas as datas dentro do período de uma disponibilidade
  List<DateTime> _getDatesInAvailability(AvailabilityEntity availability) {
    final List<DateTime> dates = [];
    
    final startDate = DateTime(
      availability.dataInicio.year,
      availability.dataInicio.month,
      availability.dataInicio.day,
    );
    final endDate = DateTime(
      availability.dataFim.year,
      availability.dataFim.month,
      availability.dataFim.day,
    );
    
    if (!availability.repetir) {
      // Sem recorrência, todos os dias entre data início e data fim
      DateTime currentDate = startDate;
      while (!currentDate.isAfter(endDate)) {
        dates.add(DateTime(currentDate.year, currentDate.month, currentDate.day));
        currentDate = currentDate.add(const Duration(days: 1));
      }
    } else {
      // Com recorrência, gerar todas as datas dentro do período
      final weekdayMap = {
        'MO': DateTime.monday,
        'TU': DateTime.tuesday,
        'WE': DateTime.wednesday,
        'TH': DateTime.thursday,
        'FR': DateTime.friday,
        'SA': DateTime.saturday,
        'SU': DateTime.sunday,
      };
      
      final validWeekdays = availability.diasDaSemana.map((day) => weekdayMap[day]!).toSet();
      
      DateTime currentDate = startDate;
      while (!currentDate.isAfter(endDate)) {
        if (validWeekdays.contains(currentDate.weekday)) {
          dates.add(DateTime(currentDate.year, currentDate.month, currentDate.day));
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
    
    return dates;
  }

  CalendarDataSource _getCalendarDataSource(ColorScheme colorScheme) {
    final List<Appointment> appointments = [];
    
    // Adiciona disponibilidades fragmentadas
    for (final availability in _availabilities) {
      final dates = _getDatesInAvailability(availability);
      for (final date in dates) {
        final fragmented = _getFragmentedAppointments(availability, date, colorScheme);
        appointments.addAll(fragmented);
      }
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
        color: colorScheme.tertiary, // Cor diferente para shows
      );
      
      appointments.add(appointment);
    }
    
    return _AvailabilityDataSource(appointments);
  }

  List<Appointment> _getAppointmentsForDate(DateTime date, ColorScheme colorScheme) {
    final appointments = _getCalendarDataSource(colorScheme).appointments as List<Appointment>;
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
  
  /// Verifica se uma data específica tem disponibilidade real (considerando bloqueios)
  bool _hasRealAvailabilityOnDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Se for data passada, não tem disponibilidade
    if (targetDate.isBefore(todayDate)) {
      return false;
    }
    
    // Verifica cada disponibilidade
    for (final availability in _availabilities) {
      final startDate = DateTime(
        availability.dataInicio.year,
        availability.dataInicio.month,
        availability.dataInicio.day,
      );
      final endDate = DateTime(
        availability.dataFim.year,
        availability.dataFim.month,
        availability.dataFim.day,
      );
      
      // Verifica se a data está dentro do período
      if (targetDate.isBefore(startDate) || targetDate.isAfter(endDate)) {
        continue;
      }
      
      // Se não repete, todos os dias entre início e fim são válidos
      if (!availability.repetir) {
        // Já está dentro do período (verificado acima), então é válido
        // Não precisa de verificação adicional
      } else {
        // Se repete, verifica se o dia da semana está na lista
        final weekdayMap = {
          'MO': DateTime.monday,
          'TU': DateTime.tuesday,
          'WE': DateTime.wednesday,
          'TH': DateTime.thursday,
          'FR': DateTime.friday,
          'SA': DateTime.saturday,
          'SU': DateTime.sunday,
        };
        
        final dateWeekday = date.weekday;
        final hasValidWeekday = availability.diasDaSemana.any((day) => weekdayMap[day] == dateWeekday);
        
        if (!hasValidWeekday) {
          continue;
        }
      }
      
      // Verifica se há bloqueios que ocupam todo o período disponível neste dia
      final blockedSlotsForDate = availability.blockedSlots.where((blocked) {
        final blockedDate = DateTime(
          blocked.date.year,
          blocked.date.month,
          blocked.date.day,
        );
        return blockedDate.isAtSameMomentAs(targetDate);
      }).toList();
      
      // Se não há bloqueios, tem disponibilidade
      if (blockedSlotsForDate.isEmpty) {
        return true;
      }
      
      // Verifica se ainda sobra algum horário disponível após considerar os bloqueios
      final startParts = availability.horarioInicio.split(':');
      final endParts = availability.horarioFim.split(':');
      final availStartMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final availEndMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      // Ordenar bloqueios por horário
      blockedSlotsForDate.sort((a, b) {
        final aStart = _timeStringToMinutes(a.startTime);
        final bStart = _timeStringToMinutes(b.startTime);
        return aStart.compareTo(bStart);
      });
      
      int currentTime = availStartMinutes;
      for (final blocked in blockedSlotsForDate) {
        final blockedStart = _timeStringToMinutes(blocked.startTime);
        final blockedEnd = _timeStringToMinutes(blocked.endTime);
        
        // Se há espaço antes do bloqueio, tem disponibilidade
        if (blockedStart > currentTime) {
          return true;
        }
        
        currentTime = blockedEnd;
      }
      
      // Verifica se há espaço após o último bloqueio
      if (currentTime < availEndMinutes) {
        return true;
      }
    }
    
    return false;
  }

  bool _hasAvailabilityOnDate(DateTime date) {
    // Usa a função que considera bloqueios
    return _hasRealAvailabilityOnDate(date);
  }

  bool _hasShowOnDate(DateTime date) {
    return _confirmedShows.any((show) {
      final showDate = show['date'] as DateTime;
      return DateTime(date.year, date.month, date.day)
          .isAtSameMomentAs(DateTime(showDate.year, showDate.month, showDate.day));
    });
  }

  void _onCalendarTap(CalendarTapDetails details) {
    // Apenas atualiza a data selecionada, sem abrir modal
    if (details.date != null) {
      setState(() {
        _selectedDate = details.date;
      });
    }
  }

  void _showNewAvailabilityDialog(DateTime selectedDate) {
    AvailabilityFormModal.show(
      context: context,
      initialDate: selectedDate,
      onSave: (availability) {
        if (!mounted) return;
        // Armazena a disponibilidade pendente e marca como add
        setState(() {
          _pendingAvailability = availability;
          _isPendingUpdate = false;
        });
        // Fecha o modal
        Navigator.of(context).pop();
        // Verifica sobreposição antes de adicionar
        final availabilityBloc = context.read<AvailabilityBloc>();
        availabilityBloc.add(CheckAvailabilityOverlapEvent(availability: availability));
      },
    );
  }
  
  void _addAvailabilityAfterCheck() {
    if (_pendingAvailability == null) return;
    
    final availabilityBloc = context.read<AvailabilityBloc>();
    availabilityBloc.add(AddAvailabilityEvent(availability: _pendingAvailability!));
    
    // Limpa a disponibilidade pendente
    setState(() {
      _pendingAvailability = null;
      _isPendingUpdate = false;
    });
  }
  
  void _updateAvailabilityAfterCheck() {
    if (_pendingAvailability == null) return;
    
    final availabilityBloc = context.read<AvailabilityBloc>();
    // Dispara evento de update com a disponibilidade completa
    availabilityBloc.add(UpdateAvailabilityEvent(
      availability: _pendingAvailability!,
    ));
    
    // Limpa a disponibilidade pendente
    setState(() {
      _pendingAvailability = null;
      _isPendingUpdate = false;
    });
  }
  
  Future<void> _showOverlapConfirmationDialog(String priorityReason, String overlappingAddressTitle) async {
    if (!mounted) return;
    
    final actionText = _isPendingUpdate ? 'atualizar' : 'adicionar';
    final confirmText = _isPendingUpdate ? 'Atualizar' : 'Adicionar';
    
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Sobreposição de Disponibilidade',
      message: 'A disponibilidade definida está sobrepondo outras disponibilidades.\n\n'
          '$priorityReason\n\n'
          'Deseja $actionText mesmo assim?',
      confirmText: confirmText,
      cancelText: 'Cancelar',
    );
    
    if (confirmed == true && mounted) {
      if (_isPendingUpdate) {
        _updateAvailabilityAfterCheck();
      } else {
        _addAvailabilityAfterCheck();
      }
    } else if (mounted) {
      // Limpa a disponibilidade pendente se cancelou
      setState(() {
        _pendingAvailability = null;
        _isPendingUpdate = false;
      });
    }
  }

  void _showEditAvailabilityDialog(AvailabilityEntity availability) {
    AvailabilityFormModal.show(
      context: context,
      availability: availability,
      onSave: (updatedAvailability) {
        if (!mounted) return;
        // Armazena a disponibilidade pendente e marca como update
        setState(() {
          _pendingAvailability = updatedAvailability;
          _isPendingUpdate = true;
        });
        // Fecha o modal
        Navigator.of(context).pop();
        // Verifica sobreposição antes de atualizar
        // IMPORTANTE: Para update, precisamos verificar sobreposição excluindo a própria disponibilidade
        final availabilityBloc = context.read<AvailabilityBloc>();
        availabilityBloc.add(CheckAvailabilityOverlapEvent(
          availability: updatedAvailability,
          excludeAvailabilityId: updatedAvailability.id, // Exclui a própria disponibilidade da verificação
        ));
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
              if (!mounted) return;
              final availabilityBloc = context.read<AvailabilityBloc>();
              availabilityBloc.add(DeleteAvailabilityEvent(
                availabilityId: availability.id!,
              ));
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

    return BlocListener<AvailabilityBloc, AvailabilityState>(
      listener: (context, state) {
        if (state is GetAvailabilitiesSuccess) {
          setState(() {
            _availabilities = state.availabilities;
          });
        } else if (state is GetAvailabilitiesFailure) {
          context.showError(state.error);
        } else if (state is AddAvailabilitySuccess) {
          context.showSuccess('Disponibilidade salva com sucesso!');
          _handleGetAvailabilities(forceRefresh: true);
        } else if (state is AddAvailabilityFailure) {
          context.showError(state.error);
        } else if (state is UpdateAvailabilitySuccess) {
          context.showSuccess('Disponibilidade atualizada com sucesso!');
          _handleGetAvailabilities(forceRefresh: true);
        } else if (state is UpdateAvailabilityFailure) {
          context.showError(state.error);
        } else if (state is DeleteAvailabilitySuccess) {
          context.showSuccess('Disponibilidade excluída com sucesso!');
          _handleGetAvailabilities(forceRefresh: true);
        } else if (state is DeleteAvailabilityFailure) {
          context.showError(state.error);
        } else if (state is CloseAvailabilitySuccess) {
          context.showSuccess('Disponibilidade fechada com sucesso!');
          _handleGetAvailabilities(forceRefresh: true);
        } else if (state is CloseAvailabilityFailure) {
          context.showError(state.error);
        } else if (state is CheckAvailabilityOverlapSuccess) {
          // Sem sobreposição - adiciona ou atualiza diretamente
          if (_isPendingUpdate) {
            _updateAvailabilityAfterCheck();
          } else {
            _addAvailabilityAfterCheck();
          }
        } else if (state is CheckAvailabilityOverlapWarning) {
          // Há sobreposição - mostra dialog de confirmação
          _showOverlapConfirmationDialog(
            state.priorityReason,
            state.overlappingAddressTitle,
          );
        } else if (state is CheckAvailabilityOverlapFailure) {
          context.showError(state.error);
          // Limpa a disponibilidade pendente em caso de erro
          setState(() {
            _pendingAvailability = null;
            _isPendingUpdate = false;
          });
        }
      },
      child: BlocBuilder<AvailabilityBloc, AvailabilityState>(
        builder: (context, state) {
          final isLoading = state is GetAvailabilitiesLoading || state is AvailabilityInitial;

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
                      _buildListTab(colorScheme, textTheme, isLoading),
                      // Tab 1: Calendário
                      _buildCalendarTab(colorScheme, textTheme, isLoading),
                      
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarTab(ColorScheme colorScheme, TextTheme textTheme, bool isLoading) {
    return Column(
      children: [
        // Calendário
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.only(top: DSPadding.vertical(16)),
            padding: EdgeInsets.all(DSPadding.horizontal(4)),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(DSSize.width(16)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DSSize.width(16)),
                child: SfCalendar(
                view: CalendarView.month,
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
                selectionDecoration: BoxDecoration(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                  border: Border.all(
                    color: colorScheme.onPrimaryContainer,
                    width: DSSize.width(1),
                  ),
                  shape: BoxShape.circle,
                ),
                todayHighlightColor: colorScheme.onPrimaryContainer,
                cellBorderColor: colorScheme.outline.withOpacity(0.2),
                monthCellBuilder: (context, details) {
                  final date = details.date;
                  final hasAvailability = _hasAvailabilityOnDate(date);
                  final hasShow = _hasShowOnDate(date);
                  final isSelected = _selectedDate != null &&
                      DateTime(date.year, date.month, date.day).isAtSameMomentAs(
                          DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day));
                  final isToday = DateTime(date.year, date.month, date.day).isAtSameMomentAs(
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
                  
                  // Verifica se é um dia passado (anterior ao dia atual)
                  final today = DateTime.now();
                  final todayDate = DateTime(today.year, today.month, today.day);
                  final currentDate = DateTime(date.year, date.month, date.day);
                  final isPastDate = currentDate.isBefore(todayDate);
                  
                  return Opacity(
                    opacity: isPastDate ? 0.3 : 1.0,
                    child: Container(
                      margin: EdgeInsets.all(DSSize.width(1)),
                      decoration: isSelected
                          ? BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                            )
                          : null,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Data
                          Text(
                            '${date.day}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : isToday
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onPrimary,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          // Marcadores visuais
                          Positioned(
                            bottom: DSSize.height(5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Marcador de disponibilidade ou falta dela (somente para datas futuras/hoje)
                                if (!isPastDate && !hasShow)
                                  Container(
                                    width: DSSize.width(6),
                                    height: DSSize.height(6),
                                    decoration: BoxDecoration(
                                      color: hasAvailability
                                          ? Colors.green
                                          : colorScheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (hasAvailability && hasShow)
                                  DSSizedBoxSpacing.horizontal(2),
                                if (hasShow)
                                  Icon(
                                    Icons.star,
                                    size: DSSize.width(8),
                                    color: colorScheme.tertiary,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        DSSizedBoxSpacing.vertical(16),
        
        // Lista de eventos do dia selecionado
        Expanded(
          flex: 2,
          child: _selectedDate != null
              ? DayEventsList(
                  date: _selectedDate!,
                  appointments: _getAppointmentsForDate(_selectedDate!, colorScheme),
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

  Widget _buildListTab(ColorScheme colorScheme, TextTheme textTheme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DSPadding.horizontal(0),
            vertical: DSPadding.vertical(0),
          ),
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
                        size: DSSize.width(64),
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
                  // padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(16)),
                  itemCount: _availabilities.length,
                  itemBuilder: (context, index) {
                    final availability = _availabilities[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: DSPadding.vertical(12)),
                      child: AvailabilityCard(
                        availability: availability,
                        onTap: () => _showEditAvailabilityDialog(availability),
                        onEdit: () => _showEditAvailabilityDialog(availability),
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
