import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/enums/time_slot_status_enum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget de calendário estilo Airbnb
/// 
/// Características:
/// - Cards GRANDES (150px+ de altura)
/// - Scroll vertical contínuo
/// - Informações visíveis por dia
/// - Seleção com fundo escuro
/// - Seleção de período (long press + arrastar)
class CalendarWidget extends StatefulWidget {
  final List<AvailabilityDayEntity> availabilities; // Dados reais de disponibilidade
  final DateTime? selectedDay;
  final List<DateTime>? selectedDays; // Para seleção múltipla persistente
  final void Function(DateTime day)? onDaySelected; // Seleção única
  final void Function(List<DateTime> days)? onDaysSelected; // Seleção múltipla (ao soltar)
  final VoidCallback? onClearSelection; // Para limpar seleção

  const CalendarWidget({
    super.key,
    this.availabilities = const [],
    this.selectedDay,
    this.selectedDays,
    this.onDaySelected,
    this.onDaysSelected,
    this.onClearSelection,
  });

  @override
  State<CalendarWidget> createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final ScrollController _scrollController = ScrollController();
  late final DateTime _startDate;
  late final DateTime _endDate;
  
  // Estado para seleção de período
  bool _isSelecting = false;
  DateTime? _selectionStart;
  DateTime? _selectionEnd;
  final Map<DateTime, GlobalKey> _dayKeys = {};
  
  // Cache de disponibilidades por data (para lookup rápido)
  late Map<String, AvailabilityDayEntity> _availabilityMap;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Mostrar desde o primeiro dia do mês atual (incluindo dias passados)
    _startDate = DateTime(now.year, now.month, 1);
    
    // Até exatamente 1 ano a partir de hoje
    _endDate = today.add(const Duration(days: 365));
    
