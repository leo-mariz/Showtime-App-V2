// custom_multi_select_field.dart
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class CustomMultiSelectField extends StatefulWidget {
  final List<String> items;
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool readOnly;
  final Function(List<String>)? onChanged;

  const CustomMultiSelectField({
    super.key,
    required this.items,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  CustomMultiSelectFieldState createState() => CustomMultiSelectFieldState();
}

class CustomMultiSelectFieldState extends State<CustomMultiSelectField> {
  List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.controller.text.split(', ').where((e) => e.isNotEmpty).toList();
  }

  void _showMultiSelectDialog() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSSize.width(16)),
          ),
          child: MultiSelectDialogContent(
            items: widget.items,
            initialValue: _selectedItems,
            title: widget.labelText,
            onConfirm: (values) {
              setState(() {
                _selectedItems = values;
                widget.controller.text = _selectedItems.join(', ');
                widget.onChanged?.call(_selectedItems);
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surfaceContainerColor = colorScheme.surfaceContainerHighest;
    final textColor = colorScheme.onPrimary;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    return GestureDetector(
      onTap: widget.readOnly ? null : _showMultiSelectDialog,
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: onPrimaryContainer),
            filled: true,
            fillColor: surfaceContainerColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSSize.width(15)),
              borderSide: BorderSide(color: surfaceContainerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSSize.width(15)),
              borderSide: BorderSide(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}

class MultiSelectDialogContent extends StatefulWidget {
  final List<String> items;
  final List<String> initialValue;
  final String title;
  final Function(List<String>) onConfirm;

  const MultiSelectDialogContent({
    super.key,
    required this.items,
    required this.initialValue,
    required this.title,
    required this.onConfirm,
  });

  @override
  MultiSelectDialogContentState createState() => MultiSelectDialogContentState();
}

class MultiSelectDialogContentState extends State<MultiSelectDialogContent> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialValue);
  }

  void _toggleItem(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: DSSize.height(MediaQuery.of(context).size.height * 0.7),
        maxWidth: DSSize.width(MediaQuery.of(context).size.width * 0.85),
      ),
      padding: EdgeInsets.all(DSSize.width(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          DSSizedBoxSpacing.vertical(24),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: widget.items.map((item) {
                  final isSelected = _selectedItems.contains(item);
                  return Padding(
                    padding: EdgeInsets.only(bottom: DSSize.height(8)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _toggleItem(item),
                        borderRadius: BorderRadius.circular(DSSize.width(12)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                              : colorScheme.surface,
                            borderRadius: BorderRadius.circular(DSSize.width(12)),
                            border: Border.all(
                              color: isSelected 
                                ? colorScheme.primary
                                : colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: DSSize.width(16),
                              vertical: DSSize.height(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: isSelected 
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                      fontWeight: isSelected 
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: DSSize.width(24),
                                  height: DSSize.height(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected 
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected 
                                        ? colorScheme.primary
                                        : colorScheme.outline,
                                      width: DSSize.width(2),
                                    ),
                                  ),
                                  child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: DSSize.width(16),
                                        color: colorScheme.onSecondaryContainer,
                                      )
                                    : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          DSSizedBoxSpacing.vertical(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Cancelar',
                  backgroundColor: colorScheme.error,
                  textColor: colorScheme.onError,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              DSSizedBoxSpacing.horizontal(16),
              Expanded(
                child: CustomButton(
                  label: 'Confirmar',
                  backgroundColor: colorScheme.onPrimaryContainer,
                  textColor: colorScheme.primaryContainer,
                  onPressed: () {
                    widget.onConfirm(_selectedItems);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}