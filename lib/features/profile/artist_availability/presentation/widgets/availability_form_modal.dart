import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/blocked_time_slot.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/core/shared/widgets/dialog_button.dart';
import 'package:app/core/shared/widgets/informative_banner.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:app/features/addresses/presentation/widgets/addresses_modal.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/blocked_slots_modal.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/radius_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Modal para criar/editar disponibilidade
class AvailabilityFormModal extends StatefulWidget {
  final AvailabilityEntity? availability;
  final DateTime? initialDate;
  final Function(AvailabilityEntity) onSave;

  const AvailabilityFormModal({
    super.key,
    this.availability,
    this.initialDate,
    required this.onSave,
  });

  /// Exibe o modal de disponibilidade
  static Future<void> show({
    required BuildContext context,
    AvailabilityEntity? availability,
    DateTime? initialDate,
    required Function(AvailabilityEntity) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvailabilityFormModal(
        availability: availability,
        initialDate: initialDate,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AvailabilityFormModal> createState() => _AvailabilityFormModalState();
}

class _AvailabilityFormModalState extends State<AvailabilityFormModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _recurrenceDaysController = TextEditingController();

  // Estados
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isRecurring = false;
  List<String> _selectedDays = [];
  AddressInfoEntity? _selectedAddress;
  double _radiusKm = 0.1; // Inicia com 100 metros
  List<BlockedTimeSlot> _blockedSlots = []; // Lista de bloqueios

  // Valores iniciais para comparação (apenas quando for update)
  AvailabilityEntity? _initialAvailability;

  @override
  void initState() {
    super.initState();
    if (widget.availability != null) {
      _initialAvailability = widget.availability;
      _loadAvailability(widget.availability!);
    } else {
      _startDate = widget.initialDate ?? DateTime.now();
      _endDate = _startDate;
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 18, minute: 0);
      _updateControllers();
    }
  }

  void _loadAvailability(AvailabilityEntity availability) {
    _startDate = availability.dataInicio;
    _endDate = availability.dataFim;
    _startTime = TimeOfDay(
      hour: int.parse(availability.horarioInicio.split(':')[0]),
      minute: int.parse(availability.horarioInicio.split(':')[1]),
    );
    _endTime = TimeOfDay(
      hour: int.parse(availability.horarioFim.split(':')[0]),
      minute: int.parse(availability.horarioFim.split(':')[1]),
    );
    _isRecurring = availability.repetir;
    _selectedDays = List.from(availability.diasDaSemana);
    _blockedSlots = List.from(availability.blockedSlots);
    _selectedAddress = availability.endereco;
    _radiusKm = availability.raioAtuacao;
    _valueController.text = availability.valorShow.toStringAsFixed(2);
    _radiusController.text = _radiusKm.toStringAsFixed(1);
    // Garante que o raio mínimo seja 0.1 km (100 metros)
    if (_radiusKm < 0.1) {
      _radiusKm = 0.1;
      _radiusController.text = _radiusKm.toStringAsFixed(1);
    }
    _updateControllers();
  }

  void _updateControllers() {
    if (_startDate != null) {
      _startDateController.text = DateFormat('dd/MM/yyyy').format(_startDate!);
    }
    if (_endDate != null) {
      _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate!);
    }
    if (_startTime != null) {
      _startTimeController.text = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
    }
    if (_endTime != null) {
      _endTimeController.text = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
    }
    _recurrenceDaysController.text = _selectedDays.isEmpty
        ? ''
        : _selectedDays.map((day) {
            final index = AvailabilityEntityOptions.daysOfWeekList().indexOf(day);
            return index != -1
                ? AvailabilityEntityOptions.daysOfWeek()[index]
                : day;
          }).join(', ');
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _valueController.dispose();
    _radiusController.dispose();
    _recurrenceDaysController.dispose();
    super.dispose();
  }

