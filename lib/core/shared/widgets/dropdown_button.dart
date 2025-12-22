import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String labelText;
  final List<String> itemsList;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const CustomDropdownButton({
    super.key,
    required this.labelText,
    required this.itemsList,
    required this.selectedValue,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surfaceContainerColor = colorScheme.surfaceContainerHighest;
    final onSurfaceContainerColor = colorScheme.onSurfaceVariant;
    final textColor = colorScheme.onPrimary;
    return DropdownButtonFormField<String>(
      isExpanded: true, // Faz o widget ocupar o máximo de espaço horizontal possível
      decoration: InputDecoration(
        hintStyle: TextStyle(color: onSurfaceContainerColor),
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onSurfaceContainerColor),
        filled: true,
        fillColor: surfaceContainerColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSSize.width(16)),
          borderSide: BorderSide(color: surfaceContainerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSSize.width(16)),
          borderSide: BorderSide(color: textColor),
        )
      ),
      dropdownColor: surfaceContainerColor.withOpacity(0.9),
      value: selectedValue,
      items: itemsList.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor)),
          
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
