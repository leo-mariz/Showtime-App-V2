import 'dart:async';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/formatters/input_formatters.dart';
import 'package:app/core/shared/widgets/dropdown_button.dart';
import 'package:app/core/shared/widgets/document_field_with_validation.dart';
import 'package:app/core/shared/widgets/document_validation_indicator.dart';
import 'package:flutter/material.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';

class CpfForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController cpfController;
  final TextEditingController birthdateController;
  final TextEditingController phoneNumberController;
  final String? selectedGender;
  final List<String> genderOptions;
  final Function(String?) onGenderChanged;
  final Function(bool) onValidationChanged; // Callback quando validação muda

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
    required this.onValidationChanged,
  });

  @override
  CpfFormState createState() => CpfFormState();
}

class CpfFormState extends State<CpfForm> {
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  Timer? _debounceTimer;
  String? _lastValidatedCpf;
  DocumentValidationStatus? _validationStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.cpfController.addListener(_onCpfChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.cpfController.removeListener(_onCpfChanged);
    super.dispose();
  }

  void _onCpfChanged() {
    if (_validationStatus == DocumentValidationStatus.loading) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final cpfText = widget.cpfController.text.trim();
      final cleanCpf = cpfText.replaceAll(RegExp(r'[^\d]'), '');

      // 1. Verificar se campo não está vazio
      if (cpfText.isEmpty) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
          _lastValidatedCpf = null; // Reset para permitir nova validação quando preencher
        });
        widget.onValidationChanged(false);
        return;
      }

      // 2. Verificar se CPF está completo (11 dígitos)
      if (cleanCpf.length != 11) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
        });
        widget.onValidationChanged(false);
        return;
      }

      // 3. Verificar se CPF é válido (formato) antes de buscar
      if (!CPFValidator.isValid(cpfText)) {
        // CPF inválido - mostrar erro de formato
        setState(() {
          _validationStatus = DocumentValidationStatus.error;
          _errorMessage = 'Digite um CPF válido';
        });
        widget.onValidationChanged(false);
        return;
      }

      // 4. CPF válido e completo - buscar no banco se for diferente do último validado
      if (cleanCpf != _lastValidatedCpf) {
        _validateCpf(cleanCpf);
      }
    });
  }

  void _validateCpf(String cpf) {
    setState(() {
      _validationStatus = DocumentValidationStatus.loading;
      _lastValidatedCpf = cpf;
    });

    context.read<UsersBloc>().add(CheckCpfExistsEvent(cpf: cpf));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is DocumentValidationSuccess && state.document == _lastValidatedCpf) {
          setState(() {
            _validationStatus = state.exists
                ? DocumentValidationStatus.exists
                : DocumentValidationStatus.available;
            _errorMessage = state.exists ? 'Este CPF já está em uso' : null;
          });
          widget.onValidationChanged(!state.exists);
        } else if (state is DocumentValidationFailure && state.document == _lastValidatedCpf) {
          setState(() {
            _validationStatus = DocumentValidationStatus.error;
            _errorMessage = state.error;
          });
          widget.onValidationChanged(false);
        }
      },
      child: Column(
      children: [
          DocumentFieldWithValidation(
          label: 'CPF',
          controller: widget.cpfController,
          validator: Validators.validateCPF,
          inputFormatters: [_cpfMask],
            validationStatus: _validationStatus,
            errorMessage: _errorMessage,
            onChanged: (value) {
              // Reset status quando usuário edita
              if (_validationStatus != null) {
                setState(() {
                  _validationStatus = null;
                  _errorMessage = null;
                  _lastValidatedCpf = null;
                });
                widget.onValidationChanged(false);
              }
            },
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
        DSSizedBoxSpacing.vertical(8),
        CustomTextField(
          label: 'Data de Nascimento',
          controller: widget.birthdateController,
          validator: Validators.validateBirthdate,
          inputFormatters: [
            DateInputFormatter(),
          ],
        ),
        DSSizedBoxSpacing.vertical(8),
        CustomDropdownButton(
          labelText: 'Gênero',
          itemsList: widget.genderOptions,
          selectedValue: widget.selectedGender,
          onChanged: widget.onGenderChanged,
          validator: Validators.validateIsNull,
        ),
      ],
      ),
    );
  }
}