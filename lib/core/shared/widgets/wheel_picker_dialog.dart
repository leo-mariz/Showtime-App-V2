import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/dialog_button.dart';
import 'package:flutter/material.dart';

enum WheelPickerType {
  time, // Para seleção de horário (0-23h, minutos de 15 em 15)
  duration, // Para seleção de duração (0-24h, minutos de 15 em 15)
  /// Antecedência mínima: uma roda só — 0h a 23h30 (passo 30 min), depois 1 dia a 14 dias. Valor em minutos.
  requestMinimumEarliness,
}

class WheelPickerDialog extends StatefulWidget {
  final String title;
  final String? subtitle; // Subtítulo para mostrar informações adicionais (ex: intervalos disponíveis)
  final int initialHours;
  final int initialMinutes;
  final WheelPickerType type;
  final Duration? minimumDuration; // Apenas para type.duration
  final int? minimumTimeInMinutes; // Horário mínimo em minutos (apenas para type.time)
  /// Máximo de horas (apenas para type.duration). Ex.: 96 para antecedência até 96h. Padrão 24.
  final int? maxHours;

  const WheelPickerDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.initialHours,
    required this.initialMinutes,
    required this.type,
    this.minimumDuration,
    this.minimumTimeInMinutes,
    this.maxHours,
  });

  @override
  State<WheelPickerDialog> createState() => _WheelPickerDialogState();
}

/// Opções do picker de antecedência mínima: 0h a 11h30 (30 em 30 min), 12h a 24h (hora em hora), depois 2 dias a 14 dias.
List<({String label, int valueMinutes})> _requestMinimumEarlinessOptions() {
  final list = <({String label, int valueMinutes})>[];
  for (int m = 0; m <= 11 * 60 + 30; m += 30) {
    final h = m ~/ 60;
    final min = m % 60;
    list.add((
      label: min == 0 ? '$h h' : '$h h ${min.toString().padLeft(2, '0')}',
      valueMinutes: m,
    ));
  }
  for (int h = 6; h <= 24; h++) {
    final m = h * 60;
    list.add((label: '$h h', valueMinutes: m));
  }
  for (int d = 2; d <= 14; d++) {
    list.add((label: '$d dias', valueMinutes: d * 24 * 60));
  }
  return list;
}

class _WheelPickerDialogState extends State<WheelPickerDialog> {
  late int _hours;
  late int _minutes;
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;

  List<({String label, int valueMinutes})>? _earlinessOptions;
  late int _earlinessSelectedIndex;
  late FixedExtentScrollController _earlinessController;

  int get _maxHours {
    if (widget.type == WheelPickerType.time) return 23;
    return widget.maxHours ?? 24;
  }
  int get _minutesStep => 15;
  int get _minutesCount => 4; // 0, 15, 30, 45

  @override
  void initState() {
    super.initState();
    if (widget.type == WheelPickerType.requestMinimumEarliness) {
      _earlinessOptions = _requestMinimumEarlinessOptions();
      final totalMinutes = widget.initialHours * 60 + widget.initialMinutes;
      int best = 0;
      for (int i = 0; i < _earlinessOptions!.length; i++) {
        if ((_earlinessOptions![i].valueMinutes - totalMinutes).abs() <
            (_earlinessOptions![best].valueMinutes - totalMinutes).abs()) {
          best = i;
        }
      }
      _earlinessSelectedIndex = best;
      _earlinessController = FixedExtentScrollController(initialItem: _earlinessSelectedIndex);
      _hours = 0;
      _minutes = 0;
      _hoursController = FixedExtentScrollController(initialItem: 0);
      _minutesController = FixedExtentScrollController(initialItem: 0);
    } else {
      _hours = widget.initialHours.clamp(0, _maxHours);
      _minutes = widget.initialMinutes;
      _minutes = ((_minutes / _minutesStep).round() * _minutesStep) % 60;
      _hoursController = FixedExtentScrollController(initialItem: _hours);
      _minutesController = FixedExtentScrollController(
        initialItem: _minutes ~/ _minutesStep,
      );
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    if (widget.type == WheelPickerType.requestMinimumEarliness) {
      _earlinessController.dispose();
    }
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
    if (widget.type == WheelPickerType.time && widget.minimumTimeInMinutes != null) {
      final currentTimeInMinutes = (_hours * 60) + _minutes;
      return currentTimeInMinutes >= widget.minimumTimeInMinutes!;
    }
    return true;
  }

  void _onConfirm() {
    if (widget.type == WheelPickerType.time) {
      Navigator.of(context).pop(_getCurrentTime());
    } else if (widget.type == WheelPickerType.requestMinimumEarliness &&
        _earlinessOptions != null) {
      final minutes = _earlinessOptions![_earlinessSelectedIndex].valueMinutes;
      Navigator.of(context).pop(Duration(minutes: minutes));
    } else {
      Navigator.of(context).pop(_getCurrentDuration());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
            DSSizedBoxSpacing.vertical(8),
            Text(
              widget.subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      content: SizedBox(
        height: DSSize.height(200),
        child: widget.type == WheelPickerType.requestMinimumEarliness &&
                _earlinessOptions != null
            ? ListWheelScrollView.useDelegate(
                controller: _earlinessController,
                itemExtent: DSSize.height(50),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _earlinessSelectedIndex = index;
                  });
                },
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final opt = _earlinessOptions![index];
                    final isSelected = index == _earlinessSelectedIndex;
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
                        opt.label,
                        style: textTheme.titleLarge?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onPrimary.withOpacity(0.6),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                  childCount: _earlinessOptions!.length,
                ),
              )
            : Row(
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
              child: DialogButton(
                text: 'Cancelar',
                type: DialogButtonType.text,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            DSSizedBoxSpacing.horizontal(16),
            Expanded(
              child: DialogButton(
                text: 'Confirmar',
                type: DialogButtonType.primary,
                backgroundColor: colorScheme.onPrimaryContainer,
                onPressed: (widget.type == WheelPickerType.requestMinimumEarliness || _isValid()) ? _onConfirm : null,
                textColor: _isValid() ? colorScheme.primaryContainer : colorScheme.onPrimary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

