import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/document_validation_indicator.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget de campo de documento (CPF/CNPJ) com validação em tempo real
/// 
/// Exibe indicador visual de validação ao lado do campo
class DocumentFieldWithValidation extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final DocumentValidationStatus? validationStatus;
  final String? errorMessage;
  final bool enabled;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;

  const DocumentFieldWithValidation({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.inputFormatters,
    this.validationStatus,
    this.errorMessage,
    this.enabled = true,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomTextField(
            label: label,
            controller: controller,
            validator: validator,
            inputFormatters: inputFormatters,
            enabled: enabled,
            onChanged: onChanged,
            keyboardType: keyboardType ?? TextInputType.text,
          ),
        ),
        DSSizedBoxSpacing.horizontal(8),
        Padding(
          padding: EdgeInsets.only(top: DSSize.height(24)), // Alinha com o campo
          child: DocumentValidationIndicator(
            status: validationStatus,
            errorMessage: errorMessage,
          ),
        ),
      ],
    );
  }
}