  /// Verifica se houve alterações nos campos (apenas para update)
  bool _hasChanges() {
    if (_initialAvailability == null) return true; // Se não há disponibilidade inicial, sempre permite salvar

    // Compara datas (apenas dia, mês e ano)
    if (_startDate == null || _endDate == null) return true;
    
    final startDateOnly = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final endDateOnly = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
    final initialStartDateOnly = DateTime(_initialAvailability!.dataInicio.year, _initialAvailability!.dataInicio.month, _initialAvailability!.dataInicio.day);
    final initialEndDateOnly = DateTime(_initialAvailability!.dataFim.year, _initialAvailability!.dataFim.month, _initialAvailability!.dataFim.day);
    
    if (!startDateOnly.isAtSameMomentAs(initialStartDateOnly) ||
        !endDateOnly.isAtSameMomentAs(initialEndDateOnly)) {
      return true;
    }

    // Compara horários
    final currentStartTime = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
    final currentEndTime = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
    if (_startTime == null || 
        _endTime == null ||
        currentStartTime != _initialAvailability!.horarioInicio ||
        currentEndTime != _initialAvailability!.horarioFim) {
      return true;
    }

    // Compara recorrência
    if (_isRecurring != _initialAvailability!.repetir) {
      return true;
    }

    // Compara dias da semana
    if (_selectedDays.length != _initialAvailability!.diasDaSemana.length ||
        !_selectedDays.every((day) => _initialAvailability!.diasDaSemana.contains(day))) {
      return true;
    }

    // Compara valor
    final currentValue = double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0;
    if (currentValue != _initialAvailability!.valorShow) {
      return true;
    }

    // Compara raio
    if (_radiusKm != _initialAvailability!.raioAtuacao) {
      return true;
    }

    // Compara endereço (compara por uid ou título)
    if (_selectedAddress == null ||
        _selectedAddress!.uid != _initialAvailability!.endereco.uid ||
        _selectedAddress!.title != _initialAvailability!.endereco.title) {
      return true;
    }

    // Compara blockedSlots
    if (_blockedSlots.length != _initialAvailability!.blockedSlots.length) {
      return true;
    }
    
    // Compara cada blockedSlot
    for (var i = 0; i < _blockedSlots.length; i++) {
      final current = _blockedSlots[i];
      if (i >= _initialAvailability!.blockedSlots.length) {
        return true;
      }
      final initial = _initialAvailability!.blockedSlots[i];
      if (current.date != initial.date ||
          current.startTime != initial.startTime ||
          current.endTime != initial.endTime ||
          current.note != initial.note) {
        return true;
      }
    }

    return false; // Nenhuma alteração detectada
  }

