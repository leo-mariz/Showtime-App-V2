import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CnpjForm extends StatefulWidget {
  final TextEditingController cnpjController;
  final TextEditingController companyNameController;
  final TextEditingController fantasyNameController;
  final TextEditingController stateRegistrationController;
  final TextEditingController phoneNumberController;

  const CnpjForm({
    super.key,
    required this.cnpjController,
    required this.companyNameController,
    required this.fantasyNameController,
    required this.stateRegistrationController,
    required this.phoneNumberController,
  });

  @override
  CnpjFormState createState() => CnpjFormState();
}

class CnpjFormState extends State<CnpjForm> {

  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
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
          label: 'CNPJ',
          controller: widget.cnpjController,
          inputFormatters: [_cnpjMask],
          validator: Validators.validateCNPJ,
          keyboardType: TextInputType.number,
        ),
        DSSizedBoxSpacing.vertical(4),
        CustomTextField(
          label: 'Razão Social',
          controller: widget.companyNameController,
          validator: Validators.validateIsNull,
        ),
        DSSizedBoxSpacing.vertical(4),
        CustomTextField(
          label: 'Nome Fantasia',
          controller: widget.fantasyNameController,
          validator: Validators.validateIsNull,
        ),
      ],
    );
  }
}