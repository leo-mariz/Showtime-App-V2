import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
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
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';
import 'package:app/core/utils/availability_validator.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/features/app_lists/presentation/bloc/app_lists_bloc.dart';
import 'package:app/features/app_lists/presentation/bloc/events/app_lists_events.dart';
import 'package:app/features/app_lists/presentation/bloc/states/app_lists_states.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:app/features/profile/clients/presentation/bloc/clients_bloc.dart';
import 'package:app/features/profile/clients/presentation/bloc/events/clients_events.dart';
import 'package:app/features/profile/clients/presentation/bloc/states/clients_states.dart';
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
  // final AvailabilityEntity? availability; // Disponibilidade correspondente ao explorar

  const RequestScreen({
    super.key,
    required this.selectedDate,
    required this.selectedAddress,
    required this.artist,
    required this.pricePerHour,
    required this.minimumDuration,
    // this.availability, // Opcional para manter compatibilidade
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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedDuration = widget.minimumDuration;
    _durationController.text = _formatDuration(widget.minimumDuration);
    
    // Buscar tipos de evento do AppListsBloc após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadEventTypes();
      }
    });
  }
  
  void _loadEventTypes() {
    final appListsBloc = context.read<AppListsBloc>();
    appListsBloc.add(GetEventTypesEvent());
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
    // Calcular valor por minuto: pricePerHour / 60
    final valorPorMinuto = widget.pricePerHour / 60;
    // Total = valorPorMinuto * duração em minutos
    final total = valorPorMinuto * _selectedDuration!.inMinutes;
    return total;
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

  // Future<void> _selectDate() async {
  //   // Se temos uma disponibilidade, usar suas restrições de data
  //   DateTime? firstDate;
  //   DateTime? lastDate;
  //   bool Function(DateTime)? selectableDayPredicate;
    
  //   if (widget.availability != null) {
  //     final availability = widget.availability!;
  //     firstDate = availability.dataInicio.isBefore(DateTime.now()) 
  //         ? DateTime.now() 
  //         : availability.dataInicio;
  //     lastDate = availability.dataFim;
      
  //     // Criar função para validar dias selecionáveis baseado na disponibilidade
  //     selectableDayPredicate = (DateTime date) {
  //       return AvailabilityValidator.isDateValidForAvailability(
  //         availability.dataInicio,
  //         availability.dataFim,
  //         availability.diasDaSemana,
  //         availability.repetir,
  //         availability.blockedSlots,
  //         availability.horarioInicio,
  //         availability.horarioFim,
  //         date,
  //       );
  //     };
  //   } else {
  //     firstDate = DateTime.now();
  //     lastDate = DateTime.now().add(const Duration(days: 365));
  //   }
    
  //   final picked = await CustomDatePickerDialog.show(
  //     context: context,
  //     initialDate: _selectedDate ?? widget.selectedDate,
  //     firstDate: firstDate,
  //     lastDate: lastDate,
  //     selectableDayPredicate: selectableDayPredicate,
  //   );

  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //       // Resetar horário se a data mudou e temos disponibilidade (para recalcular horários válidos)
  //       if (widget.availability != null) {
  //         _selectedTime = null;
  //         _timeController.clear();
  //       }
  //     });
  //   }
  // }

  // Future<void> _selectTime() async {
  //   // Validar se há data selecionada quando temos disponibilidade
  //   if (widget.availability != null && _selectedDate == null) {
  //     context.showError('Selecione uma data primeiro');
  //     return;
  //   }
    
  //   final currentTime = _selectedTime ?? TimeOfDay.now();
  //   final hours = currentTime.hour;
  //   final minutes = currentTime.minute;

  //   // Calcular intervalos disponíveis se temos disponibilidade e data selecionada
  //   String? subtitle;
  //   if (widget.availability != null && _selectedDate != null) {
  //     final intervals = AvailabilityValidator.getAvailableTimeIntervals(
  //       widget.availability!.horarioInicio,
  //       widget.availability!.horarioFim,
  //       widget.availability!.blockedSlots,
  //       _selectedDate!,
  //     );
  //     if (intervals.isNotEmpty) {
  //       subtitle = 'Disponíveis para início:\n${intervals.join(', ')}';
  //     }
  //   }

  //   final result = await showDialog<TimeOfDay>(
  //     context: context,
  //     builder: (context) => WheelPickerDialog(
  //       title: 'Selecione o horário de início',
  //       subtitle: subtitle,
  //       initialHours: hours,
  //       initialMinutes: minutes,
  //       type: WheelPickerType.time,
  //     ),
  //   );

  //   if (result != null) {
  //     // Validar horário se temos disponibilidade
  //     if (widget.availability != null && _selectedDate != null) {
  //       final availability = widget.availability!;
  //       final selectedTimeMinutes = AvailabilityValidator.timeToMinutes(
  //         '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}'
  //       );
  //       final availabilityStartMinutes = AvailabilityValidator.timeToMinutes(availability.horarioInicio);
  //       final availabilityEndMinutes = AvailabilityValidator.timeToMinutes(availability.horarioFim, isEndTime: true);
        
  //       // Verificar se o horário está dentro do intervalo disponível
  //       // Quando horarioFim é 00:00, foi tratado como 1440 minutos (24:00)
  //       // Permite selecionar até o último horário (<= availabilityEndMinutes)
  //       if (selectedTimeMinutes < availabilityStartMinutes || selectedTimeMinutes > availabilityEndMinutes) {
  //         final intervals = AvailabilityValidator.getAvailableTimeIntervals(
  //           availability.horarioInicio,
  //           availability.horarioFim,
  //           availability.blockedSlots,
  //           _selectedDate!,
  //         );
  //         context.showError(
  //           'Horário fora dos intervalos disponíveis: ${intervals.join(', ')}'
  //         );
  //         return;
  //       }
        
  //       // Verificar se há blockedSlots na data selecionada que conflitam
  //       final normalizedSelectedDate = DateTime(
  //         _selectedDate!.year,
  //         _selectedDate!.month,
  //         _selectedDate!.day,
  //       );
        
  //       final blockedSlotsForDate = availability.blockedSlots.where((blockedSlot) {
  //         final blockedDate = DateTime(
  //           blockedSlot.date.year,
  //           blockedSlot.date.month,
  //           blockedSlot.date.day,
  //         );
  //         return blockedDate == normalizedSelectedDate;
  //       }).toList();
        
  //       for (final blockedSlot in blockedSlotsForDate) {
  //         final blockedStartMinutes = AvailabilityValidator.timeToMinutes(blockedSlot.startTime);
  //         final blockedEndMinutes = AvailabilityValidator.timeToMinutes(blockedSlot.endTime);
          
  //         // Verificar se o horário selecionado está dentro de um bloqueio
  //         if (selectedTimeMinutes >= blockedStartMinutes && selectedTimeMinutes < blockedEndMinutes) {
  //           context.showError(
  //             'Horário bloqueado na data selecionada (${blockedSlot.startTime} - ${blockedSlot.endTime})'
  //           );
  //           return;
  //         }
  //       }
  //     }
      
  //     setState(() {
  //       _selectedTime = result;
  //       _timeController.text = '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
  //     });
  //   }
  // }

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

    final nameClient = _getClientName();
    if (nameClient.isEmpty) {
      context.showError('Erro ao obter nome do cliente. Por favor, tente novamente.');
      return;
    }

    final clientRating =_getClientRating();

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
      nameClient: nameClient,
      clientRating: clientRating,
      eventType: eventType,
      value: _totalValue,
      // availabilitySnapshot: widget.availability,
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

    return MultiBlocListener(
      listeners: [
        // Listener para ContractsBloc
        BlocListener<ContractsBloc, ContractsState>(
          listener: (context, state) {
            if (state is AddContractSuccess) {
              context.showSuccess('Solicitação enviada com sucesso!');
              AutoRouter.of(context).pop();
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
            
            // Cabeçalho: Solicitando para
            Text(
              'Artista: ${widget.artist.artistName}',
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
              // onTap: _selectDate,
              onTap: () {},
              errorMessage: _hasAttemptedSubmit && _selectedDate == null ? 'Selecione a data' : null,
            ),
            
            DSSizedBoxSpacing.vertical(16),
            
            // Horário de início
            SelectableRow(
              label: 'Horário de início',
              value: _timeController.text,
              // onTap: _selectTime,
              onTap: () {},
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





