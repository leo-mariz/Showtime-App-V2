import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/formatters/input_formatters.dart';
import 'package:app/core/shared/widgets/dropdown_button.dart';
import 'package:flutter/material.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CpfForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController cpfController;
  final TextEditingController birthdateController;
  final TextEditingController phoneNumberController;
  final String? selectedGender;
  final List<String> genderOptions;
  final Function(String?) onGenderChanged;

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
  });

  @override
  CpfFormState createState() => CpfFormState();
}

class CpfFormState extends State<CpfForm> {

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // final _phoneMask = MaskTextInputFormatter(
  //   mask: '(##) #####-####',
  //   filter: {"#": RegExp(r'[0-9]')},
  // );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'CPF',
          controller: widget.cpfController,
          validator: Validators.validateCPF,
          inputFormatters: [_cpfMask],
        ),
        DSSizedBoxSpacing.vertical(4),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Nome',
                controller: widget.nameController,
                validator: Validators.validateIsNull,
              ),
            ),
            DSSizedBoxSpacing.horizontal(20),
            Expanded(
              child: CustomTextField(
                label: 'Sobrenome',
                controller: widget.lastNameController,
                validator: Validators.validateIsNull,
              ),
            ),
          ],
        ),
        DSSizedBoxSpacing.vertical(4),
        Row(
          children: [
            Expanded(
              flex: 7,
              child: CustomTextField(
                label: 'Data de Nascimento',
                controller: widget.birthdateController,
                validator: Validators.validateBirthdate,
                inputFormatters: [
                  DateInputFormatter(),
                ],
              ),
            ),
            DSSizedBoxSpacing.horizontal(20),
            Expanded(
              flex: 6,
              child: CustomDropdownButton(
                labelText: 'Gênero',
                itemsList: widget.genderOptions,
                selectedValue: widget.selectedGender,
                onChanged: widget.onGenderChanged,
                validator: Validators.validateIsNull,
              ),
            ),
          ],
        ),
      ],
    );
  }
}