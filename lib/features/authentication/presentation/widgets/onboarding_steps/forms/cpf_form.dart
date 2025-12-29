import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/formatters/input_formatters.dart';
import 'package:app/core/shared/widgets/dropdown_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:app/features/authentication/presentation/widgets/onboarding_steps/forms/cpf_field_with_validation.dart';
import 'package:flutter/material.dart';

class CpfForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController cpfController;
  final TextEditingController birthdateController;
  final TextEditingController phoneNumberController;
  final String? selectedGender;
  final List<String> genderOptions;
  final Function(String?) onGenderChanged;
  final Function(bool)? onCpfValidationChanged;

  const CpfForm({
    super.key,
    required this.nameController,
    required this.lastNameController,
    required this.cpfController,
    required this.birthdateController,
    required this.phoneNumberController,
    required this.selectedGender,
    required this.genderOptions,
    required this.onGenderChanged,
    this.onCpfValidationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CpfFieldWithValidation(
          controller: cpfController,
          onValidationChanged: onCpfValidationChanged,
        ),
        DSSizedBoxSpacing.vertical(4),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Nome',
                controller: nameController,
                validator: Validators.validateIsNull,
              ),
            ),
            DSSizedBoxSpacing.horizontal(20),
            Expanded(
              child: CustomTextField(
                label: 'Sobrenome',
                controller: lastNameController,
                validator: Validators.validateIsNull,
              ),
            ),
          ],
        ),
        DSSizedBoxSpacing.vertical(8),
        CustomTextField(
          label: 'Data de Nascimento',
          controller: birthdateController,
          validator: Validators.validateBirthdate,
          inputFormatters: [
            DateInputFormatter(),
          ],
        ),
        DSSizedBoxSpacing.vertical(8),
        CustomDropdownButton(
          labelText: 'Gênero',
          itemsList: genderOptions,
          selectedValue: selectedGender,
          onChanged: onGenderChanged,
          validator: Validators.validateIsNull,
        ),
      ],
    );
  }
}
