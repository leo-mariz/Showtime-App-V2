import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget reutilizável para input de valor por hora
/// 
/// Características:
/// - Formatação monetária (R$/h)
/// - Validação de valor positivo
/// - Layout responsivo com label
/// - Suporte a validação customizada
class PricePerHourInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hintText;
  final bool enabled;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool required;

  const PricePerHourInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.label = 'Valor/hora',
    this.hintText = '0.00',
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.required = true,
  });

  String? _defaultValidator(String? value) {
    if (required && (value == null || value.isEmpty)) {
      return 'Digite o valor';
    }
    
    if (value != null && value.isNotEmpty) {
      final num = double.tryParse(value.replaceAll(',', '.'));
      if (num == null || num <= 0) {
        return 'Valor inválido';
      }
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        
        // Input
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              prefixText: 'R\$/h ',
              filled: true,
              fillColor: enabled
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSSize.width(12)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: DSSize.width(12),
                vertical: DSSize.height(12),
              ),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
            validator: validator ?? _defaultValidator,
          ),
        ),
      ],
    );
  }
}
