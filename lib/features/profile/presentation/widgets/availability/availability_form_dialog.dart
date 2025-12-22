import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:app/features/profile/presentation/widgets/availability/radius_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Modal para criar/editar disponibilidade
class AvailabilityFormDialog extends StatefulWidget {
  final AvailabilityEntity? availability;
  final DateTime? initialDate;
  final Function(AvailabilityEntity) onSave;

  const AvailabilityFormDialog({
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
      builder: (context) => AvailabilityFormDialog(
        availability: availability,
        initialDate: initialDate,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AvailabilityFormDialog> createState() => _AvailabilityFormDialogState();
}

class _AvailabilityFormDialogState extends State<AvailabilityFormDialog> {
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

  // Mock de endereços - TODO: Buscar do artista
  final List<AddressInfoEntity> _availableAddresses = [
    AddressInfoEntity(
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
    ),
    AddressInfoEntity(
      title: 'Trabalho',
      zipCode: '04547-130',
      street: 'Rua Funchal',
      number: '263',
      district: 'Vila Olímpia',
      city: 'São Paulo',
      state: 'SP',
      latitude: -23.5935,
      longitude: -46.6854,
      isPrimary: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.availability != null) {
      _loadAvailability(widget.availability!);
    } else {
      _startDate = widget.initialDate ?? DateTime.now();
      _endDate = _startDate;
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 18, minute: 0);
      _selectedAddress = _availableAddresses.first;
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
    // TODO: Navegar para tela de seleção de endereços
    // Por enquanto, usar showDialog simples
    final selected = await showDialog<AddressInfoEntity>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione o endereço'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableAddresses.length,
            itemBuilder: (context, index) {
              final address = _availableAddresses[index];
              return ListTile(
                title: Text(address.title),
                subtitle: Text('${address.street}, ${address.number} - ${address.city}'),
                onTap: () => Navigator.of(context).pop(address),
              );
            },
          ),
        ),
      ),
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

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione as datas')),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione os horários')),
      );
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um endereço')),
      );
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
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            // const Divider(height: 1),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16,
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
                      SwitchListTile(
                        title: Text('Recorrência?', style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),),
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
                      if (_isRecurring) ...[
                        DSSizedBoxSpacing.vertical(8),
                        SelectableRow(
                          label: 'Dias da semana',
                          value: _recurrenceDaysController.text.isEmpty
                              ? 'Selecione'
                              : _recurrenceDaysController.text,
                          onTap: _selectRecurrenceDays,
                        ),
                      ],
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
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: _radiusController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                                ],
                                decoration: InputDecoration(
                                  suffixText: 'km',
                                  contentPadding: EdgeInsets.symmetric(horizontal: DSSize.width(8), vertical: DSSize.height(12)),
                                ),
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
                    ],
                  ),
                ),
              ),
              
            // Actions - fixo na parte inferior
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: bottomPadding > 0 ? bottomPadding + 16 : 16,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
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
                        onPressed: _onSave,
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
    return AlertDialog(
      title: const Text('Selecione os dias'),
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

