import 'package:app/features/authentication/presentation/widgets/onboarding_steps/forms/cnpj_form.dart';
import 'package:app/features/authentication/presentation/widgets/onboarding_steps/forms/cpf_form.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

/// Step 2 do onboarding: Informações básicas (CPF ou CNPJ)
class BasicInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool isArtist;
  
  // Controllers CPF
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController cpfController;
  final TextEditingController birthdateController;
  
  // Controllers CNPJ
  final TextEditingController cnpjController;
  final TextEditingController companyNameController;
  final TextEditingController fantasyNameController;
  final TextEditingController stateRegistrationController;
  
  // Controllers compartilhados
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  
  // Estado CPF
  final String? selectedGender;
  final List<String> genderOptions;
  final Function(String?) onGenderChanged;
  
  final Function(bool) onDocumentTypeChanged;
  final bool isCnpj;
  final Function(bool)? onCpfValidationChanged;
  final Function(bool)? onCnpjValidationChanged;

  const BasicInfoStep({
    super.key,
    required this.formKey,
    required this.isArtist,
    required this.nameController,
    required this.lastNameController,
    required this.cpfController,
    required this.birthdateController,
    required this.cnpjController,
    required this.companyNameController,
    required this.fantasyNameController,
    required this.stateRegistrationController,
    required this.emailController,
    required this.phoneNumberController,
    required this.selectedGender,
    required this.genderOptions,
    required this.onGenderChanged,
    required this.onDocumentTypeChanged,
    required this.isCnpj,
    this.onCpfValidationChanged,
    this.onCnpjValidationChanged,
  });

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: widget.formKey,
      // autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seleção CPF ou CNPJ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: Text(
                    'CPF',
                    style: textTheme.bodySmall,
                  ),
                  value: false,
                  groupValue: widget.isCnpj,
                  onChanged: (value) {
                    if (value != null) {
                      widget.onDocumentTypeChanged(value);
                    }
                  },
                  activeColor: colorScheme.onPrimaryContainer,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: Text(
                    'CNPJ',
                    style: textTheme.bodySmall,
                  ),
                  value: true,
                  groupValue: widget.isCnpj,
                  onChanged: (value) {
                    if (value != null) {
                      widget.onDocumentTypeChanged(value);
                    }
                  },
                  activeColor: colorScheme.onPrimaryContainer,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          
          DSSizedBoxSpacing.vertical(8),
          
            // Campos específicos
            if (widget.isCnpj) ...[
              CnpjForm(
                cnpjController: widget.cnpjController,
                companyNameController: widget.companyNameController,
                fantasyNameController: widget.fantasyNameController,
                stateRegistrationController: widget.stateRegistrationController,
                phoneNumberController: widget.phoneNumberController,
                onCnpjValidationChanged: widget.onCnpjValidationChanged,
              ),
            ] else ...[
              CpfForm(
                cpfController: widget.cpfController,
                nameController: widget.nameController,
                lastNameController: widget.lastNameController,
                birthdateController: widget.birthdateController,
                genderOptions: widget.genderOptions,
                selectedGender: widget.selectedGender,
                phoneNumberController: widget.phoneNumberController,
                onGenderChanged: widget.onGenderChanged,
                onCpfValidationChanged: widget.onCpfValidationChanged,
              ),
            ],
        ],
      ),
    );
  }
}

