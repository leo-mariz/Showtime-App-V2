import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/blocked_time_slot.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlockedSlotsModal extends StatefulWidget {
  final List<BlockedTimeSlot> initialBlockedSlots;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRecurring;
  final List<String> selectedDays;
  final String startTime;
  final String endTime;
  final ValueChanged<List<BlockedTimeSlot>>? onBlockedSlotsChanged;

  const BlockedSlotsModal({
    super.key,
    required this.initialBlockedSlots,
    required this.startDate,
    required this.endDate,
    required this.isRecurring,
    required this.selectedDays,
    required this.startTime,
    required this.endTime,
    this.onBlockedSlotsChanged,
  });

  /// Exibe o modal de bloqueios
  static Future<List<BlockedTimeSlot>?> show({
    required BuildContext context,
    required List<BlockedTimeSlot> initialBlockedSlots,
    required DateTime startDate,
    required DateTime endDate,
    required bool isRecurring,
    required List<String> selectedDays,
    required String startTime,
    required String endTime,
    ValueChanged<List<BlockedTimeSlot>>? onBlockedSlotsChanged,
  }) {
    return showModalBottomSheet<List<BlockedTimeSlot>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlockedSlotsModal(
        initialBlockedSlots: initialBlockedSlots,
        startDate: startDate,
        endDate: endDate,
        isRecurring: isRecurring,
        selectedDays: selectedDays,
        startTime: startTime,
        endTime: endTime,
        onBlockedSlotsChanged: onBlockedSlotsChanged,
      ),
    );
  }

  @override
  State<BlockedSlotsModal> createState() => _BlockedSlotsModalState();
}

class _BlockedSlotsModalState extends State<BlockedSlotsModal> {
  // Form fields for new blocked slot
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Verifica se a data está dentro da disponibilidade
  bool _isDateValid(DateTime date) {
    // 1. Verificar se está dentro do período (startDate e endDate)
    if (date.isBefore(widget.startDate) || date.isAfter(widget.endDate)) {
      return false;
    }

    // 2. Se não há recorrência, qualquer dia dentro do período é válido
    if (!widget.isRecurring || widget.selectedDays.isEmpty) {
      return true;
    }

    // 3. Se há recorrência, verificar se o dia da semana está nos dias selecionados
    // DateTime.weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
    // Códigos RFC: SU=Sunday, MO=Monday, TU=Tuesday, WE=Wednesday, TH=Thursday, FR=Friday, SA=Saturday
    final weekdayMap = {
      1: 'MO', // Monday
      2: 'TU', // Tuesday
      3: 'WE', // Wednesday
      4: 'TH', // Thursday
      5: 'FR', // Friday
      6: 'SA', // Saturday
      7: 'SU', // Sunday
    };

    final dayCode = weekdayMap[date.weekday];
    return dayCode != null && widget.selectedDays.contains(dayCode);
  }