    // Criar mapa de disponibilidades por data
    _buildAvailabilityMap();
  }
  
  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualizar mapa quando availabilities mudam
    if (oldWidget.availabilities != widget.availabilities) {
      _buildAvailabilityMap();
    }
  }
  
  /// Constrói mapa de disponibilidades indexado por data (YYYY-MM-DD)
  void _buildAvailabilityMap() {
    _availabilityMap = {};
    for (final availability in widget.availabilities) {
      final dateKey = _getDateKey(availability.date);
      _availabilityMap[dateKey] = availability;
    }
  }
  
  /// Retorna chave de data no formato YYYY-MM-DD
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Obtém disponibilidade para um dia específico
  AvailabilityDayEntity? _getAvailabilityForDay(DateTime day) {
    final dateKey = _getDateKey(day);
    return _availabilityMap[dateKey];
  }
  
  /// Verifica se o dia tem disponibilidade ativa
  bool _hasAvailability(DateTime day) {
    final availability = _getAvailabilityForDay(day);
    if (availability == null) return false;
    
    // Verificar se está ativo e tem slots
    return availability.isActive && 
           availability.slots!.isNotEmpty;
  }
  
  /// Conta quantidade de slots disponíveis no dia
  int _getAvailableSlotsCount(DateTime day) {
    final availability = _getAvailabilityForDay(day);
    if (availability == null) return 0;
    
    // Contar total de slots disponíveis
    return availability.slots
        ?.where((slot) => slot.status == TimeSlotStatusEnum.available)
        .length ?? 0;
  }
  
  /// Verifica se a disponibilidade está desativada
  bool _isAvailabilityInactive(DateTime day) {
    final availability = _getAvailabilityForDay(day);
    if (availability == null) return false;
    
    // Tem disponibilidade mas está inativa
    return !availability.isActive && availability.slots!.isNotEmpty;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Faz scroll até o dia de hoje
  void scrollToToday() {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
        
    // Calcular a posição aproximada do dia de hoje
    final position = _calculateScrollPositionForDate(todayNormalized);
    
    if (position == null) {
      return;
    }
    
    // Fazer scroll animado até a posição calculada
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    ).then((_) {
    });
  }
  
  /// Calcula a posição de scroll para uma data específica
  double? _calculateScrollPositionForDate(DateTime targetDate) {
    // Altura aproximada de cada componente
    const double monthHeaderHeight = 60.0;   // Header do mês
    const double dayCardHeight = 118.0;      // Card do dia (110 + 4 de espaçamento + 4 de margin)
    const double monthSpacing = 8.0;         // Espaçamento entre meses
    
    double totalHeight = 0.0;
    
    // Adicionar altura do header de dias da semana (fixo no topo)
    // totalHeight += weekdayHeaderHeight; // Não conta pois não está no ListView
    
    // Gerar e agrupar todos os dias
    final allDays = _generateDays();
    final monthsMap = _groupByMonth(allDays);
    
    // Calcular altura até o mês do targetDate
    for (final monthEntry in monthsMap.entries) {
      final daysInMonth = monthEntry.value;
      final firstDayOfMonth = daysInMonth.first;
      
      // Adicionar altura do header do mês
      totalHeight += monthHeaderHeight;
      
      // Se o targetDate é neste mês, calcular posição específica
      if (firstDayOfMonth.year == targetDate.year &&
          firstDayOfMonth.month == targetDate.month) {
        
        // Calcular quantas semanas (rows) até o targetDate
        final firstDay = daysInMonth.first;
        final weekdayOffset = firstDay.weekday % 7;
        
        // Encontrar o índice do targetDate na lista de dias do mês
        int dayIndex = -1;
        for (int i = 0; i < daysInMonth.length; i++) {
          final day = daysInMonth[i];
          if (day.year == targetDate.year &&
              day.month == targetDate.month &&
              day.day == targetDate.day) {
            dayIndex = i;
            break;
          }
        }
        
        if (dayIndex == -1) {
          return null; // Dia não encontrado
        }
        
        // Calcular em qual row (semana) o dia está
        final positionInMonth = weekdayOffset + dayIndex;
        final rowIndex = positionInMonth ~/ 7;
        
        // Adicionar altura das rows anteriores
        totalHeight += rowIndex * dayCardHeight;
           
        return totalHeight;
      }
      
      // Se não é este mês, adicionar altura total do mês
      final firstDay = daysInMonth.first;
      final weekdayOffset = firstDay.weekday % 7;
      final totalDaysInGrid = weekdayOffset + daysInMonth.length;
      final totalRows = (totalDaysInGrid / 7).ceil();
      
      totalHeight += totalRows * dayCardHeight;
      totalHeight += monthSpacing;
    }
    
    return null; // Data não encontrada
  }

  List<DateTime> _generateDays() {
    final days = <DateTime>[];
    var current = _startDate;
    
    while (current.isBefore(_endDate) || current.isAtSameMomentAs(_endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }

  Map<String, List<DateTime>> _groupByMonth(List<DateTime> days) {
    final grouped = <String, List<DateTime>>{};
    
    for (final day in days) {
      final monthKey = DateFormat('MMMM yyyy', 'pt_BR').format(day);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(day);
    }
    
    return grouped;
  }

  bool _isSelected(DateTime day) {
    // Verificar seleção única
    if (widget.selectedDay != null) {
      return day.year == widget.selectedDay!.year &&
             day.month == widget.selectedDay!.month &&
             day.day == widget.selectedDay!.day;
    }
    
    // Verificar seleção múltipla
    if (widget.selectedDays != null) {
      return widget.selectedDays!.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day
      );
    }
    
    // Verificar seleção temporária durante drag
    if (_isSelecting && _selectionStart != null && _selectionEnd != null) {
      return _isDateInRange(day, _selectionStart!, _selectionEnd!);
    }
    
    return false;
  }
  
  /// Verifica se uma data está dentro do range de seleção
  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    
    final actualStart = normalizedStart.isBefore(normalizedEnd) ? normalizedStart : normalizedEnd;
    final actualEnd = normalizedStart.isBefore(normalizedEnd) ? normalizedEnd : normalizedStart;
    
    return (normalizedDate.isAtSameMomentAs(actualStart) || normalizedDate.isAfter(actualStart)) &&
           (normalizedDate.isAtSameMomentAs(actualEnd) || normalizedDate.isBefore(actualEnd));
  }
  
  /// Calcula todas as datas no range selecionado
  List<DateTime> _getDatesInRange(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    
    final actualStart = normalizedStart.isBefore(normalizedEnd) ? normalizedStart : normalizedEnd;
    final actualEnd = normalizedStart.isBefore(normalizedEnd) ? normalizedEnd : normalizedStart;
    
    final dates = <DateTime>[];
    var current = actualStart;
    
    while (current.isBefore(actualEnd) || current.isAtSameMomentAs(actualEnd)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }
  
  /// Encontra qual dia está sendo tocado baseado na posição global
  DateTime? _findDayAtPosition(Offset globalPosition) {
    for (final entry in _dayKeys.entries) {
      final key = entry.value;
      final day = entry.key;
      
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        
        if (globalPosition.dx >= position.dx &&
            globalPosition.dx <= position.dx + size.width &&
            globalPosition.dy >= position.dy &&
            globalPosition.dy <= position.dy + size.height) {
          return day;
        }
      }
    }
    return null;
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year &&
           day.month == now.month &&
           day.day == now.day;
  }

  bool _isPast(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDay = DateTime(day.year, day.month, day.day);
    return checkDay.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allDays = _generateDays();
    final monthsMap = _groupByMonth(allDays);

    return Column(
      children: [
        // Header com dias da semana
        _buildWeekdayHeader(colorScheme),
        
        // Calendário scrollável
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: DSSize.width(8),
              right: DSSize.width(8),
              bottom: DSSize.height(80), // Espaço para FAB
            ),
            itemCount: monthsMap.length,
            itemBuilder: (context, monthIndex) {
              final monthEntry = monthsMap.entries.elementAt(monthIndex);
              final monthName = monthEntry.key;
              final daysInMonth = monthEntry.value;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header do mês
                  _buildMonthHeader(monthName, colorScheme),
                  
                  SizedBox(height: DSSize.height(4)),
                  
                  // Grid de dias
                  _buildMonthGrid(daysInMonth, colorScheme),
                  
                  SizedBox(height: DSSize.height(8)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(ColorScheme colorScheme) {
    const weekdays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(4),
        vertical: DSSize.height(8),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: calculateFontSize(12),
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthHeader(String monthName, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(
        left: DSSize.width(4),
        top: DSSize.height(16),
        bottom: DSSize.height(8),
      ),
      child: Text(
        monthName,
        style: TextStyle(
          fontSize: calculateFontSize(20),
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildMonthGrid(List<DateTime> daysInMonth, ColorScheme colorScheme) {
    // Calcular offset do primeiro dia do mês
    final firstDay = daysInMonth.first;
    final weekdayOffset = firstDay.weekday % 7;
    
    // Criar lista com dias vazios no início
    final displayDays = <DateTime?>[];
    for (var i = 0; i < weekdayOffset; i++) {
      displayDays.add(null);
    }
    displayDays.addAll(daysInMonth);
    
    // Criar rows de 7 dias
    final rows = <Widget>[];
    for (var i = 0; i < displayDays.length; i += 7) {
      final weekDays = displayDays.sublist(
        i,
        i + 7 > displayDays.length ? displayDays.length : i + 7,
      );
      
      // Preencher última semana com nulls se necessário
      while (weekDays.length < 7) {
        weekDays.add(null);
      }
      
      rows.add(_buildWeekRow(weekDays, colorScheme));
      rows.add(SizedBox(height: DSSize.height(4)));
    }
    
    return Column(children: rows);
  }

  Widget _buildWeekRow(List<DateTime?> weekDays, ColorScheme colorScheme) {
    return Row(
      children: weekDays.map((day) {
        if (day == null) {
          return Expanded(child: SizedBox(height: DSSize.height(120), ));
        }
        return Expanded(
          child: _buildDayCard(day, colorScheme),
        );
      }).toList(),
    );
  }

  Widget _buildDayCard(DateTime day, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    final isSelected = _isSelected(day);
    final isToday = _isToday(day);
    final isPast = _isPast(day);
    
    // Criar GlobalKey para este dia (normalizado)
    final normalizedDay = DateTime(day.year, day.month, day.day);
    if (!_dayKeys.containsKey(normalizedDay)) {
      _dayKeys[normalizedDay] = GlobalKey();
    }
    
    // Dados reais de disponibilidade
    final hasAvailability = _hasAvailability(day);
    final slotsCount = _getAvailableSlotsCount(day);
    final isInactive = _isAvailabilityInactive(day);
    
    return GestureDetector(
      onTap: () {
        // Não permitir seleção de dias passados
        if (isPast) {
          return;
        }
        
        // Tap simples: seleção única
        if (widget.onDaySelected != null) {
          widget.onDaySelected!(day);
        }
      },
      onLongPressStart: (details) {
        // Não permitir seleção de dias passados
        if (isPast) {
          return;
        }
        
        // Iniciar seleção de período
        setState(() {
          _isSelecting = true;
          _selectionStart = day;
          _selectionEnd = day;
        });
      },
      onLongPressMoveUpdate: (details) {
        // Atualizar seleção enquanto arrasta
        if (_isSelecting) {
          final dayAtPosition = _findDayAtPosition(details.globalPosition);
          if (dayAtPosition != null && dayAtPosition != _selectionEnd) {
            setState(() {
              _selectionEnd = dayAtPosition;
            });
          }
        }
      },
      onLongPressEnd: (details) {
        // Finalizar seleção e notificar
        if (_isSelecting && _selectionStart != null && _selectionEnd != null) {
          final selectedDates = _getDatesInRange(_selectionStart!, _selectionEnd!);
          
          // Filtrar dias passados da seleção
          final today = DateTime.now();
          final todayNormalized = DateTime(today.year, today.month, today.day);
          final validDates = selectedDates.where((date) {
            final normalized = DateTime(date.year, date.month, date.day);
            return !normalized.isBefore(todayNormalized);
          }).toList();
          
          // Limpa estado de drag mas mantém seleção via parent
          setState(() {
            _isSelecting = false;
            _selectionStart = null;
            _selectionEnd = null;
          });
          
          // Verificar se há datas válidas
          if (validDates.isEmpty) {
            return;
          }
          
          // Notifica parent com as datas válidas selecionadas
          if (widget.onDaysSelected != null) {
            widget.onDaysSelected!(validDates);
          }
        }
      },
      child: AnimatedContainer(
        key: _dayKeys[normalizedDay], // ← Key no widget visual
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: DSSize.width(2)),
        height: DSSize.height(110),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.onPrimaryContainer
              : isPast
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.4) // Dias passados mais opacos
                  : colorScheme.primaryContainer,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : colorScheme.outline.withOpacity(0.2),
            width: 1, // Borda mais grossa para hoje
          ),
          borderRadius: BorderRadius.circular(DSSize.width(8)),
        ),
        child: Stack(
          children: [
            // Conteúdo do card
            Padding(
              padding: EdgeInsets.all(DSSize.width(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Número do dia
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bolinha indicadora de "hoje"
                      if (isToday)
                        Container(
                          width: DSSize.width(30),
                          height: DSSize.width(30),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: calculateFontSize(16),
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? colorScheme.primaryContainer
                                  : colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      
                      // Número do dia
                      if (!isToday) ...[
                        Text(
                          '${day.day}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: calculateFontSize(16),
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : isPast
                                    ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                                    : colorScheme.onSurface,
                          ),
                        ),
                      ]
                    ],
                  ),

                  DSSizedBoxSpacing.vertical(8),
                  
                  
                  // Informações de disponibilidade
                  if (isInactive && !isPast) ...[
                    // Disponibilidade desativada
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close,
                          size: DSSize.width(16),
                          color: colorScheme.error,
                        ),
                      ],
                    ),
                  ] else if (hasAvailability && !isPast) ...[    
                    // Disponibilidade ativa com slots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle, 
                          size: DSSize.width(12), 
                          color: colorScheme.onSecondaryContainer,
                        ),
                        DSSizedBoxSpacing.horizontal(4),

                        Text(
                          '$slotsCount',
                          style: textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  ] else if (isPast) ...[
                    // Dias passados mostram como expirados (centralizado)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close,
                          size: DSSize.width(14),
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Dias sem disponibilidade - Bloqueado (centralizado)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle_outlined,
                          size: DSSize.width(14),
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ],
                    ),
                  ],
                  
                  // TODO: Adicionar indicador de shows quando houver integração
                  // Exemplo: if (hasShows) ... Icon(Icons.mic, ...) + Text('$showsCount')
                  
                  // Espaçador para manter altura consistente
                  if (!hasAvailability && !isPast) ...[
                    SizedBox(height: DSSize.height(4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: calculateFontSize(14),
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.onSurfaceVariant.withOpacity(0.3),
                          ),
                        ),
                      ],
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
}
