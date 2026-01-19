import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/core/shared/widgets/dialog_button.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:app/features/addresses/presentation/widgets/addresses_modal.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/radius_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';



/// Modal para criar/editar disponibilidade
class AvailabilityFormModal extends StatefulWidget {
  final DateTime? initialDate;

  const AvailabilityFormModal({
    super.key,
    this.initialDate,
  });

  /// Exibe o modal de disponibilidade
  static Future<void> show({
    required BuildContext context,
    DateTime? initialDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvailabilityFormModal(
        initialDate: initialDate,
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
  bool _isBlocking = false; // Modo Abrir/Fechar
  bool _allHours = true; // Todos os horários (apenas para modo Fechar)
  bool _allDays = true; // Todos os dias (apenas para modo Abrir)
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<String> _selectedWeekdays = []; // Códigos: MO, TU, WE, etc
  AddressInfoEntity? _selectedAddress;
  double _radiusKm = 10.0; // Padrão: 10km

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate ?? DateTime.now();
    _endDate = _startDate;
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endTime = const TimeOfDay(hour: 18, minute: 0);
    _updateControllers();
  }
  
  void _onModeChanged(bool isBlocking) {
    setState(() {
      _isBlocking = isBlocking;
      if (_isBlocking) {
        // Modo Fechar: reseta alguns campos
        _allHours = true;
      } else {
        // Modo Abrir: garante que "Todos os dias" esteja marcado por padrão
        _allDays = true;
        _selectedWeekdays.clear();
      }
      _updateControllers();
    });
  }
  
  void _updateControllers() {
    // Atualiza data início
    if (_startDate != null) {
      _startDateController.text = DateFormat('dd/MM/yyyy').format(_startDate!);
    }
    
    // Atualiza data fim
    if (_endDate != null) {
      _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate!);
    }
    
    // Atualiza horário início
    if (_startTime != null) {
      _startTimeController.text = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
    }
    
    // Atualiza horário fim
    if (_endTime != null) {
      _endTimeController.text = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
    }
    
    // Atualiza dias da semana
    if (_allDays || _selectedWeekdays.isEmpty) {
      _recurrenceDaysController.text = 'Todos os dias';
    } else {
      _recurrenceDaysController.text = _selectedWeekdays
          .map((code) => WeekdayConstants.codeToName[code] ?? code)
          .join(', ');
    }
    
    // Atualiza raio
    _radiusController.text = _radiusKm.toStringAsFixed(1);
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
        // Atualiza data fim para igual à data início
        _endDate = picked;
        _updateControllers();
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      context.showError('Selecione a data de início primeiro');
      return;
    }
    
    final picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
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
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _WeekdaySelectionDialog(
        allDaysSelected: _allDays,
        selectedWeekdays: Set.from(_selectedWeekdays),
      ),
    );

    if (result != null) {
      setState(() {
        _allDays = result['allDays'] as bool;
        _selectedWeekdays = List<String>.from(result['weekdays'] as List);
        _updateControllers();
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

    if (_isBlocking) {
      // Validações para modo Fechar
      if (!_allHours && (_startTime == null || _endTime == null)) {
        context.showError('Selecione os horários');
        return;
      }
      
      // TODO: Implementar lógica de bloqueio de período
      context.showError('Funcionalidade de bloqueio em desenvolvimento');
      return;
    } else {
      // Validações para modo Abrir
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

    // Validação de dias da semana (somente se não for "Todos os dias")
    if (!_allDays && _selectedWeekdays.isEmpty) {
      context.showError('Selecione os dias da semana');
      return;
    }

    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return GestureDetector(
      onTap: () {
        // Fecha o teclado ao tocar fora dos campos
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
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
                    'Nova Disponibilidade',
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
            
            // Tipo (Abrir/Fechar) - Apenas para novas disponibilidades
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DSSize.width(16), vertical: DSSize.height(16)),
                child: SegmentedButton<bool>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    selectedBackgroundColor: colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DSSize.width(12)),
                    ),
                    selectedForegroundColor: colorScheme.primaryContainer,
                  ),
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(
                        'Abrir',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.event_available),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(
                        'Fechar',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.block),
                    ),
                  ],
                  selected: {_isBlocking},
                  onSelectionChanged: (Set<bool> newSelection) {
                    _onModeChanged(newSelection.first);
                  },
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
                    
