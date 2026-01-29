import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/dialog_button.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/check_overlaps_dto.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/open_period_dto.dart';
import 'package:app/features/profile/artist_availability/domain/entities/check_overlap_on_day_result.dart';
import 'package:app/features/profile/artist_availability/domain/entities/day_overlap_info.dart';
import 'package:app/features/profile/artist_availability/domain/entities/organized_availabilities_after_verification_result_entity.dart.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/availability_bloc.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/calendar_widget.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/day_edit_bottom_sheet.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/forms/availability_confirmation_dialog.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/forms/availability_form_modal.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/check_overlap_on_day_dto.dart';
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
  CheckOverlapsDto? _lastCheckOverlapsDto; // Guarda o DTO original para criar OpenPeriodDto
  
  // Variáveis para guardar contexto de operação de slot (add/update)
  String? _pendingSlotOperation; // 'add' ou 'update'
  // ignore: unused_field
  String? _pendingSlotId; // Para update
  DateTime? _pendingSlotDate;
  String? _pendingSlotStartTime; // Horário de início do slot pendente
  String? _pendingSlotEndTime; // Horário de fim do slot pendente
  double? _pendingSlotPricePerHour; // Valor por hora do slot pendente

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

  /// Atualiza o cache local de disponibilidades com novos/atualizados dias
  /// 
  /// Substitui ou adiciona os dias na lista local, mantendo os demais intactos
  void _updateAvailabilitiesCache(List<AvailabilityDayEntity> updatedDays) {
    setState(() {
      // Criar um mapa das novas disponibilidades por data
      final updatedMap = <String, AvailabilityDayEntity>{};
      for (final day in updatedDays) {
        final dateKey = _getDateKey(day.date);
        updatedMap[dateKey] = day;
      }

      // Atualizar ou adicionar os dias no cache local
      final updatedList = <AvailabilityDayEntity>[];
      final processedDates = <String>{};

      // Primeiro, adicionar todos os dias existentes (exceto os que foram atualizados)
      for (final existingDay in _availabilities) {
        final dateKey = _getDateKey(existingDay.date);
        if (updatedMap.containsKey(dateKey)) {
          // Substituir pelo dia atualizado
          updatedList.add(updatedMap[dateKey]!);
          processedDates.add(dateKey);
        } else {
          // Manter o dia existente
          updatedList.add(existingDay);
          processedDates.add(dateKey);
        }
      }

      // Depois, adicionar os novos dias que não existiam antes
      for (final newDay in updatedDays) {
        final dateKey = _getDateKey(newDay.date);
        if (!processedDates.contains(dateKey)) {
          updatedList.add(newDay);
        }
      }

      _availabilities = updatedList;
    });
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
        if (state is ToggleAvailabilityStatusSuccess) {
          context.showSuccess('Status atualizado com sucesso');
          _loadAvailabilities(forceRemote: true);
        } else if (state is ToggleAvailabilityStatusFailure) {
          context.showError(state.error);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO/ERRO Get Organized Day After Verification (para slots)
        // ════════════════════════════════════════════════════════════════
        if (state is GetOrganizedDayAfterVerificationSuccess) {
          _handleOrganizedDayResult(state.result);
        } else if (state is GetOrganizedDayAfterVerificationFailure) {
          context.showError(state.error);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO/ERRO Get Organized Availabilities After Verification
        // ════════════════════════════════════════════════════════════════
        if (state is OpenOrganizedAvailabilitiesSuccess) {
          _handleOrganizedAvailabilitiesResult(
            state.result,
            originalDto: _lastCheckOverlapsDto!,
            isClose: false,
          );
        } else if (state is CloseOrganizedAvailabilitiesSuccess) {
          _handleOrganizedAvailabilitiesResult(
            state.result,
            originalDto: _lastCheckOverlapsDto!,
            isClose: true,
          );
        } else if (state is GetOrganizedAvailabilitiesAfterVerificationFailure) {
          context.showError(state.error);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO Add/Update/Delete Time Slot
        // ════════════════════════════════════════════════════════════════
        if (state is AddTimeSlotSuccess || 
            state is UpdateTimeSlotSuccess || 
            state is DeleteTimeSlotSuccess) {
          context.showSuccess('Alteração realizada com sucesso');
          _loadAvailabilities(forceRemote: true);
          // Fechar bottom sheet se estiver aberto
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else if (state is UpdateAddressAndRadiusSuccess) {
          context.showSuccess('Endereço e raio atualizados com sucesso');
          _loadAvailabilities(forceRemote: true);
          // Não fechar o bottom sheet automaticamente para update de endereço/raio
          // O usuário pode querer continuar editando
        } else if (state is AddTimeSlotFailure) {
          context.showError(state.error);
        } else if (state is UpdateTimeSlotFailure) {
          context.showError(state.error);
        } else if (state is DeleteTimeSlotFailure) {
          context.showError(state.error);
        } else if (state is UpdateAddressAndRadiusFailure) {
          context.showError(state.error);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO/ERRO Open Period
        // ════════════════════════════════════════════════════════════════
        if (state is OpenPeriodSuccess) {
          // Atualizar cache local imediatamente com os dias criados/atualizados
          _updateAvailabilitiesCache(state.days);
          // Recarregar do servidor para garantir sincronização
          _loadAvailabilities(forceRemote: true);
          context.showSuccess('Período aberto com sucesso');
        } else if (state is OpenPeriodFailure) {
          context.showError(state.error);
        }
        
        // ════════════════════════════════════════════════════════════════
        // SUCESSO/ERRO Close Period
        // ════════════════════════════════════════════════════════════════
        if (state is ClosePeriodSuccess) {
          // Atualizar cache local imediatamente com os dias atualizados
          _updateAvailabilitiesCache(state.days);
          // Recarregar do servidor para garantir sincronização
          _loadAvailabilities(forceRemote: true);
          context.showSuccess('Período fechado com sucesso');
        } else if (state is ClosePeriodFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<AvailabilityBloc, AvailabilityState>(
        builder: (context, state) {
          // Atualizar cache local quando dados são carregados
          if (state is GetAllAvailabilitiesSuccess) {
            // Usar WidgetsBinding para atualizar após o frame atual
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _availabilities != state.availabilities) {
                setState(() {
                  _availabilities = state.availabilities;
                });
              }
            });
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
                        DSSizedBoxSpacing.horizontal(8),
                        // Botão limpar seleção (aparece quando tem seleção múltipla)
                        Text('Disponibilidades', 
                        style: textTheme.titleSmall?.copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),),
                        
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
    if (state is GetAllAvailabilitiesLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLoadingIndicator(),
          ],
        ),
      );
    }

    // ════════════════════════════════════════════════════════════════
    // DADOS CARREGADOS → Renderizar calendário
    // ════════════════════════════════════════════════════════════════
    if (state is GetAllAvailabilitiesSuccess || _availabilities.isNotEmpty) {
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
    if (availability == null) {
      context.showError('Dia não pode ser ativado sem intervalos disponíveis');
      return;
    }

    if (availability.slots!.isEmpty && isActive) {
      context.showError('Dia não pode ser ativado sem intervalos disponíveis');
      return;
    }

    // Criar entidade atualizada apenas com isActive
    final updatedDay = availability.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
    
    // Disparar evento diretamente
    context.read<AvailabilityBloc>().add(
      ToggleAvailabilityDayEvent(dayEntity: updatedDay),
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
    // Buscar disponibilidade atual do dia
    final availability = _getAvailabilityForDay(day);
    if (availability == null) {
      context.showError('Dia não encontrado');
      return;
    }
    
    // Criar entidade atualizada com novo endereço e raio
    final updatedDay = availability.copyWith(
      endereco: address,
      raioAtuacao: radius,
      updatedAt: DateTime.now(),
    );
    
    // Disparar evento diretamente
    // O bottom sheet será fechado quando o estado de sucesso for emitido
    context.read<AvailabilityBloc>().add(
      UpdateAddressAndRadiusEvent(dayEntity: updatedDay),
    );
  }

  /// Callback para adicionar novo slot de horário
  void _onAddSlot(
    DateTime day,
    String startTime,
    String endTime,
    double pricePerHour,
  ) {
    // Buscar disponibilidade atual do dia
    final availability = _getAvailabilityForDay(day);
    
    // Criar DTO para verificação de overlap
    final dto = CheckOverlapOnDayDto(
      startTime: startTime,
      endTime: endTime,
      valorHora: pricePerHour,
      endereco: availability?.endereco,
      raioAtuacao: availability?.raioAtuacao,
    );
    
    // Guardar contexto da operação
    _pendingSlotOperation = 'add';
    _pendingSlotDate = day;
    _pendingSlotId = null;
    _pendingSlotStartTime = startTime;
    _pendingSlotEndTime = endTime;
    _pendingSlotPricePerHour = pricePerHour;
    
    // Disparar evento para verificar overlaps
    context.read<AvailabilityBloc>().add(
      GetOrganizedDayAfterVerificationEvent(
        date: day,
        dto: dto,
      ),
    );
  }

  /// Callback para atualizar slot de horário existente
  void _onUpdateSlot(
    DateTime day,
    String slotId,
    String? startTime,
    String? endTime,
    double? pricePerHour,
  ) {
    // Buscar disponibilidade atual do dia
    final availability = _getAvailabilityForDay(day);
    if (availability == null) {
      context.showError('Dia não encontrado');
      return;
    }
    
    // Buscar slot atual para pegar valores padrão
    final currentSlot = availability.slots?.firstWhere(
      (slot) => slot.slotId == slotId,
    );
    
    if (currentSlot == null) {
      context.showError('Slot não encontrado');
      return;
    }
    
    // Usar valores fornecidos ou manter os atuais
    final finalStartTime = startTime ?? currentSlot.startTime;
    final finalEndTime = endTime ?? currentSlot.endTime;
    final finalPricePerHour = pricePerHour ?? currentSlot.valorHora ?? 0.0;
    
    // Criar DTO para verificação de overlap
    final dto = CheckOverlapOnDayDto(
      startTime: finalStartTime,
      endTime: finalEndTime,
      valorHora: finalPricePerHour,
      endereco: availability.endereco,
      raioAtuacao: availability.raioAtuacao,
      slotId: slotId, // Passar o slotId para ignorar este slot na verificação
    );
    
    // Guardar contexto da operação
    _pendingSlotOperation = 'update';
    _pendingSlotDate = day;
    _pendingSlotId = slotId;
    _pendingSlotStartTime = finalStartTime;
    _pendingSlotEndTime = finalEndTime;
    _pendingSlotPricePerHour = finalPricePerHour;
    
    // Disparar evento para verificar overlaps
    context.read<AvailabilityBloc>().add(
      GetOrganizedDayAfterVerificationEvent(
        date: day,
        dto: dto,
      ),
    );
  }

  /// Callback para deletar slot de horário
  void _onDeleteSlot(
    DateTime day,
    String slotId,
  ) {
    // Buscar disponibilidade atual do dia
    final availability = _getAvailabilityForDay(day);
    if (availability == null) {
      context.showError('Dia não encontrado');
      return;
    }

    // Remover slot da lista
    final currentSlots = availability.slots ?? [];
    final updatedSlots = currentSlots.where((slot) => slot.slotId != slotId).toList();

    // Se não há mais slots, desativar o dia
    final isActive = updatedSlots.isNotEmpty ? availability.isActive : false;

    // Criar entidade atualizada sem o slot deletado
    final updatedDay = availability.copyWith(
      slots: updatedSlots,
      isActive: isActive,
      updatedAt: DateTime.now(),
    );

    // Disparar evento diretamente
    context.read<AvailabilityBloc>().add(
      DeleteTimeSlotEvent(dayEntity: updatedDay),
    );
    
    // Fechar o bottom sheet após deletar
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
      onSave: _onSavePeriod,
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

  /// Callback para salvar período (chamado pelo modal)
  /// 
  /// Recebe CheckOverlapsDto e isClose do modal e dispara o evento
  /// para verificar overlaps antes de criar/atualizar disponibilidades
  void _onSavePeriod(CheckOverlapsDto dto, bool isClose) {
    // Guardar o DTO original para usar depois na criação do OpenPeriodDto
    _lastCheckOverlapsDto = dto;
    
    debugPrint('🟢 [CALENDAR_SCREEN] _onSavePeriod chamado - isClose: $isClose');
    debugPrint('🟢 [CALENDAR_SCREEN] PatternId: ${dto.patternMetadata?.patternId}');
    debugPrint('🟢 [CALENDAR_SCREEN] StartTime: ${dto.startTime}');
    debugPrint('🟢 [CALENDAR_SCREEN] EndTime: ${dto.endTime}');
    
    context.read<AvailabilityBloc>().add(
      GetOrganizedAvailabilitiesAfterVerificationEvent(
        dto: dto,
        isClose: isClose,
      ),
    );
  }

  /// Trata o resultado da verificação de overlaps
  /// 
  /// Mostra dialog de confirmação se houver overlaps ou shows,
  /// ou processa diretamente se não houver conflitos
  Future<void> _handleOrganizedAvailabilitiesResult(
    OrganizedAvailabilitiesAfterVerificationResult result,
    {required CheckOverlapsDto originalDto, required bool isClose}
  ) async {
    final daysWithOverlap = result.daysWithOverlap;
    final daysWithBookedSlot = result.daysWithBookedSlot;
    final daysWithoutOverlap = result.daysWithoutOverlap;

    debugPrint('🟡 [CALENDAR_SCREEN] _handleOrganizedAvailabilitiesResult - isClose: $isClose');
    debugPrint('🟡 [CALENDAR_SCREEN] daysWithOverlap: ${daysWithOverlap.length}');
    debugPrint('🟡 [CALENDAR_SCREEN] daysWithBookedSlot: ${daysWithBookedSlot.length}');
    debugPrint('🟡 [CALENDAR_SCREEN] daysWithoutOverlap: ${daysWithoutOverlap.length}');
    
    // Log detalhado dos dias com overlap
    for (var i = 0; i < daysWithOverlap.length; i++) {
      final overlap = daysWithOverlap[i];
      debugPrint('🟡 [CALENDAR_SCREEN] Overlap[$i] - Date: ${overlap.date}, hasOverlap: ${overlap.hasOverlap}');
      debugPrint('🟡 [CALENDAR_SCREEN] Overlap[$i] - OldSlots: ${overlap.oldTimeSlots?.length ?? 0}');
      debugPrint('🟡 [CALENDAR_SCREEN] Overlap[$i] - NewSlots: ${overlap.newTimeSlots?.length ?? 0}');
      if (overlap.newTimeSlots != null) {
        for (var j = 0; j < overlap.newTimeSlots!.length; j++) {
          final slot = overlap.newTimeSlots![j];
          debugPrint('🟡 [CALENDAR_SCREEN] Overlap[$i] - NewSlot[$j]: ${slot.startTime}-${slot.endTime}, status: ${slot.status}, valorHora: ${slot.valorHora}');
        }
      }
    }

    // Se há overlaps ou shows, mostrar dialog de confirmação

    final confirmed = await AvailabilityConfirmationDialog.show(
      context: context,
      title: isClose ? 'Confirmar fechamento de período' : 'Confirmar abertura de período',
      isClose: isClose,
      checkOverlapsDto: originalDto,
      daysWithOverlap: daysWithOverlap,
      daysWithBookedSlot: daysWithBookedSlot,
      daysWithoutOverlap: daysWithoutOverlap,
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );

    if (confirmed == true) {
      // Criar OpenPeriodDto e chamar evento de abrir/fechar período
      final openPeriodDto = _createOpenPeriodDto(
        originalDto: originalDto,
        daysWithOverlap: daysWithOverlap,
        daysWithBookedSlot: daysWithBookedSlot,
        daysWithoutOverlap: daysWithoutOverlap,
      );

      debugPrint('🟠 [CALENDAR_SCREEN] Criando OpenPeriodDto para ${isClose ? "FECHAR" : "ABRIR"}');
      debugPrint('🟠 [CALENDAR_SCREEN] dayOverlapInfos: ${openPeriodDto.dayOverlapInfos.length}');
      debugPrint('🟠 [CALENDAR_SCREEN] daysWithBookedSlot: ${openPeriodDto.daysWithBookedSlot.length}');

      if (isClose) {
        debugPrint('🔴 [CALENDAR_SCREEN] Disparando ClosePeriodEvent');
        context.read<AvailabilityBloc>().add(
          ClosePeriodEvent(dto: openPeriodDto),
        );
      } else {
        debugPrint('🟢 [CALENDAR_SCREEN] Disparando OpenPeriodEvent');
        context.read<AvailabilityBloc>().add(
          OpenPeriodEvent(dto: openPeriodDto),
        );
      }
    
    
    }
  }

  /// Trata o resultado da verificação de overlap de um único dia (para add/update slot)
  Future<void> _handleOrganizedDayResult(
    OrganizedDayAfterVerificationResult result,
  ) async {
    if (_pendingSlotOperation == null || _pendingSlotDate == null) {
      return; // Sem operação pendente
    }

    final day = _pendingSlotDate!;
    final operation = _pendingSlotOperation!;

    // Se há slot reservado, não pode alterar
    if (result.hasBookedSlot) {
      context.showError('Não é possível alterar este dia pois há shows marcados');
      _clearPendingOperation();
      return;
    }

    // Se não há mudanças, apenas confirmar e aplicar
    if (!result.hasChanges && result.dayEntity != null) {
      // Montar mensagem com o intervalo e valor do slot
      String message;
      if (_pendingSlotStartTime != null && _pendingSlotEndTime != null) {
        final intervalText = '$_pendingSlotStartTime - $_pendingSlotEndTime';
        final priceText = _pendingSlotPricePerHour != null
            ? ' (R\$ ${_pendingSlotPricePerHour!.toStringAsFixed(0)}/hora)'
            : '';
        message = operation == 'add'
            ? 'Deseja adicionar o intervalo $intervalText$priceText?'
            : 'Deseja atualizar o intervalo para $intervalText$priceText?';
      } else {
        message = operation == 'add'
            ? 'Deseja adicionar este horário?'
            : 'Deseja atualizar este horário?';
      }

      final confirmed = await _showSimpleConfirmationDialog(
        title: operation == 'add' 
            ? 'Confirmar adição de horário' 
            : 'Confirmar atualização de horário',
        message: message,
      );

      if (confirmed == true) {
        _applySlotOperation(result.dayEntity!);
      }
      _clearPendingOperation();
      return;
    }

    // Se há mudanças (overlaps), mostrar dialog detalhado
    if (result.hasChanges && result.overlapInfo != null) {
      final overlapInfo = result.overlapInfo!;
      final daysWithOverlap = [overlapInfo];
      final daysWithBookedSlot = <AvailabilityDayEntity>[];
      final daysWithoutOverlap = <AvailabilityDayEntity>[];

      final confirmed = await AvailabilityConfirmationDialog.show(
        context: context,
        title: operation == 'add' 
            ? 'Confirmar adição de horário' 
            : 'Confirmar atualização de horário',
        isClose: false,
        checkOverlapsDto: null, // Não temos CheckOverlapsDto para slot único
        daysWithOverlap: daysWithOverlap,
        daysWithBookedSlot: daysWithBookedSlot,
        daysWithoutOverlap: daysWithoutOverlap,
        confirmText: 'Confirmar',
        cancelText: 'Cancelar',
      );

      if (confirmed == true) {
        // Criar entidade a partir do overlapInfo
        final availability = _getAvailabilityForDay(day);
        if (availability != null) {
          final updatedDay = availability.copyWith(
            slots: overlapInfo.newTimeSlots ?? [],
            endereco: overlapInfo.newAddress ?? availability.endereco,
            raioAtuacao: overlapInfo.newRadius ?? availability.raioAtuacao,
            updatedAt: DateTime.now(),
          );
          _applySlotOperation(updatedDay);
        }
      }
      _clearPendingOperation();
      return;
    }

    // Dia não encontrado - não deveria acontecer, mas tratar
    if (result.dayEntity == null) {
      context.showError('Dia não encontrado');
      _clearPendingOperation();
      return;
    }

    _clearPendingOperation();
  }

  /// Aplica a operação de slot (add ou update) após confirmação
  void _applySlotOperation(AvailabilityDayEntity dayEntity) {
    if (_pendingSlotOperation == null) return;

    if (_pendingSlotOperation == 'add') {
      context.read<AvailabilityBloc>().add(
        AddTimeSlotEvent(dayEntity: dayEntity),
      );
    } else if (_pendingSlotOperation == 'update') {
      context.read<AvailabilityBloc>().add(
        UpdateTimeSlotEvent(dayEntity: dayEntity),
      );
    }
  }

  /// Limpa a operação pendente
  void _clearPendingOperation() {
    _pendingSlotOperation = null;
    _pendingSlotDate = null;
    _pendingSlotId = null;
    _pendingSlotStartTime = null;
    _pendingSlotEndTime = null;
    _pendingSlotPricePerHour = null;
  }

  /// Mostra dialog simples de confirmação
  Future<bool?> _showSimpleConfirmationDialog({
    required String title,
    required String message,
  }) async {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimaryContainer)),
        content: Text(message, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary)),
        actions: [
          DialogButton.text(
            text: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(false),
            foregroundColor: colorScheme.onPrimary,
          ),
          DialogButton.primary(
            text: 'Confirmar',
            onPressed: () => Navigator.of(context).pop(true),
            backgroundColor: colorScheme.onPrimaryContainer,
            foregroundColor: colorScheme.primaryContainer,
          ),
        ],
      ),
    );
  }

  /// Cria OpenPeriodDto a partir do resultado da verificação
  OpenPeriodDto _createOpenPeriodDto({
    required CheckOverlapsDto originalDto,
    required List<DayOverlapInfo> daysWithOverlap,
    required List<AvailabilityDayEntity> daysWithBookedSlot,
    required List<AvailabilityDayEntity> daysWithoutOverlap,
  }) {
    // Criar baseAvailabilityDay a partir do CheckOverlapsDto
    final baseAvailabilityDay = AvailabilityDayEntity(
      date: originalDto.patternMetadata?.recurrence?.originalStartDate ?? DateTime.now(),
      slots: [], // Será preenchido pelo usecase baseado no patternMetadata
      raioAtuacao: originalDto.raioAtuacao ?? 0.0,
      endereco: originalDto.endereco ?? AddressInfoEntity(
        uid: '',
        street: '',
        city: '',
        state: '',
        zipCode: '',
        latitude: 0.0,
        longitude: 0.0,
      ),
      isManualOverride: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      patternMetadata: originalDto.patternMetadata != null
          ? [originalDto.patternMetadata!]
          : null,
    );

    return OpenPeriodDto(
      baseAvailabilityDay: baseAvailabilityDay,
      dayOverlapInfos: daysWithOverlap,
      daysWithBookedSlot: daysWithBookedSlot,
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
    final showColor = Colors.yellow;

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
            label: 'Indisponível',
            description: 'Disponibilidade desativada',
            color: error,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          SizedBox(height: DSSize.height(16)),

          _buildLegendItem(
            icon: Icons.star,
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
