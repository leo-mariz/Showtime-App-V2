import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/availability_bloc.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/calendar_legend_widget.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/day_details_bottom_sheet.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/forms/availability_form_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

/// Widget principal do calendário
/// 
/// Permite visualização e edição de disponibilidade
class AvailabilityCalendarWidget extends StatefulWidget {
  const AvailabilityCalendarWidget({
    super.key,
  });

  @override
  State<AvailabilityCalendarWidget> createState() => _AvailabilityCalendarWidgetState();
}

class _AvailabilityCalendarWidgetState extends State<AvailabilityCalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final Set<DateTime> _selectedDays = {};
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  
  Map<String, dynamic> _dayStates = {}; // dayId -> {hasAvailability, isPartial, isBlocked, isCustom}

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadMonth(_focusedDay);
  }

  void _loadMonth(DateTime month) {
    context.read<AvailabilityBloc>().add(
      GetAvailabilityEvent(GetAvailabilityDto(
        forceRemote: false,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocConsumer<AvailabilityBloc, AvailabilityState>(
        listener: (context, state) {
          if (state is AvailabilityErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AvailabilityCreatedState || 
                     state is AvailabilityUpdatedState || 
                     state is AvailabilityDeletedState) {
            // Recarregar mês após operações
            _loadMonth(_focusedDay);
          }
        },
        builder: (context, state) {
          // Processar dados quando carregar
          if (state is AvailabilityLoadedState) {
            _dayStates = _processDaysState(state);
          }

          return Column(
            children: [
              // Calendário
              Expanded(
                child: SingleChildScrollView(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    
                    // Fixar formato em mês
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mês',
                    },
                    
                    // Range selection
                    rangeSelectionMode: _rangeSelectionMode,
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    
                    // Predicados de seleção
                    selectedDayPredicate: (day) {
                      return _selectedDays.contains(day) || 
                             isSameDay(_selectedDay, day);
                    },
                    
                    // Callbacks
                    onDaySelected: _handleDaySelection,
                    onRangeSelected: _handleRangeSelection,
                    onDayLongPressed: _handleDayLongPress,
                    
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                      _loadMonth(focusedDay);
                    },
                    
                    // Builders customizados
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, colorScheme, isSelected: _selectedDays.contains(day));
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, colorScheme, isToday: true, isSelected: _selectedDays.contains(day));
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, colorScheme, isSelected: true);
                      },
                      rangeStartBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, colorScheme, isRangeStart: true);
                      },
                      rangeEndBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, colorScheme, isRangeEnd: true);
                      },
                      withinRangeBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, colorScheme, isWithinRange: true);
                      },
                    ),
                    
                    // Estilo do header
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: calculateFontSize(14),
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    
                    // Estilo dos dias da semana
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      weekendStyle: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    // Altura das células (cards maiores)
                    rowHeight: DSSize.height(80),
                  ),
                ),
              ),
              
              // Legenda
              Container(
                padding: EdgeInsets.all(DSSize.width(16)),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: const CalendarLegendWidget(),
              ),
              
              // Loading indicator
              if (state is AvailabilityLoadingState)
                Padding(
                  padding: EdgeInsets.all(DSSize.width(8)),
                  child: LinearProgressIndicator(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedDays.isEmpty
          ? FloatingActionButton(
              onPressed: () => _showCreateForm(),
              backgroundColor: colorScheme.onPrimaryContainer,
              foregroundColor: colorScheme.primaryContainer,
              child: const Icon(Icons.add),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão de limpar (discreto)
                FloatingActionButton.small(
                  heroTag: 'clear',
                  onPressed: () {
                    setState(() {
                      _selectedDays.clear();
                      _rangeStart = null;
                      _rangeEnd = null;
                      _rangeSelectionMode = RangeSelectionMode.toggledOff;
                    });
                  },
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  child: const Icon(Icons.close, size: 20),
                ),
                SizedBox(width: DSSize.width(12)),
                // Botão de ação
                FloatingActionButton.extended(
                  heroTag: 'action',
                  onPressed: () {
                    // TODO: Ação em lote
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${_selectedDays.length} dias selecionados'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  backgroundColor: colorScheme.onPrimaryContainer,
                  foregroundColor: colorScheme.primaryContainer,
                  icon: const Icon(Icons.edit),
                  label: Text('${_selectedDays.length}'),
                ),
              ],
            ),
    );
  }

  Map<String, dynamic> _processDaysState(AvailabilityLoadedState state) {
    final Map<String, dynamic> states = {};
    
    for (final day in state.days) {
      final dayId = day.documentId;
      
      final hasAvailability = day.hasAvailability;
      final isCustom = day.isOverridden;
      
      // Verificar se é parcialmente disponível
      bool isPartial = false;
      bool isFullyBlocked = true;
      
      for (final address in day.addresses) {
        final hasAvailable = address.slots.any((s) => s.isAvailable);
        final hasBlocked = address.slots.any((s) => s.isBlocked);
        
        if (hasAvailable && hasBlocked) {
          isPartial = true;
        }
        if (hasAvailable) {
          isFullyBlocked = false;
        }
      }
      
      states[dayId] = {
        'hasAvailability': hasAvailability,
        'isPartial': isPartial,
        'isBlocked': isFullyBlocked && !hasAvailability,
        'isCustom': isCustom,
      };
    }
    
    return states;
  }

  Map<String, dynamic>? _getDayState(DateTime day) {
    final dayId = _formatDateToId(day);
    return _dayStates[dayId];
  }

  String _formatDateToId(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _showDayDetails(DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DayDetailsBottomSheet(
        selectedDate: day,
      ),
    );
  }

  void _showCreateForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AvailabilityFormModal(
        initialDate: _selectedDay,
      ),
    );
  }

  // ==================== HANDLERS DE SELEÇÃO ====================
  
  void _handleDaySelection(DateTime selectedDay, DateTime focusedDay) {
    if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
      // Modo de seleção múltipla ativo
      setState(() {
        if (_selectedDays.contains(selectedDay)) {
          _selectedDays.remove(selectedDay);
        } else {
          _selectedDays.add(selectedDay);
        }
      });
    } else {
      // Seleção única - mostrar detalhes
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _showDayDetails(selectedDay);
    }
  }

  void _handleRangeSelection(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _focusedDay = focusedDay;
      
      // Se range completo, adicionar todos os dias ao conjunto
      if (start != null && end != null) {
        _selectedDays.clear();
        DateTime current = start;
        while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
          _selectedDays.add(current);
          current = current.add(const Duration(days: 1));
        }
      }
    });
  }

  void _handleDayLongPress(DateTime day, DateTime focusedDay) {
    // Long press ativa/desativa modo de seleção múltipla
    setState(() {
      if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
        _rangeSelectionMode = RangeSelectionMode.toggledOn;
        _selectedDays.clear();
        _selectedDays.add(day);
        _rangeStart = null;
        _rangeEnd = null;
      } else {
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        _selectedDays.clear();
        _rangeStart = null;
        _rangeEnd = null;
      }
    });

    // Feedback háptico
    // HapticFeedback.mediumImpact();
  }

  // ==================== UI BUILDERS ====================
  
  Widget _buildDayCell(
    DateTime day,
    ColorScheme colorScheme, {
    bool isToday = false,
    bool isSelected = false,
    bool isRangeStart = false,
    bool isRangeEnd = false,
    bool isWithinRange = false,
  }) {
    final dayState = _getDayState(day);
    final hasData = dayState != null;
    
    // Cores e elevação baseadas no estado
    Color? backgroundColor;
    Color? borderColor;
    double elevation = 0;
    
    if (isSelected || isRangeStart || isRangeEnd) {
      backgroundColor = colorScheme.onPrimaryContainer.withOpacity(0.15);
      borderColor = colorScheme.onPrimaryContainer;
      elevation = 8; // Elevação para selecionados
    } else if (isWithinRange) {
      backgroundColor = colorScheme.onPrimaryContainer.withOpacity(0.08);
      elevation = 4; // Elevação média para range
    } else if (isToday) {
      borderColor = colorScheme.onPrimaryContainer;
      elevation = 2; // Elevação leve para hoje
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.all(DSSize.width(4)),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border.all(
          color: borderColor ?? colorScheme.outline.withOpacity(0.2),
          width: borderColor != null ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(DSSize.width(12)),
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: colorScheme.onPrimaryContainer.withOpacity(0.15),
              blurRadius: elevation,
              offset: Offset(0, elevation / 2),
            ),
          if (hasData && elevation == 0)
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com dia
          Padding(
            padding: EdgeInsets.all(DSSize.width(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: calculateFontSize(14),
                    fontWeight: isToday || isSelected 
                        ? FontWeight.bold 
                        : FontWeight.w600,
                    color: (isSelected || isRangeStart || isRangeEnd)
                        ? colorScheme.onPrimaryContainer
                        : isToday
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                  ),
                ),
                if (hasData && dayState['isCustom'])
                  Icon(
                    Icons.star,
                    size: DSSize.width(12),
                    color: Colors.purple.shade400,
                  ),
              ],
            ),
          ),
          
          // Conteúdo do card
          if (hasData) ...[
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: DSSize.width(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indicador de disponibilidade
                    _buildAvailabilityIndicator(dayState, colorScheme),
                    
                    SizedBox(height: DSSize.height(4)),
                    
                    // Info resumida (mock)
                    if (dayState['hasAvailability']) ...[
                      Text(
                        'R\$ 150/h',
                        style: TextStyle(
                          fontSize: calculateFontSize(10),
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Centro',
                        style: TextStyle(
                          fontSize: calculateFontSize(9),
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '3 slots',
                        style: TextStyle(
                          fontSize: calculateFontSize(9),
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ] else ...[
            // Dia sem disponibilidade
            Expanded(
              child: Center(
                child: Icon(
                  Icons.remove,
                  size: DSSize.width(14),
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityIndicator(Map<String, dynamic> dayState, ColorScheme colorScheme) {
    Color color;
    IconData icon;
    String label;

    if (dayState['isBlocked']) {
      color = Colors.red.shade400;
      icon = Icons.block;
      label = 'Bloqueado';
    } else if (dayState['isPartial']) {
      color = Colors.orange.shade400;
      icon = Icons.access_time;
      label = 'Parcial';
    } else if (dayState['hasAvailability']) {
      color = Colors.green.shade400;
      icon = Icons.check_circle;
      label = 'Disponível';
    } else {
      color = colorScheme.onSurfaceVariant;
      icon = Icons.remove_circle_outline;
      label = 'Sem agenda';
    }

    return Row(
      children: [
        Icon(icon, size: DSSize.width(10), color: color),
        SizedBox(width: DSSize.width(4)),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: calculateFontSize(9),
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