                    // Campos específicos para modo Fechar
                    
                    DSSizedBoxSpacing.vertical(16),
                        SelectableRow(
                          label: 'Dias da semana',
                          value: _recurrenceDaysController.text.isEmpty
                              ? 'Selecione'
                              : _recurrenceDaysController.text,
                          onTap: _selectRecurrenceDays,
                        ),

                        if (_isBlocking) ...[
                          DSSizedBoxSpacing.vertical(16),
                      CheckboxListTile(
                        title: const Text('Todos os horários'),
                        value: _allHours,
                        onChanged: (value) {
                          setState(() {
                            _allHours = value ?? true;
                            if (_allHours) {
                              _startTime = null;
                              _endTime = null;
                              _startTimeController.clear();
                              _endTimeController.clear();
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      if (!_allHours) ...[
                        DSSizedBoxSpacing.vertical(8),
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
                      ],
                    ],
                    
                    // Campos específicos para modo Abrir
                    if (!_isBlocking) ...[
                      // // Checkbox: Todos os dias
                      // CheckboxListTile(
                      //   title: const Text('Todos os dias'),
                      //   value: _allDays,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _allDays = value ?? true;
                      //       if (_allDays) {
                      //         _selectedWeekdays.clear();
                      //       }
                      //       _updateControllers();
                      //     });
                      //   },
                      //   contentPadding: EdgeInsets.zero,
                      // ),
                      
                      // Dias da semana (somente se não for "Todos os dias")

                        

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
                    ],
                    
                    // Campos específicos para modo Abrir
                    if (!_isBlocking) ...[
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
                              max: 200.0,
                              divisions: 1999, // Permite incrementos de 0.1 (100 metros)
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
                                if (num != null && num >= 0.1 && num <= 200) {
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
                                if (num == null || num < 0.1 || num > 200) {
                                  return 'Entre 0.1 e 200';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  DSSizedBoxSpacing.vertical(32),                                        
                    
                  // Actions - fixo na parte inferior
                   Row(
                        children: [
                          
                          Expanded(
                            child: CustomButton(
                              label: _isBlocking ? 'Fechar Período' : 'Abrir Disponibilidade',
                              onPressed: _onSave,
                            ),
                          ),
                        ],
                      ),
                      DSSizedBoxSpacing.vertical(16),
                    
                  ],
                ),
              ),          
            ),
          ],
        ),
      ),
    ),
  );
  }
}


/// Dialog para seleção de dias da semana
class _WeekdaySelectionDialog extends StatefulWidget {
  final bool allDaysSelected;
  final Set<String> selectedWeekdays;

  const _WeekdaySelectionDialog({
    required this.allDaysSelected,
    required this.selectedWeekdays,
  });

  @override
  State<_WeekdaySelectionDialog> createState() => _WeekdaySelectionDialogState();
}

class _WeekdaySelectionDialogState extends State<_WeekdaySelectionDialog> {
  late bool _allDays;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _allDays = widget.allDaysSelected;
    _selected = Set.from(widget.selectedWeekdays);
  }

  void _toggleAllDays() {
    setState(() {
      _allDays = !_allDays;
      if (_allDays) {
        _selected.clear();
      }
    });
  }

  void _toggleDay(String code) {
    if (_allDays) return;
    
    setState(() {
      if (_selected.contains(code)) {
        _selected.remove(code);
      } else {
        _selected.add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return AlertDialog(
      title: Text(
        'Selecione os dias',
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Opção "Todos os dias"
            CheckboxListTile(
              title: Text(
                'Todos os dias',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              value: _allDays,
              onChanged: (_) => _toggleAllDays(),
            ),
            
            const Divider(),
            
            // Lista de dias da semana
            ...List.generate(WeekdayConstants.codes.length, (index) {
              final code = WeekdayConstants.codes[index];
              final name = WeekdayConstants.names[index];
              final isSelected = _selected.contains(code);
              
              return CheckboxListTile(
                title: Text(name),
                value: isSelected,
                onChanged: _allDays ? null : (_) => _toggleDay(code),
              );
            }),
          ],
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
          onPressed: () {
            Navigator.of(context).pop({
              'allDays': _allDays,
              'weekdays': _selected.toList(),
            });
          },
        ),
      ],
    );
  }
}

