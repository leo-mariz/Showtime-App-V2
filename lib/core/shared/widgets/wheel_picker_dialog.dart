import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

enum WheelPickerType {
  time, // Para seleção de horário (0-23h, minutos de 15 em 15)
  duration, // Para seleção de duração (0-24h, minutos de 15 em 15)
}

class WheelPickerDialog extends StatefulWidget {
  final String title;
  final int initialHours;
  final int initialMinutes;
  final WheelPickerType type;
  final Duration? minimumDuration; // Apenas para type.duration

  const WheelPickerDialog({
    super.key,
    required this.title,
    required this.initialHours,
    required this.initialMinutes,
    required this.type,
    this.minimumDuration,
  });

  @override
  State<WheelPickerDialog> createState() => _WheelPickerDialogState();
}

class _WheelPickerDialogState extends State<WheelPickerDialog> {
  late int _hours;
  late int _minutes;
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;

  int get _maxHours => widget.type == WheelPickerType.time ? 23 : 24;
  int get _minutesStep => 15;
  int get _minutesCount => 4; // 0, 15, 30, 45

  @override
  void initState() {
    super.initState();
    _hours = widget.initialHours.clamp(0, _maxHours);
    _minutes = widget.initialMinutes;
    
    // Arredonda minutos para o múltiplo de 15 mais próximo
    _minutes = ((_minutes / _minutesStep).round() * _minutesStep) % 60;
    
    _hoursController = FixedExtentScrollController(initialItem: _hours);
    _minutesController = FixedExtentScrollController(
      initialItem: _minutes ~/ _minutesStep,
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Duration _getCurrentDuration() {
    return Duration(hours: _hours, minutes: _minutes);
  }

  TimeOfDay _getCurrentTime() {
    return TimeOfDay(hour: _hours, minute: _minutes);
  }

  bool _isValid() {
    if (widget.type == WheelPickerType.duration && widget.minimumDuration != null) {
      return _getCurrentDuration() >= widget.minimumDuration!;
    }
    return true;
  }

  void _onConfirm() {
    if (widget.type == WheelPickerType.time) {
      Navigator.of(context).pop(_getCurrentTime());
    } else {
      Navigator.of(context).pop(_getCurrentDuration());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        height: DSSize.height(200),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Horas',
                    style: textTheme.bodyMedium,
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: _hoursController,
                      itemExtent: DSSize.height(50),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _hours = index;
                        });
                      },
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final isSelected = index == _hours;
                          return Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                              horizontal: DSSize.width(8),
                              vertical: DSSize.height(4),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primaryContainer.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(DSSize.width(12)),
                              border: isSelected
                                  ? Border.all(
                                      color: colorScheme.onPrimaryContainer,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Text(
                              widget.type == WheelPickerType.time
                                  ? index.toString().padLeft(2, '0')
                                  : '$index',
                              style: textTheme.titleLarge?.copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onPrimary.withOpacity(0.6),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                        childCount: _maxHours + 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DSSizedBoxSpacing.horizontal(16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Minutos',
                    style: textTheme.bodyMedium,
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: _minutesController,
                      itemExtent: DSSize.height(50),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _minutes = index * _minutesStep;
                        });
                      },
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final minutes = index * _minutesStep;
                          final isSelected = minutes == _minutes;
                          return Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                              horizontal: DSSize.width(8),
                              vertical: DSSize.height(4),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primaryContainer.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(DSSize.width(12)),
                              border: isSelected
                                  ? Border.all(
                                      color: colorScheme.onPrimaryContainer,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Text(
                              minutes.toString().padLeft(2, '0'),
                              style: textTheme.titleLarge?.copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onPrimary.withOpacity(0.6),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                        childCount: _minutesCount,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
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
                label: 'Confirmar',
                onPressed: _isValid() ? _onConfirm : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

