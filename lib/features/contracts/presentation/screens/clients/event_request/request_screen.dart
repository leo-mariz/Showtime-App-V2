import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/domain/event/event_type_entity.dart';
import 'package:app/core/enums/contractor_type_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/core/shared/widgets/info_row.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:app/core/utils/availability_validator.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage(deferredLoading: true)
class RequestScreen extends StatefulWidget {
  final DateTime selectedDate;
  final AddressInfoEntity selectedAddress;
  final ArtistEntity artist;
  final double pricePerHour;
  final Duration minimumDuration;
  final AvailabilityEntity? availability; // Disponibilidade correspondente ao explorar

  const RequestScreen({
    super.key,
    required this.selectedDate,
    required this.selectedAddress,
    required this.artist,
    required this.pricePerHour,
    required this.minimumDuration,
    this.availability, // Opcional para manter compatibilidade
  });

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _eventTypeController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Duration? _selectedDuration;
  bool _hasAttemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedDuration = widget.minimumDuration;
    _durationController.text = _formatDuration(widget.minimumDuration);
  }

  @override
  void dispose() {
    _eventTypeController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Hoje';
    } else if (selectedDay == tomorrow) {
      return 'Amanhã';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  double get _totalValue {
    if (_selectedDuration == null) return 0.0;
    // Calcular valor por minuto: pricePerHour / 60
    final valorPorMinuto = widget.pricePerHour / 60;
    // Total = valorPorMinuto * duração em minutos
    final total = valorPorMinuto * _selectedDuration!.inMinutes;
    return total;
  }

  Future<void> _selectEventType() async {
    final router = AutoRouter.of(context);
    final result = await router.push<String>(
      EventTypeSelectionRoute(
        eventTypes: [
          'Aniversário',
          'Casamento',
          'Evento Corporativo',
          'Festa',
          'Show',
          'Outro',
        ],
        selectedEventType: _eventTypeController.text.isEmpty
            ? null
            : _eventTypeController.text,
        onEventTypeSelected: (value) {
          // Callback será chamado quando o tipo for selecionado
        },
      ),
    );

    if (result != null) {
      setState(() {
        _eventTypeController.text = result;
      });
    }
  }

  Future<void> _selectDate() async {
    // Se temos uma disponibilidade, usar suas restrições de data
    DateTime? firstDate;
    DateTime? lastDate;
    bool Function(DateTime)? selectableDayPredicate;
    
    if (widget.availability != null) {
      final availability = widget.availability!;
      firstDate = availability.dataInicio.isBefore(DateTime.now()) 
          ? DateTime.now() 
          : availability.dataInicio;
      lastDate = availability.dataFim;
      
      // Criar função para validar dias selecionáveis baseado na disponibilidade
      selectableDayPredicate = (DateTime date) {
        return AvailabilityValidator.isDateValidForAvailability(
          availability.dataInicio,
          availability.dataFim,
          availability.diasDaSemana,
          availability.repetir,
          availability.blockedSlots,
          availability.horarioInicio,
          availability.horarioFim,
          date,
        );
      };
    } else {
      firstDate = DateTime.now();
      lastDate = DateTime.now().add(const Duration(days: 365));
    }
    
    final picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: _selectedDate ?? widget.selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Resetar horário se a data mudou e temos disponibilidade (para recalcular horários válidos)
        if (widget.availability != null) {
          _selectedTime = null;
          _timeController.clear();
        }
      });
    }
  }

  Future<void> _selectTime() async {
    // Validar se há data selecionada quando temos disponibilidade
    if (widget.availability != null && _selectedDate == null) {
      context.showError('Selecione uma data primeiro');
      return;
    }
    
    final currentTime = _selectedTime ?? TimeOfDay.now();
    final hours = currentTime.hour;
    final minutes = currentTime.minute;

    // Calcular intervalos disponíveis se temos disponibilidade e data selecionada
    String? subtitle;
    if (widget.availability != null && _selectedDate != null) {
      final intervals = AvailabilityValidator.getAvailableTimeIntervals(
        widget.availability!.horarioInicio,
        widget.availability!.horarioFim,
        widget.availability!.blockedSlots,
        _selectedDate!,
      );
      if (intervals.isNotEmpty) {
        subtitle = 'Disponíveis para início:\n${intervals.join(', ')}';
      }
    }

    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Selecione o horário de início',
        subtitle: subtitle,
        initialHours: hours,
        initialMinutes: minutes,
        type: WheelPickerType.time,
      ),
    );

    if (result != null) {
      // Validar horário se temos disponibilidade
      if (widget.availability != null && _selectedDate != null) {
        final availability = widget.availability!;
        final selectedTimeMinutes = AvailabilityValidator.timeToMinutes(
          '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}'
        );
        final availabilityStartMinutes = AvailabilityValidator.timeToMinutes(availability.horarioInicio);
        final availabilityEndMinutes = AvailabilityValidator.timeToMinutes(availability.horarioFim);
        
        // Verificar se o horário está dentro do intervalo disponível
        // Permite selecionar até o último horário (<= availabilityEndMinutes)
        if (selectedTimeMinutes < availabilityStartMinutes || selectedTimeMinutes > availabilityEndMinutes) {
          final intervals = AvailabilityValidator.getAvailableTimeIntervals(
            availability.horarioInicio,
            availability.horarioFim,
            availability.blockedSlots,
            _selectedDate!,
          );
          context.showError(
            'Horário fora dos intervalos disponíveis: ${intervals.join(', ')}'
          );
          return;
        }
        
        // Verificar se há blockedSlots na data selecionada que conflitam
        final normalizedSelectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        
        final blockedSlotsForDate = availability.blockedSlots.where((blockedSlot) {
          final blockedDate = DateTime(
            blockedSlot.date.year,
            blockedSlot.date.month,
            blockedSlot.date.day,
          );
          return blockedDate == normalizedSelectedDate;
        }).toList();
        
        for (final blockedSlot in blockedSlotsForDate) {
          final blockedStartMinutes = AvailabilityValidator.timeToMinutes(blockedSlot.startTime);
          final blockedEndMinutes = AvailabilityValidator.timeToMinutes(blockedSlot.endTime);
          
          // Verificar se o horário selecionado está dentro de um bloqueio
          if (selectedTimeMinutes >= blockedStartMinutes && selectedTimeMinutes < blockedEndMinutes) {
            context.showError(
              'Horário bloqueado na data selecionada (${blockedSlot.startTime} - ${blockedSlot.endTime})'
            );
            return;
          }
        }
      }
      
      setState(() {
        _selectedTime = result;
        _timeController.text = '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectDuration() async {
    final hours = _selectedDuration?.inHours ?? 0;
    final minutes = (_selectedDuration?.inMinutes ?? 0) % 60;

    String subtitle = 'Duração mínima: ${widget.minimumDuration.inHours}h ${widget.minimumDuration.inMinutes % 60}min';

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Selecione a duração',
        subtitle: subtitle,
        initialHours: hours,
        initialMinutes: minutes,
        type: WheelPickerType.duration,
        minimumDuration: widget.minimumDuration,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDuration = result;
        _durationController.text = _formatDuration(result);
      });
    }
  }

  bool get _isFormValid {
    return _eventTypeController.text.isNotEmpty &&
        _selectedDate != null &&
        _timeController.text.isNotEmpty &&
        _durationController.text.isNotEmpty;
  }

  String? _validateForm() {
    if (_eventTypeController.text.isEmpty) {
      return 'Selecione o tipo de evento';
    }
    if (_selectedDate == null) {
      return 'Selecione a data';
    }
    if (_timeController.text.isEmpty) {
      return 'Selecione o horário';
    }
    if (_durationController.text.isEmpty) {
      return 'Selecione a duração';
    }
    return null;
  }

  Future<void> _onSubmit() async {
    setState(() {
      _hasAttemptedSubmit = true;
    });
    
    final error = _validateForm();
    if (error != null) {
      context.showError(error);
      return;
    }

    // Obter UID do cliente usando UsersBloc
    final usersBloc = context.read<UsersBloc>();
    final uidResult = await usersBloc.getUserUidUseCase.call();
    final clientUid = uidResult.fold(
      (failure) => null,
      (uid) => uid,
    );

    if (clientUid == null || clientUid.isEmpty) {
      context.showError('Erro ao obter UID do usuário');
      return;
    }

    // Usar o endereço completo passado como parâmetro
    final address = widget.selectedAddress;

    // Criar EventTypeEntity básico
    final eventType = EventTypeEntity(
      uid: '', // Será gerado no backend se necessário
      name: _eventTypeController.text,
      active: 'true',
    );

    // Criar ContractEntity
    final contract = ContractEntity(
      date: _selectedDate!,
      time: _timeController.text,
      duration: _selectedDuration!.inMinutes,
      address: address,
      contractorType: ContractorTypeEnum.artist,
      refClient: clientUid,
      refArtist: widget.artist.uid,
      nameArtist: widget.artist.artistName,
      nameClient: null, // Será preenchido no backend se necessário
      eventType: eventType,
      value: _totalValue,
      availabilitySnapshot: widget.availability,
    );

    // Adicionar evento ao Bloc
    context.read<ContractsBloc>().add(AddContractEvent(contract: contract));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return BlocProvider.value(
      value: context.read<ContractsBloc>(),
      child: BlocListener<ContractsBloc, ContractsState>(
        listener: (context, state) {
          if (state is AddContractSuccess) {
            context.showSuccess('Solicitação enviada com sucesso!');
            AutoRouter.of(context).pop();
          } else if (state is AddContractFailure) {
            context.showError(state.error);
          }
        },
        child: BasePage(
          showAppBar: true,
          appBarTitle: 'Nova Solicitação',
          showAppBarBackButton: true,
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DSSizedBoxSpacing.vertical(16),
            
            // Cabeçalho: Solicitando para
            Text(
              'Artista: ${widget.artist.artistName}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: onPrimary,
              ),
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Endereço (fixo)
            InfoRow(
              label: 'Endereço',
              value: widget.selectedAddress.title,
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Separador
            Divider(
              color: onSurfaceVariant.withOpacity(0.2),
              thickness: 1,
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Data
            SelectableRow(
              label: 'Data',
              value: _selectedDate != null ? _formatDate(_selectedDate!) : '',
              onTap: _selectDate,
              errorMessage: _hasAttemptedSubmit && _selectedDate == null ? 'Selecione a data' : null,
            ),
            
            DSSizedBoxSpacing.vertical(16),
            
            // Horário de início
            SelectableRow(
              label: 'Horário de início',
              value: _timeController.text,
              onTap: _selectTime,
              errorMessage: _hasAttemptedSubmit && _timeController.text.isEmpty ? 'Selecione o horário' : null,
            ),
            
            DSSizedBoxSpacing.vertical(16),
            
            // Duração
            SelectableRow(
              label: 'Duração',
              value: _durationController.text,
              onTap: _selectDuration,
              errorMessage: _hasAttemptedSubmit && _durationController.text.isEmpty ? 'Selecione a duração' : null,
            ),
            
            DSSizedBoxSpacing.vertical(16),
            
            // Tipo de evento
            SelectableRow(
              label: 'Tipo de evento',
              value: _eventTypeController.text,
              onTap: _selectEventType,
              errorMessage: _hasAttemptedSubmit && _eventTypeController.text.isEmpty ? 'Selecione o tipo de evento' : null,
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Separador
            Divider(
              color: onSurfaceVariant.withOpacity(0.2),
              thickness: 1,
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Valor/h (fixo)
            InfoRow(
              label: 'Valor/h',
              value: 'R\$ ${widget.pricePerHour.toStringAsFixed(2)}',
            ),
            
            DSSizedBoxSpacing.vertical(16),
            
            // Total (calculado)
            InfoRow(
              label: 'Total',
              value: 'R\$ ${_totalValue.toStringAsFixed(2)}',
              isHighlighted: true,
              highlightColor: colorScheme.onPrimaryContainer,
            ),
            
            DSSizedBoxSpacing.vertical(32),
            
            // Botão de envio
            BlocBuilder<ContractsBloc, ContractsState>(
              builder: (context, state) {
                final isLoading = state is AddContractLoading;
                final isEnabled = _isFormValid && !isLoading;
                
                return CustomButton(
                  label: isLoading ? 'Enviando...' : 'Solicitar Apresentação',
                  onPressed: isEnabled ? _onSubmit : null,
                  icon: Icons.send,
                  iconOnLeft: true,
                );
              },
            ),
            
            DSSizedBoxSpacing.vertical(24),
          ],
        ),
      ),
        ),
      ),
    );
  }
}