  Future<void> _selectStartDate() async {
    final picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate == null || _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
        _updateControllers();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _updateControllers();
      });
    }
  }

  Future<void> _selectStartTime() async {
    final currentTime = _startTime ?? const TimeOfDay(hour: 9, minute: 0);
    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Horário de início',
        initialHours: currentTime.hour,
        initialMinutes: currentTime.minute,
        type: WheelPickerType.time,
      ),
    );

    if (result != null) {
      setState(() {
        _startTime = result;
        _updateControllers();
      });
    }
  }

  Future<void> _selectEndTime() async {
    final currentTime = _endTime ?? const TimeOfDay(hour: 18, minute: 0);
    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Horário de fim',
        initialHours: currentTime.hour,
        initialMinutes: currentTime.minute,
        type: WheelPickerType.time,
      ),
    );

    if (result != null) {
      setState(() {
        _endTime = result;
        _updateControllers();
      });
    }
  }

  Future<void> _selectAddress() async {
    final selected = await AddressesModal.show(
      context: context,
      selectedAddress: _selectedAddress,
    );

    if (selected != null) {
      setState(() {
        _selectedAddress = selected;
      });
    }
  }

  Future<void> _selectRecurrenceDays() async {
    final dayOptions = AvailabilityEntityOptions.daysOfWeek();
    final currentSelected = _selectedDays.map((day) {
      final index = AvailabilityEntityOptions.daysOfWeekList().indexOf(day);
      return index != -1 ? dayOptions[index] : day;
    }).toList();

    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _RecurrenceDaysDialog(
        initialSelected: currentSelected,
        options: dayOptions,
      ),
    );

    if (result != null) {
      setState(() {
        // Converte de português para código (SU, MO, etc)
        final dayMap = AvailabilityEntityOptions.daysOfWeekMap();
        _selectedDays = result.map((ptDay) => dayMap[ptDay] ?? ptDay).toList();
        _updateControllers();
      });
    }
  }

  Future<void> _showBlockedSlotsModal() async {
    // Validações básicas
    if (_startDate == null || _endDate == null) {
      context.showError('Defina o período da disponibilidade primeiro');
      return;
    }

    if (_startTime == null || _endTime == null) {
      context.showError('Defina os horários da disponibilidade primeiro');
      return;
    }

    final result = await BlockedSlotsModal.show(
      context: context,
      initialBlockedSlots: List.from(_blockedSlots),
      startDate: _startDate!,
      endDate: _endDate!,
      isRecurring: _isRecurring,
      selectedDays: _selectedDays,
      startTime: '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
      endTime: '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
      onBlockedSlotsChanged: (updatedSlots) {
        // Atualizar em tempo real quando os bloqueios mudam
        setState(() {
          _blockedSlots = List<BlockedTimeSlot>.from(updatedSlots);
        });
      },
    );

    // Atualizar com o resultado final (caso o callback não tenha sido chamado)
    if (result != null) {
      setState(() {
        _blockedSlots = List<BlockedTimeSlot>.from(result);
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      context.showError('Selecione as datas');
      return;
    }

    if (_startTime == null || _endTime == null) {
      context.showError('Selecione os horários');
      return;
    }

    // Validação de 6 meses
    final maxEndDate = _startDate!.add(const Duration(days: 180));
    if (_endDate!.isAfter(maxEndDate)) {
      context.showError('Disponibilidade não pode ter mais de 6 meses de duração');
      return;
    }

    // Validação de endereço
    if (_selectedAddress == null) {
      context.showError('Selecione um endereço');
      return;
    }

    final availability = AvailabilityEntity(
      id: widget.availability?.id,
      dataInicio: _startDate!,
      dataFim: _endDate!,
      horarioInicio: '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
      horarioFim: '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
      diasDaSemana: _isRecurring ? _selectedDays : [],
      valorShow: double.parse(_valueController.text.replaceAll(',', '.')),
      endereco: _selectedAddress!,
      raioAtuacao: _radiusKm,
      repetir: _isRecurring,
      blockedSlots: _blockedSlots,
    );

    widget.onSave(availability);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final hasChanges = _hasChanges();

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.9,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header com drag handle
            Padding(
              padding: EdgeInsets.only(top: DSSize.height(12), bottom: DSSize.height(8)),
              child: Container(
                width: DSSize.width(40),
                height: DSSize.height(4),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(DSSize.width(2)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.availability != null
                        ? 'Editar Disponibilidade'
                        : 'Nova Disponibilidade',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: DSSize.width(16),
                  right: DSSize.width(16),
                  top: DSSize.height(16),
                  bottom: DSSize.height(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Período
                    SelectableRow(
                      label: 'Data início',
                      value: _startDateController.text.isEmpty
                          ? 'Selecione'
                          : _startDateController.text,
                      onTap: _selectStartDate,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    SelectableRow(
                      label: 'Data fim',
                      value: _endDateController.text.isEmpty
                          ? 'Selecione'
                          : _endDateController.text,
                      onTap: _selectEndDate,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    
                    // Horários
                    SelectableRow(
                      label: 'Horário início',
                      value: _startTimeController.text.isEmpty
                          ? 'Selecione'
                          : _startTimeController.text,
                      onTap: _selectStartTime,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    SelectableRow(
                      label: 'Horário fim',
                      value: _endTimeController.text.isEmpty
                          ? 'Selecione'
                          : _endTimeController.text,
                      onTap: _selectEndTime,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    
                    // Recorrência
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Recorrência?',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Switch(
                                activeColor: colorScheme.onPrimaryContainer,
                                value: _isRecurring,
                                onChanged: (value) {
                                  setState(() {
                                    _isRecurring = value;
                                    if (!value) {
                                      _selectedDays = [];
                                      _updateControllers();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    if (_isRecurring) ...[
                      DSSizedBoxSpacing.vertical(8),
                      SelectableRow(
                        label: 'Dias da semana',
                        value: _recurrenceDaysController.text.isEmpty
                            ? 'Selecione'
                            : _recurrenceDaysController.text,
                        onTap: _selectRecurrenceDays,
                      ),
                    ] else ...[
                      DSSizedBoxSpacing.vertical(8),
                      InformativeBanner(
                        message: 'Com a recorrência desativada, ficarão disponíveis todos os dias entre a data de início e a data de fim selecionadas.',
                      ),
                    ],
                    Divider(height: DSSize.height(32)),
                    DSSizedBoxSpacing.vertical(16),
                    
                    // Valor/hora
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Valor/hora',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _valueController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.end,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                onChanged: (_) => setState(() {}), // Atualiza para verificar mudanças
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  prefixText: 'R\$/h ',
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(DSSize.width(12)),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(DSSize.width(12)),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(DSSize.width(12)),
                                    borderSide: BorderSide(
                                      color: colorScheme.onPrimaryContainer,
                                      width: 1,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(DSSize.width(12)),
                                    borderSide: BorderSide(
                                      color: colorScheme.error,
                                      width: 1,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(DSSize.width(12)),
                                    borderSide: BorderSide(
                                      color: colorScheme.error,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: DSSize.width(12),
                                    vertical: DSSize.height(12),
                                  ),
                                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Digite o valor';
                                  }
                                  final num = double.tryParse(value.replaceAll(',', '.'));
                                  if (num == null || num <= 0) {
                                    return 'Valor inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    
                    // Endereço
                    SelectableRow(
                      label: 'Endereço base',
                      value: _selectedAddress?.title ?? 'Selecione',
                      onTap: _selectAddress,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    
                    // Mapa com raio
                    if (_selectedAddress != null) ...[
                      Text(
                        'Raio de atuação',
                        style: textTheme.bodyMedium,
                      ),
                      DSSizedBoxSpacing.vertical(8),
                      RadiusMapWidget(
                        address: _selectedAddress!,
                        radiusKm: _radiusKm,
                      ),
                      DSSizedBoxSpacing.vertical(16),
                      Text(
                        'Raio (km)',
                        style: textTheme.bodyMedium,
                      ),
                      DSSizedBoxSpacing.vertical(8),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Slider(
                              value: _radiusKm,
                              min: 0.1,
                              max: 50.0,
                              divisions: 999, // Permite incrementos de 0.1 (100 metros)
                              label: _radiusKm >= 1
                                  ? '${_radiusKm.toStringAsFixed(1)} km'
                                  : '${(_radiusKm * 1000).toStringAsFixed(0)} m',
                              onChanged: (value) {
                                setState(() {
                                  _radiusKm = value;
                                  _radiusController.text = value.toStringAsFixed(1);
                                });
                              },
                            ),
                          ),
                          DSSizedBoxSpacing.horizontal(16),
                          Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(DSSize.width(12)),
                              border: Border.all(
                                color: colorScheme.outline,
                              ),
                            ),
                            child: TextFormField(
                              controller: _radiusController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                              ],
                              onChanged: (value) {
                                final num = double.tryParse(value.replaceAll(',', '.'));
                                if (num != null && num >= 0.1 && num <= 100) {
                                  setState(() {
                                    _radiusKm = num;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                final num = double.tryParse(value.replaceAll(',', '.'));
                                if (num == null || num < 0.1 || num > 100) {
                                  return 'Entre 0.1 e 100';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // ⭐ Seção de Exceções - Fechar Horários (opcional)
                    Divider(height: DSSize.height(32)),
                    Text(
                      '🚫 Fechar Horários (Opcional)?',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    Text(
                      'Teve um imprevisto e não poderá se apresentar em algum dos horários disponibilizados acima? Clique em "Adicionar Fechamento" para defini-lo como indisponível.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    
                    // Lista de bloqueios
                    if (_blockedSlots.isNotEmpty) ...[
                      ..._blockedSlots.asMap().entries.map((entry) {
                        final index = entry.key;
                        final blocked = entry.value;
                        final dateStr = DateFormat('dd/MM/yyyy').format(blocked.date);
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: DSPadding.vertical(8)),
                          padding: EdgeInsets.all(DSPadding.horizontal(12)),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(DSSize.width(8)),
                            border: Border.all(
                              color: colorScheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.block,
                                size: DSSize.width(20),
                                color: colorScheme.error,
                              ),
                              DSSizedBoxSpacing.horizontal(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$dateStr, ${blocked.startTime} - ${blocked.endTime}',
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    if (blocked.note != null && blocked.note!.isNotEmpty)
                                      Text(
                                        blocked.note!,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: DSSize.width(20)),
                                onPressed: () {
                                  setState(() {
                                    _blockedSlots.removeAt(index);
                                  });
                                },
                                color: colorScheme.error,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      DSSizedBoxSpacing.vertical(16),
                    ],
                    
                    // Botão para gerenciar exceções
                    OutlinedButton.icon(
                      onPressed: _showBlockedSlotsModal,
                      icon: Icon(Icons.add),
                      label: Text('Adicionar Fechamento'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions - fixo na parte inferior
            Container(
              padding: EdgeInsets.only(
                left: DSSize.width(16),
                right: DSSize.width(16),
                top: DSSize.height(16),
                bottom: bottomPadding > 0 ? bottomPadding + DSSize.height(16) : DSSize.height(16),
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: DSSize.width(10),
                    offset: Offset(0, -DSSize.height(2)),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Cancelar',
                        buttonType: CustomButtonType.cancel,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    DSSizedBoxSpacing.horizontal(16),
                    Expanded(
                      child: CustomButton(
                        label: 'Salvar',
                        onPressed: hasChanges ? _onSave : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog para seleção de dias da semana
class _RecurrenceDaysDialog extends StatefulWidget {
  final List<String> initialSelected;
  final List<String> options;

  const _RecurrenceDaysDialog({
    required this.initialSelected,
    required this.options,
  });

  @override
  State<_RecurrenceDaysDialog> createState() => _RecurrenceDaysDialogState();
}

class _RecurrenceDaysDialogState extends State<_RecurrenceDaysDialog> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selected.contains(day)) {
        _selected.remove(day);
      } else {
        _selected.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text('Selecione os dias', style: textTheme.titleMedium?.copyWith(
        color: colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.bold,
      )),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.options.length,
          itemBuilder: (context, index) {
            final day = widget.options[index];
            final isSelected = _selected.contains(day);
            return CheckboxListTile(
              title: Text(day),
              value: isSelected,
              onChanged: (_) => _toggleDay(day),
            );
          },
        ),
      ),
      actions: [
        DialogButton(
          text: 'Cancelar',
          type: DialogButtonType.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogButton(
          text: 'Confirmar',
          type: DialogButtonType.primary,
          textColor: colorScheme.onPrimaryContainer,
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}

