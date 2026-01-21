import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/price_per_hour_input.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:flutter/material.dart';

/// Modal para criar/editar um slot de tempo (hora início, hora fim, valor/h)
/// 
/// Se os parâmetros forem null, o modal abre em modo "criar"
/// Se os parâmetros forem fornecidos, abre em modo "editar"
class EditSlotModal extends StatefulWidget {
  final String? startTime; // Formato: "HH:mm" (null = criar novo)
  final String? endTime; // Formato: "HH:mm" (null = criar novo)
  final double? pricePerHour; // null = criar novo

  const EditSlotModal({
    super.key,
    this.startTime,
    this.endTime,
    this.pricePerHour,
  });

  /// Exibe o modal de edição
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    String? startTime,
    String? endTime,
    double? pricePerHour,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditSlotModal(
        startTime: startTime,
        endTime: endTime,
        pricePerHour: pricePerHour,
      ),
    );
  }

  /// Verifica se está em modo criar (vs editar)
  bool get isCreateMode => startTime == null && endTime == null && pricePerHour == null;

  @override
  State<EditSlotModal> createState() => _EditSlotModalState();
}

class _EditSlotModalState extends State<EditSlotModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    
    if (widget.startTime != null && widget.endTime != null) {
      // Modo editar: parse horários existentes
      final startParts = widget.startTime!.split(':');
      _startTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
      
      final endParts = widget.endTime!.split(':');
      _endTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
      
      _priceController.text = widget.pricePerHour?.toStringAsFixed(0) ?? '';
    } else {
      // Modo criar: valores padrão
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 18, minute: 0);
      _priceController.text = '';
    }
    
    // Atualiza controllers
    _updateControllers();
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateControllers() {
    _startTimeController.text =
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    _endTimeController.text =
        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectStartTime() async {
    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Horário de início',
        initialHours: _startTime.hour,
        initialMinutes: _startTime.minute,
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
    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Horário de fim',
        initialHours: _endTime.hour,
        initialMinutes: _endTime.minute,
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

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que hora fim é maior que hora início
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horário de fim deve ser maior que horário de início'),
        ),
      );
      return;
    }

    // Retorna os dados editados
    Navigator.of(context).pop({
      'startTime':
          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
      'endTime':
          '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
      'pricePerHour': double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DSSize.width(20)),
          child: Form(
            key: _formKey,
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
                  widget.isCreateMode ? 'Adicionar horário' : 'Editar horário',
                  style: TextStyle(
                    fontSize: calculateFontSize(20),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                DSSizedBoxSpacing.vertical(24),

                // Horário início
                SelectableRow(
                  label: 'Horário início',
                  value: _startTimeController.text.isEmpty
                      ? 'Selecione'
                      : _startTimeController.text,
                  onTap: _selectStartTime,
                ),

                DSSizedBoxSpacing.vertical(16),

                // Horário fim
                SelectableRow(
                  label: 'Horário fim',
                  value: _endTimeController.text.isEmpty
                      ? 'Selecione'
                      : _endTimeController.text,
                  onTap: _selectEndTime,
                ),

                DSSizedBoxSpacing.vertical(16),

                // Valor por hora
                PricePerHourInput(
                  controller: _priceController,
                  hintText: '150',
                ),

                DSSizedBoxSpacing.vertical(24),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Cancelar',
                        onPressed: () => Navigator.of(context).pop(),
                        backgroundColor: Colors.transparent,
                        textColor: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    DSSizedBoxSpacing.horizontal(12),
                    Expanded(
                      child: CustomButton(
                        label: 'Salvar',
                        onPressed: _onSave,
                        backgroundColor: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),

                DSSizedBoxSpacing.vertical(16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
