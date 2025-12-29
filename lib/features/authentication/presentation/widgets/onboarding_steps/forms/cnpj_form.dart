import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:app/features/authentication/presentation/widgets/onboarding_steps/forms/cnpj_field_with_validation.dart';
import 'package:flutter/material.dart';

class CnpjForm extends StatelessWidget {
  final TextEditingController cnpjController;
  final TextEditingController companyNameController;
  final TextEditingController fantasyNameController;
  final TextEditingController stateRegistrationController;
  final TextEditingController phoneNumberController;
  final Function(bool)? onCnpjValidationChanged;

  const CnpjForm({
    super.key,
    required this.cnpjController,
    required this.companyNameController,
    required this.fantasyNameController,
    required this.stateRegistrationController,
    required this.phoneNumberController,
    this.onCnpjValidationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CnpjFieldWithValidation(
          controller: cnpjController,
          onValidationChanged: onCnpjValidationChanged,
        ),
        DSSizedBoxSpacing.vertical(4),
        CustomTextField(
          label: 'Razão Social',
          controller: companyNameController,
          validator: Validators.validateIsNull,
        ),
        DSSizedBoxSpacing.vertical(4),
        CustomTextField(
          label: 'Nome Fantasia',
          controller: fantasyNameController,
          validator: Validators.validateIsNull,
        ),
      ],
    );
  }
}
