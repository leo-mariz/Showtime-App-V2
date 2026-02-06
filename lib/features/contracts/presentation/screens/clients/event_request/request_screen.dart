import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/features/explore/domain/entities/ensembles/ensemble_with_availabilities_entity.dart';
import 'package:app/core/domain/availability/time_slot_entity.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/domain/event/event_type_entity.dart';
import 'package:app/core/enums/contractor_type_enum.dart';
import 'package:app/core/enums/time_slot_status_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/core/shared/widgets/info_row.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/features/app_lists/presentation/bloc/app_lists_bloc.dart';
import 'package:app/features/app_lists/presentation/bloc/events/app_lists_events.dart';
import 'package:app/features/app_lists/presentation/bloc/states/app_lists_states.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/request_availabilities/request_availabilities_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/request_availabilities/events/request_availabilities_events.dart';
import 'package:app/features/contracts/presentation/bloc/request_availabilities/states/request_availabilities_states.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:app/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:app/features/clients/presentation/bloc/events/clients_events.dart';
import 'package:app/features/clients/presentation/bloc/states/clients_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage(deferredLoading: true)
class RequestScreen extends StatefulWidget {
  final DateTime selectedDate;
  final AddressInfoEntity selectedAddress;
  final ArtistEntity artist;
  /// Quando preenchido, a solicitação é para o conjunto (contrato tipo grupo).
  final EnsembleWithAvailabilitiesEntity? ensemble;

