import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/close_period_dto.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/open_period_dto.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/availability_bloc.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/calendar_widget.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/day_edit_bottom_sheet.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/forms/availability_form_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela de calendário estilo Airbnb
/// Integrada com BLoC para gerenciar disponibilidades
class AvailabilityCalendarScreen extends StatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  State<AvailabilityCalendarScreen> createState() => _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState extends State<AvailabilityCalendarScreen> {
  DateTime? _selectedDay;
  List<DateTime>? _selectedDays; // Para seleção de período
  final GlobalKey<CalendarWidgetState> _calendarKey = GlobalKey<CalendarWidgetState>();
  List<AvailabilityDayEntity> _availabilities = []; // Cache local dos dados

  @override
  void initState() {
    super.initState();
    // Carregar disponibilidades ao iniciar a tela
    _loadAvailabilities();
  }

  /// Carrega as disponibilidades do BLoC
  void _loadAvailabilities({bool forceRemote = false}) {
    context.read<AvailabilityBloc>().add(
      GetAllAvailabilitiesEvent(forceRemote: forceRemote),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AvailabilityBloc, AvailabilityState>(
      listener: (context, state) {
        // ════════════════════════════════════════════════════════════════
        // SUCESSO Toggle Status
        // ════════════════════════════════════════════════════════════════
        if (state is ToggleAvailabilityStatusSuccessState) {
          context.showSuccess(state.message);
          _loadAvailabilities(forceRemote: true);
        }
        else if (state is ToggleAvailabilityStatusErrorState) {
          context.showError(state.message);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO Update Address/Radius
        // ════════════════════════════════════════════════════════════════
        else if (state is UpdateAddressRadiusSuccessState) {
          context.showSuccess(state.message);
          _loadAvailabilities(forceRemote: true);
        }
        else if (state is UpdateAddressRadiusErrorState) {
          context.showError(state.message);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO Add Slot
        // ════════════════════════════════════════════════════════════════
        else if (state is AddTimeSlotSuccessState) {
          context.showSuccess(state.message);
          _loadAvailabilities(forceRemote: true);
        }
        else if (state is AddTimeSlotErrorState) {
          context.showError(state.message);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO Update Slot
        // ════════════════════════════════════════════════════════════════
        else if (state is UpdateTimeSlotSuccessState) {
          context.showSuccess(state.message);
          _loadAvailabilities(forceRemote: true);
        }
        else if (state is UpdateTimeSlotErrorState) {
          context.showError(state.message);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO Delete Slot
        // ════════════════════════════════════════════════════════════════
        else if (state is DeleteTimeSlotSuccessState) {
          context.showSuccess(state.message);
          _loadAvailabilities(forceRemote: true);
        }
        else if (state is DeleteTimeSlotErrorState) {
          context.showError(state.message);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO Open Period
        // ════════════════════════════════════════════════════════════════
        else if (state is OpenPeriodSuccessState) {
          context.showSuccess(state.message);
          _loadAvailabilities(forceRemote: true);
        }
        else if (state is OpenPeriodErrorState) {
          context.showError(state.message);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO Close Period
        // ════════════════════════════════════════════════════════════════
        else if (state is ClosePeriodSuccessState) {
          context.showSuccess(state.message);
          _loadAvailabilities(forceRemote: true);
        }
        else if (state is ClosePeriodErrorState) {
          context.showError(state.message);
        }
        
        // ════════════════════════════════════════════════════════════════
        // ERRO GetAll
        // ════════════════════════════════════════════════════════════════
        else if (state is GetAllAvailabilitiesErrorState) {
          context.showError(state.message);
        }
      },
      child: BlocBuilder<AvailabilityBloc, AvailabilityState>(
        builder: (context, state) {
          // Atualizar cache local quando dados são carregados
          if (state is AllAvailabilitiesLoadedState) {
            _availabilities = state.days;
          }

          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: SafeArea(
              bottom: false,
              top: true,
              child: Column(
                children: [
                  // Barra de ações no topo
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: DSSize.width(8),
                      vertical: DSSize.height(4),
                    ),
                    child: Row(
                      children: [
                        // Botão limpar seleção (aparece quando tem seleção múltipla)
                        if (_selectedDays != null && _selectedDays!.isNotEmpty) ...[
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedDays = null;
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              size: DSSize.width(18),
                              color: colorScheme.error,
                            ),
                            label: Text(
                              'Limpar (${_selectedDays!.length} dias)',
                              style: TextStyle(
                                fontSize: DSSize.width(13),
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        
                        const Spacer(),
                        
                        // Botão de informações (legenda)
                        IconButton(
                          onPressed: () {
                            _showLegendModal();
                          },
                          icon: Icon(
                            Icons.info_outline,
                            size: DSSize.width(22),
                            color: colorScheme.onSurfaceVariant,
                          ),
                          tooltip: 'Legenda',
                        ),
                        SizedBox(width: DSSize.width(8)),
                        
                        // Botão adicionar disponibilidade
                        IconButton(
                          onPressed: () {
                            _showCreateAvailabilityModal();
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: DSSize.width(24),
                            color: colorScheme.onPrimaryContainer,
                          ),
                          tooltip: 'Adicionar disponibilidade',
                        ),
                      ],
                    ),
                  ),
                  
                  // Calendário ou Loading
                  Expanded(
                    child: _buildCalendarOrLoading(state, colorScheme),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                // Selecionar hoje e fazer scroll até o dia
                setState(() {
                  _selectedDay = DateTime.now();
                  _selectedDays = null;
                });
                
                // Fazer scroll até o dia de hoje
                _calendarKey.currentState?.scrollToToday();
              },
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              icon: Icon(Icons.arrow_upward, size: DSSize.width(20)),
              label: Text('Hoje', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSSize.width(24)),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  /// Constrói o calendário ou tela de loading baseado no estado
  Widget _buildCalendarOrLoading(AvailabilityState state, ColorScheme colorScheme) {
    // ════════════════════════════════════════════════════════════════
    // LOADING
    // ════════════════════════════════════════════════════════════════
    if (state is GetAllAvailabilitiesLoadingState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            if (state.message != null) ...[
              SizedBox(height: DSSize.height(16)),
              Text(
                state.message!,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: DSSize.width(14),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // ════════════════════════════════════════════════════════════════
    // DADOS CARREGADOS → Renderizar calendário
    // ════════════════════════════════════════════════════════════════
    if (state is AllAvailabilitiesLoadedState || _availabilities.isNotEmpty) {
      return CalendarWidget(
        key: _calendarKey,
        availabilities: _availabilities, // Passar dados reais
        selectedDay: _selectedDay,
        selectedDays: _selectedDays,
        onDaySelected: (day) {
          setState(() {
            _selectedDay = day;
            _selectedDays = null; // Limpa seleção múltipla
          });
          _showDayEditSheet(day);
        },
        onDaysSelected: (days) {
          setState(() {
            _selectedDays = days;
            _selectedDay = null; // Limpa seleção única
          });
          _showPeriodFormModal(days);
        },
        onClearSelection: () {
          setState(() {
            _selectedDays = null;
          });
        },
      );
    }

    // ════════════════════════════════════════════════════════════════
    // INITIAL ou ERRO → Tela vazia com instrução
    // ════════════════════════════════════════════════════════════════
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: DSSize.width(64),
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          SizedBox(height: DSSize.height(16)),
          Text(
            'Nenhuma disponibilidade encontrada',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: DSSize.width(16),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: DSSize.height(8)),
          Text(
            'Toque no + para adicionar',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: DSSize.width(14),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayEditSheet(DateTime day) {
    // Buscar disponibilidade do dia
    final availability = _getAvailabilityForDay(day);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayEditBottomSheet(
        selectedDate: day,
        availability: availability,
        onClose: () {
          Navigator.of(context).pop();
          setState(() {
            _selectedDay = null;
          });
        },
        onToggleStatus: (isActive) => _onToggleAvailabilityStatus(day, availability, isActive),
        onAddAvailability: () => _onAddAvailabilityForDay(day),
        onUpdateAddressRadius: (address, radius) => _onUpdateAddressRadius(day, address, radius),
        onAddSlot: (startTime, endTime, pricePerHour) => _onAddSlot(day, startTime, endTime, pricePerHour),
        onUpdateSlot: (slotId, startTime, endTime, pricePerHour) => _onUpdateSlot(day, slotId, startTime, endTime, pricePerHour),
        onDeleteSlot: (slotId) => _onDeleteSlot(day, slotId),
      ),
    );
  }
  
  /// Busca disponibilidade de um dia específico
  AvailabilityDayEntity? _getAvailabilityForDay(DateTime day) {
    final dateKey = _getDateKey(day);
    for (final availability in _availabilities) {
      if (_getDateKey(availability.date) == dateKey) {
        return availability;
      }
    }
    return null;
  }
  
  /// Retorna chave de data no formato YYYY-MM-DD
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Callbacks dos Eventos de Disponibilidade
  // ════════════════════════════════════════════════════════════════════════════

  /// Callback para ativar/desativar disponibilidade do dia
  void _onToggleAvailabilityStatus(
    DateTime day,
    AvailabilityDayEntity? availability,
    bool isActive,
  ) {
    // Só permite toggle se já existe disponibilidade
    if (availability == null) return;
    
    // Criar DTO e disparar evento
    context.read<AvailabilityBloc>().add(
      ToggleAvailabilityStatusEvent(
        ToggleAvailabilityStatusDto(
          date: day,
          isActive: isActive,
        ),
      ),
    );
    
    Navigator.of(context).pop();
  }

  /// Callback para adicionar disponibilidade em um dia específico
  Future<void> _onAddAvailabilityForDay(DateTime day) async {
    // Fecha o bottom sheet atual
    Navigator.of(context).pop();
    
    // Abre o modal de disponibilidade com o dia pré-preenchido
    await _showAvailabilityFormModal(
      initialStartDate: day,
      initialEndDate: day,
    );
  }

  /// Callback para atualizar endereço e raio de atuação
  void _onUpdateAddressRadius(
    DateTime day,
    AddressInfoEntity address,
    double radius,
  ) {
    // Disparar evento para atualizar endereço e raio
    context.read<AvailabilityBloc>().add(
      UpdateAddressRadiusEvent(
        UpdateAddressRadiusDto(
          date: day,
          addressRadius: AddressRadiusDto(
            addressId: address.uid ?? '',
            raioAtuacao: radius,
            endereco: address,
          ),
        ),
      ),
    );
    
    Navigator.of(context).pop();
  }

  /// Callback para adicionar novo slot de horário
  void _onAddSlot(
    DateTime day,
    String startTime,
    String endTime,
    double pricePerHour,
  ) {
    // Disparar evento para adicionar slot
    context.read<AvailabilityBloc>().add(
      AddTimeSlotEvent(
        SlotOperationDto.add(
          date: day,
          startTime: startTime,
          endTime: endTime,
          valorHora: pricePerHour,
        ),
      ),
    );
    
    Navigator.of(context).pop();
  }

  /// Callback para atualizar slot de horário existente
  void _onUpdateSlot(
    DateTime day,
    String slotId,
    String? startTime,
    String? endTime,
    double? pricePerHour,
  ) {
    // Disparar evento para atualizar slot
    context.read<AvailabilityBloc>().add(
      UpdateTimeSlotEvent(
        SlotOperationDto.update(
          date: day,
          slotId: slotId,
          startTime: startTime,
          endTime: endTime,
          valorHora: pricePerHour,
        ),
      ),
    );
    
    Navigator.of(context).pop();
  }

  /// Callback para deletar slot de horário
  void _onDeleteSlot(
    DateTime day,
    String slotId,
  ) {
    // Disparar evento para deletar slot
    context.read<AvailabilityBloc>().add(
      DeleteTimeSlotEvent(
        SlotOperationDto.delete(
          date: day,
          slotId: slotId,
          deleteIfEmpty: true, // Deletar dia se ficar sem slots
        ),
      ),
    );
    
    Navigator.of(context).pop();
  }

  /// Abre o modal de disponibilidade com datas específicas
  Future<void> _showAvailabilityFormModal({
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) async {
    await AvailabilityFormModal.show(
      context: context,
      initialStartDate: initialStartDate,
      initialEndDate: initialEndDate,
      onOpenPeriod: _onOpenPeriod,
      onClosePeriod: _onClosePeriod,
    );
  }

  Future<void> _showPeriodFormModal(List<DateTime> days) async {
    if (days.isEmpty) return;
    
    // Ordenar datas para pegar a menor e a maior
    final sortedDays = List<DateTime>.from(days)
      ..sort((a, b) => a.compareTo(b));
    
    final startDate = sortedDays.first;
    final endDate = sortedDays.last;
    
    await _showAvailabilityFormModal(
      initialStartDate: startDate,
      initialEndDate: endDate,
    );
    
    // Limpar seleção após fechar o modal
    setState(() {
      _selectedDays = null;
    });
  }

  Future<void> _showCreateAvailabilityModal() async {
    await _showAvailabilityFormModal();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Callbacks de Períodos
  // ════════════════════════════════════════════════════════════════════════════

  /// Callback para abrir período de disponibilidade
  void _onOpenPeriod(OpenPeriodDto dto) {
    context.read<AvailabilityBloc>().add(
      OpenPeriodEvent(dto),
    );
  }

  /// Callback para fechar/bloquear período de disponibilidade
  void _onClosePeriod(ClosePeriodDto dto) {
    context.read<AvailabilityBloc>().add(
      ClosePeriodEvent(dto),
    );
  }

  void _showLegendModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLegendBottomSheet(),
    );
  }

  Widget _buildLegendBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSecondaryContainer = colorScheme.onSecondaryContainer;
    final onTertiaryContainer = colorScheme.onTertiaryContainer;
    final error = colorScheme.error;
    final showColor = Colors.purple;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      padding: EdgeInsets.all(DSSize.width(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              width: DSSize.width(40),
              height: DSSize.height(4),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),

          // Título
          Text(
            'Legenda',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          SizedBox(height: DSSize.height(8)),

          Text(
            'Entenda os ícones do calendário',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: DSSize.height(24)),

          // Lista de legendas
          _buildLegendItem(
            icon: Icons.check_circle,
            label: 'Intervalos disponíveis',
            description: 'Número de slots de horário livres',
            color: onSecondaryContainer,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          SizedBox(height: DSSize.height(16)),

          _buildLegendItem(
            icon: Icons.circle_outlined,
            label: 'Fechado',
            description: 'Dia sem disponibilidades cadastradas',
            color: onTertiaryContainer,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          SizedBox(height: DSSize.height(16)),

          _buildLegendItem(
            icon: Icons.close,
            label: 'Inativo',
            description: 'Disponibilidade desativada',
            color: error,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          SizedBox(height: DSSize.height(16)),

          _buildLegendItem(
            icon: Icons.mic,
            label: 'Shows',
            description: 'Número de apresentações confirmadas',
            color: showColor,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          SizedBox(height: DSSize.height(24)),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      children: [
        // Ícone
        Container(
          width: DSSize.width(40),
          height: DSSize.width(40),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DSSize.width(8)),
          ),
          child: Icon(
            icon,
            size: DSSize.width(20),
            color: color,
          ),
        ),

        SizedBox(width: DSSize.width(16)),

        // Textos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: DSSize.height(2)),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