  // Valida se o horário está dentro do range
  bool _isValidTimeRange(TimeOfDay time) {
    final timeMinutes = time.hour * 60 + time.minute;
    
    final startParts = widget.startTime.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    
    final endParts = widget.endTime.split(':');
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  Future<void> _selectDate() async {
    final picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: _selectedDate ?? widget.startDate,
      firstDate: widget.startDate,
      lastDate: widget.endDate,
    );

    if (picked != null) {
      // Validar se a data está dentro da disponibilidade
      if (!_isDateValid(picked)) {
        String errorMessage;
        if (picked.isBefore(widget.startDate) || picked.isAfter(widget.endDate)) {
          errorMessage = 'Esta data está fora do período da sua disponibilidade.\n'
              'Período válido: ${DateFormat('dd/MM/yyyy').format(widget.startDate)} até ${DateFormat('dd/MM/yyyy').format(widget.endDate)}';
        } else if (widget.isRecurring && widget.selectedDays.isNotEmpty) {
          // Converter códigos para nomes legíveis
          final dayNames = {
            'SU': 'Domingo',
            'MO': 'Segunda',
            'TU': 'Terça',
            'WE': 'Quarta',
            'TH': 'Quinta',
            'FR': 'Sexta',
            'SA': 'Sábado',
          };
          final validDays = widget.selectedDays.map((code) => dayNames[code] ?? code).join(', ');
          errorMessage = 'Esta data não faz parte da sua disponibilidade.\n'
              'Selecione apenas: $validDays';
        } else {
          errorMessage = 'Esta data não é válida para sua disponibilidade.';
        }
        
        context.showError(errorMessage);
        return;
      }

      // Data válida, selecionar
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final currentTime = _selectedStartTime ?? TimeOfDay(
      hour: int.parse(widget.startTime.split(':')[0]),
      minute: int.parse(widget.startTime.split(':')[1]),
    );
    
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
      if (!_isValidTimeRange(result)) {
        context.showError(
          'Horário fora do range da disponibilidade.\n'
          'Selecione entre ${widget.startTime} e ${widget.endTime}'
        );
        return;
      }

      setState(() {
        _selectedStartTime = result;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final currentTime = _selectedEndTime ?? TimeOfDay(
      hour: int.parse(widget.endTime.split(':')[0]),
      minute: int.parse(widget.endTime.split(':')[1]),
    );
    
    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Horário de término',
        initialHours: currentTime.hour,
        initialMinutes: currentTime.minute,
        type: WheelPickerType.time,
      ),
    );

    if (result != null) {
      if (!_isValidTimeRange(result)) {
        context.showError(
          'Horário fora do range da disponibilidade.\n'
          'Selecione entre ${widget.startTime} e ${widget.endTime}'
        );
        return;
      }

      setState(() {
        _selectedEndTime = result;
      });
    }
  }

  void _addBlockedSlot() {
    // Validações
    if (_selectedDate == null) {
      context.showError('Selecione uma data');
      return;
    }

    if (_selectedStartTime == null) {
      context.showError('Selecione o horário de início');
      return;
    }

    if (_selectedEndTime == null) {
      context.showError('Selecione o horário de término');
      return;
    }

    // Validar que hora fim > hora início
    final startMinutes = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
    final endMinutes = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;
    
    if (endMinutes <= startMinutes) {
      context.showError('Horário de término deve ser após o horário de início');
      return;
    }

    // Validar limite de 10 bloqueios (usando a lista inicial + novo bloqueio)
    if (widget.initialBlockedSlots.length >= 10) {
      context.showError('Limite de 10 bloqueios atingido');
      return;
    }

    final newSlot = BlockedTimeSlot(
      date: _selectedDate!,
      startTime: '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}',
      endTime: '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}',
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    // Criar nova lista com o bloqueio adicionado
    final updatedSlots = List<BlockedTimeSlot>.from(widget.initialBlockedSlots)..add(newSlot);
    
    // Notificar mudanças
    widget.onBlockedSlotsChanged?.call(updatedSlots);
    
    // Fechar modal e retornar lista atualizada
    Navigator.pop(context, updatedSlots);
  }

  void _cancel() {
    Navigator.pop(context);
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DSSize.width(20)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  'Fechar Horário',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _cancel,
                  color: colorScheme.onPrimary,
                ),
              ],
            ),
          ),
          
          // Content - Formulário
          Flexible(
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
                  // Informação
                  Container(
                    padding: EdgeInsets.all(DSPadding.horizontal(12)),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(DSSize.width(8)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: DSSize.width(20),
                        ),
                        DSSizedBoxSpacing.horizontal(8),
                        Expanded(
                          child: Text(
                            'Feche horários específicos dentro da sua disponibilidade',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  DSSizedBoxSpacing.vertical(24),

                  // Data
                  SelectableRow(
                    label: 'Data',
                    value: _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : 'Selecione',
                    onTap: _selectDate,
                  ),
                  DSSizedBoxSpacing.vertical(16),

                  // Horário de Início
                  SelectableRow(
                    label: 'Horário início',
                    value: _selectedStartTime != null
                        ? '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}'
                        : 'Selecione',
                    onTap: _selectStartTime,
                  ),
                  DSSizedBoxSpacing.vertical(16),

                  // Horário de Término
                  SelectableRow(
                    label: 'Horário fim',
                    value: _selectedEndTime != null
                        ? '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}'
                        : 'Selecione',
                    onTap: _selectEndTime,
                  ),
                  DSSizedBoxSpacing.vertical(16),

                  // Nota (Opcional)
                  Text(
                    'Motivo (opcional)',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Evento particular, viagem, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DSSize.width(12)),
                      ),
                    ),
                    maxLines: 3,
                    maxLength: 100,
                  ),
                ],
              ),
            ),
          ),

          // Footer Actions
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
                      onPressed: _cancel,
                    ),
                  ),
                  DSSizedBoxSpacing.horizontal(16),
                  Expanded(
                    child: CustomButton(
                      label: 'Adicionar',
                      onPressed: _addBlockedSlot,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