  const RequestScreen({
    super.key,
    required this.selectedDate,
    required this.selectedAddress,
    required this.artist,
    this.ensemble,
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
  
  // Lista de tipos de evento obtidos do AppListsBloc
  List<String> _eventTypes = [];
  bool _isLoadingEventTypes = false;

  // Disponibilidades do artista/conjunto (obtidas via RequestAvailabilitiesBloc)
  List<AvailabilityDayEntity>? _availabilities;
  bool _isLoadingAvailabilities = false;

  // Slot selecionado (para pegar o valor/h correto)
  // ignore: unused_field
  TimeSlot? _selectedSlot;
  double? _selectedPricePerHour;

  // Getters
  Duration get _minimumDuration => widget.artist.professionalInfo?.minimumShowDuration != null
      ? Duration(minutes: widget.artist.professionalInfo!.minimumShowDuration!)
      : const Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedDuration = _minimumDuration;
    _durationController.text = _formatDuration(_minimumDuration);
    
    // Buscar dados após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadEventTypes();
        _loadAvailabilities();
      }
    });
  }
  
  void _loadEventTypes() {
    final appListsBloc = context.read<AppListsBloc>();
    appListsBloc.add(GetEventTypesEvent());
  }

  void _loadAvailabilities() {
    final bloc = context.read<RequestAvailabilitiesBloc>();
    if (widget.ensemble != null) {
      bloc.add(
        LoadEnsembleAvailabilitiesEvent(
          ensembleId: widget.ensemble!.ensemble.id!,
          userAddress: widget.selectedAddress,
        ),
      );
    } else {
      bloc.add(
        LoadArtistAvailabilitiesEvent(
          artistId: widget.artist.uid!,
          userAddress: widget.selectedAddress,
        ),
      );
    }
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

  String _getClientName() {
    final userBloc = context.read<UsersBloc>();
    final currentUserState = userBloc.state;
    if (currentUserState is! GetUserDataSuccess) {
      userBloc.add(GetUserDataEvent());
    }
    if (currentUserState is GetUserDataSuccess) {
      final user = currentUserState.user;
      if (user.isCnpj == true) {
        return user.cnpjUser?.companyName ?? '';
      } else {
        return '${user.cpfUser?.firstName ?? ''} ${user.cpfUser?.lastName ?? ''}';
      }
    }   
    return '';
  }

  double _getClientRating() {
    final currentClientState = context.read<ClientsBloc>().state;
    if (currentClientState is! GetClientSuccess) {
      context.read<ClientsBloc>().add(GetClientEvent());
    }
    if (currentClientState is GetClientSuccess) {
      final client = currentClientState.client;
      return client.rating ?? 0;
    }
    return 0;
  }

  String _formatAddress(AddressInfoEntity address) {
    final parts = <String>[];
    
    // Rua e número
    if (address.street != null && address.street!.isNotEmpty) {
      final streetPart = address.street!;
      final numberPart = address.number != null ? ', ${address.number}' : '';
      parts.add('$streetPart$numberPart');
    }
    
    // Bairro
    if (address.district != null && address.district!.isNotEmpty && address.city != null && address.state != null) {
      parts.add('${address.district!}, ${address.city} - ${address.state}');
    }
    
    // CEP
    if (address.zipCode.isNotEmpty) {
      parts.add('CEP: ${address.zipCode}');
    }
    
    return parts.join('\n');
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
    // Usar o valor do slot selecionado, se disponível
    final pricePerHour = _selectedPricePerHour ?? 0;
    // Calcular valor por minuto: pricePerHour / 60
    final valorPorMinuto = pricePerHour / 60;
    // Total = valorPorMinuto * duração em minutos
    final total = valorPorMinuto * _selectedDuration!.inMinutes;
    return total;
  }

  /// Retorna a disponibilidade para uma data específica
  AvailabilityDayEntity? _getAvailabilityForDate(DateTime date) {
    if (_availabilities == null) return null;
    
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    try {
      return _availabilities!.firstWhere(
        (availability) {
          final availabilityDateKey = '${availability.date.year}-${availability.date.month.toString().padLeft(2, '0')}-${availability.date.day.toString().padLeft(2, '0')}';
          return availabilityDateKey == dateKey;
        },
      );
    } catch (_) {
      return null;
    }
  }

  /// Converte horário "HH:mm" para minutos desde meia-noite
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Retorna os slots disponíveis para uma data
  List<TimeSlot> _getAvailableSlotsForDate(DateTime date) {
    final availability = _getAvailabilityForDate(date);
    if (availability == null) return [];
    
    return availability.slots
        ?.where((slot) => slot.status == TimeSlotStatusEnum.available)
        .toList() ?? [];
  }

  /// Encontra o slot que contém o horário especificado
  TimeSlot? _findSlotContainingTime(DateTime date, String time) {
    final slots = _getAvailableSlotsForDate(date);
    if (slots.isEmpty) return null;
    
    final timeInMinutes = _timeToMinutes(time);
    
    for (final slot in slots) {
      final slotStart = _timeToMinutes(slot.startTime);
      final slotEnd = _timeToMinutes(slot.endTime);
      
      // Verificar se o horário está dentro deste slot
      if (timeInMinutes >= slotStart && timeInMinutes < slotEnd) {
        return slot;
      }
    }
    
    return null;
  }

  Future<void> _selectEventType() async {
    // Se ainda está carregando, mostrar mensagem
    if (_isLoadingEventTypes) {
      context.showError('Carregando tipos de evento...');
      return;
    }
    
    // Se não há tipos de evento disponíveis, mostrar erro
    if (_eventTypes.isEmpty) {
      context.showError('Nenhum tipo de evento disponível');
      return;
    }
    
    final router = AutoRouter.of(context);
    final result = await router.push<String>(
      EventTypeSelectionRoute(
        eventTypes: _eventTypes,
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
    // Verificar se as disponibilidades já foram carregadas
    if (_isLoadingAvailabilities) {
      context.showError('Carregando disponibilidades...');
      return;
    }

    if (_availabilities == null || _availabilities!.isEmpty) {
      context.showError('Nenhuma disponibilidade encontrada');
      return;
    }

    // Se temos disponibilidades, usar suas restrições de data
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 365));
    bool Function(DateTime)? selectableDayPredicate;
    
    // Criar função para validar dias selecionáveis baseado nas disponibilidades
    selectableDayPredicate = (DateTime date) {
      return _getAvailabilityForDate(date) != null;
    };
    
    // Definir firstDate como a primeira data disponível ou hoje
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day); // Normalizar para meia-noite
    
    final sortedDates = _availabilities!
        .map((a) => a.date)
        .where((date) {
          // Normalizar a data para meia-noite antes de comparar
          final dateOnly = DateTime(date.year, date.month, date.day);
          return !dateOnly.isBefore(todayDate);
        })
        .toList()
      ..sort();
    
    if (sortedDates.isNotEmpty) {
      firstDate = sortedDates.first;
      lastDate = sortedDates.last;
    }
    
    // Ajustar initialDate para estar dentro do range válido
    DateTime initialDate = _selectedDate ?? widget.selectedDate;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    } else if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }
    
    final picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Resetar horário e valores quando a data muda
        _selectedTime = null;
        _timeController.clear();
        _selectedSlot = null;
        _selectedPricePerHour = null;
      });
    }
  }

  Future<void> _selectTime() async {
    // Validar se há data selecionada
    if (_selectedDate == null) {
      context.showError('Selecione uma data primeiro');
      return;
    }
    
    // Buscar slots disponíveis para a data selecionada
    final availableSlots = _getAvailableSlotsForDate(_selectedDate!);
    
    if (availableSlots.isEmpty) {
      context.showError('Nenhum horário disponível para esta data');
      return;
    }
    
    // Verificar se a data selecionada é hoje e calcular horário mínimo
    final now = DateTime.now();
    final selectedDateOnly = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    final todayOnly = DateTime(now.year, now.month, now.day);
    final isToday = selectedDateOnly.isAtSameMomentAs(todayOnly);
    
    int? minimumTimeInMinutes;
    if (isToday) {
      // Adicionar 1 hora de margem ao horário atual
      final minimumTime = now.add(const Duration(hours: 1));
      minimumTimeInMinutes = (minimumTime.hour * 60) + minimumTime.minute;
      // Arredondar para o próximo intervalo de 30 minutos
      if (minimumTimeInMinutes % 30 != 0) {
        minimumTimeInMinutes = ((minimumTimeInMinutes ~/ 30) + 1) * 30;
      }
    }
    
    final currentTime = _selectedTime ?? TimeOfDay.now();
    final hours = currentTime.hour;
    final minutes = currentTime.minute;

    // Criar subtitle com os intervalos e valores, filtrando horários passados se for hoje
    String subtitle = 'Horários disponíveis:\n';
    bool hasAvailableSlots = false;
    
    for (final slot in availableSlots) {
      String displayStartTime = slot.startTime;
      String displayEndTime = slot.endTime;
      
      // Se for hoje, ajustar o horário de início mostrado
      if (isToday && minimumTimeInMinutes != null) {
        final slotStartMinutes = _timeToMinutes(slot.startTime);
        final slotEndMinutes = _timeToMinutes(slot.endTime);
        
        // Se o slot termina antes do horário mínimo, pular completamente
        if (slotEndMinutes <= minimumTimeInMinutes) {
          continue;
        }
        
        // Se o slot começa antes do horário mínimo, ajustar o horário de início mostrado
        if (slotStartMinutes < minimumTimeInMinutes) {
          final adjustedHours = minimumTimeInMinutes ~/ 60;
          final adjustedMinutes = minimumTimeInMinutes % 60;
          displayStartTime = '${adjustedHours.toString().padLeft(2, '0')}:${adjustedMinutes.toString().padLeft(2, '0')}';
        }
      }
      
      hasAvailableSlots = true;
      final priceFormatted = slot.valorHora != null 
          ? 'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(slot.valorHora!)}/h'
          : 'Sem preço';
      subtitle += '$displayStartTime - $displayEndTime ($priceFormatted)\n';
    }
    
    if (!hasAvailableSlots) {
      context.showError('Nenhum horário disponível para hoje. Todos os horários já passaram.');
      return;
    }

    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Selecione o horário de início',
        subtitle: subtitle.trim(),
        initialHours: hours,
        initialMinutes: minutes,
        type: WheelPickerType.time,
        minimumTimeInMinutes: minimumTimeInMinutes, // Passar o horário mínimo para o picker
      ),
    );

    if (result != null) {
      final selectedTimeString = '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
      
      // Se for hoje, validar se o horário selecionado é após o mínimo
      if (isToday && minimumTimeInMinutes != null) {
        final selectedTimeInMinutes = (result.hour * 60) + result.minute;
        if (selectedTimeInMinutes < minimumTimeInMinutes) {
          context.showError(
            'Horário já passou. Por favor, selecione um horário com pelo menos 1 hora de antecedência.'
          );
          return;
        }
      }
      
      // Validar se o horário está dentro de algum slot disponível
      final slot = _findSlotContainingTime(_selectedDate!, selectedTimeString);
      
      if (slot == null) {
        context.showError(
          'Horário fora dos intervalos disponíveis. Por favor, selecione um horário dentro dos slots disponíveis.'
        );
        return;
      }
      
      setState(() {
        _selectedTime = result;
        _timeController.text = selectedTimeString;
        _selectedSlot = slot;
        _selectedPricePerHour = slot.valorHora;
      });
    }
  }

  Future<void> _selectDuration() async {
    final hours = _selectedDuration?.inHours ?? 0;
    final minutes = (_selectedDuration?.inMinutes ?? 0) % 60;

    String subtitle = 'Duração mínima: ${_minimumDuration.inHours}h ${_minimumDuration.inMinutes % 60}min';

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Selecione a duração',
        subtitle: subtitle,
        initialHours: hours,
        initialMinutes: minutes,
        type: WheelPickerType.duration,
        minimumDuration: _minimumDuration,
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

  Future<String?> _getClientUid() async {
    final usersBloc = context.read<UsersBloc>();
    final currentUserState = usersBloc.state;
    print('currentUserState: $currentUserState');
    if (currentUserState is! GetUserDataSuccess) {
      usersBloc.add(GetUserDataEvent());
    }
    if (currentUserState is GetUserDataSuccess) {
      print('currentUserState.user.uid: ${currentUserState.user.uid}');
      return currentUserState.user.uid;
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
    final clientUid = await _getClientUid();

    if (clientUid == null || clientUid.isEmpty) {
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

    final nameClient = _getClientName();
    if (nameClient.isEmpty) {
      context.showError('Erro ao obter nome do cliente. Por favor, tente novamente.');
      return;
    }

    final clientRating =_getClientRating();

    final isGroup = widget.ensemble != null;
    final ensemble = widget.ensemble;
    final membersCount = ensemble?.ensemble.members?.length ?? 0 - 1;
    final nameGroup = ensemble != null
        ? '${ensemble.ownerArtist?.artistName ?? 'Conjunto'} + $membersCount'
        : null;

    // Criar ContractEntity (artista individual ou conjunto)
    final contract = ContractEntity(
      date: _selectedDate!,
      time: _timeController.text,
      duration: _selectedDuration!.inMinutes,
      preparationTime: widget.artist.professionalInfo?.preparationTime,
      address: address,
      contractorType: isGroup ? ContractorTypeEnum.group : ContractorTypeEnum.artist,
      refClient: clientUid,
      refArtist: isGroup ? null : widget.artist.uid,
      refGroup: isGroup ? (ensemble!.ensemble.id) : null,
      refArtistOwner: isGroup ? widget.artist.uid : null,
      nameArtist: isGroup ? null : widget.artist.artistName,
      nameGroup: nameGroup,
      nameClient: nameClient,
      clientRating: clientRating,
      eventType: eventType,
      value: _totalValue,
      availabilitySnapshot: _getAvailabilityForDate(_selectedDate!),
    );

    // Adicionar evento ao Bloc
    // ignore: use_build_context_synchronously
    context.read<ContractsBloc>().add(AddContractEvent(contract: contract));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final router = AutoRouter.of(context);

    return MultiBlocListener(
      listeners: [
        // Listener para ContractsBloc
        BlocListener<ContractsBloc, ContractsState>(
          listener: (context, state) {
            if (state is AddContractSuccess) {
              context.showSuccess('Solicitação enviada com sucesso!');
              router.maybePop();
            } else if (state is AddContractFailure) {
              context.showError(state.error);
            }
          },
        ),
        
        // Listener para AppListsBloc - tipos de evento
        BlocListener<AppListsBloc, AppListsState>(
          listener: (context, state) {
            if (state is GetEventTypesLoading) {
              setState(() {
                _isLoadingEventTypes = true;
              });
            } else if (state is GetEventTypesSuccess) {
              setState(() {
                _isLoadingEventTypes = false;
                // Converter AppListItemEntity para List<String> (apenas nomes ativos)
                _eventTypes = state.eventTypes
                    .where((item) => item.isActive)
                    .map((item) => item.name)
                    .toList();
              });
            } else if (state is GetEventTypesFailure) {
              setState(() {
                _isLoadingEventTypes = false;
              });
              context.showError('Erro ao carregar tipos de evento: ${state.error}');
            }
          },
        ),
        // Listener para RequestAvailabilitiesBloc - disponibilidades (artista ou conjunto)
        BlocListener<RequestAvailabilitiesBloc, RequestAvailabilitiesState>(
          listener: (context, state) {
            if (state is RequestAvailabilitiesLoading) {
              setState(() => _isLoadingAvailabilities = true);
            } else if (state is RequestAvailabilitiesSuccess) {
              setState(() {
                _isLoadingAvailabilities = false;
                _availabilities = state.availabilities;
              });
            } else if (state is RequestAvailabilitiesFailure) {
              setState(() => _isLoadingAvailabilities = false);
              context.showError('Erro ao carregar disponibilidades: ${state.error}');
            }
          },
        ),
      ],
      child: BasePage(
          showAppBar: true,
          appBarTitle: 'Nova Solicitação',
          showAppBarBackButton: true,
          child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSSizedBoxSpacing.vertical(16),
              
              // Cabeçalho: Solicitando para (artista ou conjunto)
              Text(
                widget.ensemble != null
                    ? 'Conjunto: ${widget.ensemble!.ownerArtist?.artistName ?? 'Conjunto'} + ${widget.ensemble!.ensemble.members?.length ?? 0}'
                    : 'Artista: ${widget.artist.artistName}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: onPrimary,
                ),
              ),
              
              DSSizedBoxSpacing.vertical(24),
              
              // Endereço completo (fixo) - usando Column para melhor visualização multilinha
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Endereço',
                      style: textTheme.bodyMedium?.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      _formatAddress(widget.selectedAddress),
                      style: textTheme.bodyMedium?.copyWith(
                        color: onPrimary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
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
              // Aviso de prazo para resposta (regra: hoje/amanhã = 1h30, depois = 24h)
              
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
              
              // Valor/h (atualizado com o slot selecionado)
              InfoRow(
                label: 'Valor/h',
                value: _selectedPricePerHour != null
                    ? 'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(_selectedPricePerHour!)}'
                    : '--',
              ),
              
              DSSizedBoxSpacing.vertical(16),
              
              // Total (calculado)
              InfoRow(
                label: 'Total',
                value: 'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(_totalValue)}',
                isHighlighted: true,
                highlightColor: colorScheme.onPrimaryContainer,
              ),
              
              DSSizedBoxSpacing.vertical(16),

              if (_selectedDate != null) ...[
                DSSizedBoxSpacing.vertical(8),
                Builder(
                  builder: (context) {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final selectedOnly = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                    final tomorrow = today.add(const Duration(days: 1));
                    final isTodayOrTomorrow = selectedOnly == today || selectedOnly == tomorrow;
                    final message = isTodayOrTomorrow
                        ? 'A solicitação será respondida em até 1h30.'
                        : 'A solicitação será respondida em até 24 horas.';
                    final colorScheme = Theme.of(context).colorScheme;
                    final textTheme = Theme.of(context).textTheme;
                    return Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          DSSizedBoxSpacing.horizontal(8),
                          Expanded(
                            child: Text(
                              message,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              DSSizedBoxSpacing.vertical(24),
              
              // Botão de envio
              BlocBuilder<ContractsBloc, ContractsState>(
                builder: (context, state) {
                  final isLoading = state is AddContractLoading;
                  final isEnabled = _isFormValid && !isLoading;
                  
                  return CustomButton(
                    label: isLoading ? 'Enviando...' : 'Solicitar Apresentação',
                    onPressed: isEnabled ? _onSubmit : null,
                    icon: Icons.send,
                    iconOnRight: true,
                    isLoading: isLoading,
                  );
                },
              ),
              
              DSSizedBoxSpacing.vertical(24),
            ],
          ),
        ),
      ),
    );
  }
}





