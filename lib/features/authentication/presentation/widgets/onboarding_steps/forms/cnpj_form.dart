import 'dart:async';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/shared/widgets/document_field_with_validation.dart';
import 'package:app/core/shared/widgets/document_validation_indicator.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';

class CnpjForm extends StatefulWidget {
  final TextEditingController cnpjController;
  final TextEditingController companyNameController;
  final TextEditingController fantasyNameController;
  final TextEditingController stateRegistrationController;
  final TextEditingController phoneNumberController;
  final Function(bool) onValidationChanged; // Callback quando validação muda

  const CnpjForm({
    super.key,
    required this.cnpjController,
    required this.companyNameController,
    required this.fantasyNameController,
    required this.stateRegistrationController,
    required this.phoneNumberController,
    required this.onValidationChanged,
  });

  @override
  CnpjFormState createState() => CnpjFormState();
}

class CnpjFormState extends State<CnpjForm> {
  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  Timer? _debounceTimer;
  String? _lastValidatedCnpj;
  DocumentValidationStatus? _validationStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.cnpjController.addListener(_onCnpjChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.cnpjController.removeListener(_onCnpjChanged);
    super.dispose();
  }

  void _onCnpjChanged() {
    if (_validationStatus == DocumentValidationStatus.loading) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final cnpjText = widget.cnpjController.text.trim();
      final cleanCnpj = cnpjText.replaceAll(RegExp(r'[^\d]'), '');

      // 1. Verificar se campo não está vazio
      if (cnpjText.isEmpty) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
          _lastValidatedCnpj = null; // Reset para permitir nova validação quando preencher
        });
        widget.onValidationChanged(false);
        return;
      }

      // 2. Verificar se CNPJ está completo (14 dígitos)
      if (cleanCnpj.length != 14) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
        });
        widget.onValidationChanged(false);
        return;
      }

      // 3. Verificar se CNPJ é válido (formato) antes de buscar
      if (!CNPJValidator.isValid(cnpjText)) {
        // CNPJ inválido - mostrar erro de formato
        setState(() {
          _validationStatus = DocumentValidationStatus.error;
          _errorMessage = 'Digite um CNPJ válido';
        });
        widget.onValidationChanged(false);
        return;
      }

      // 4. CNPJ válido e completo - buscar no banco se for diferente do último validado
      if (cleanCnpj != _lastValidatedCnpj) {
        _validateCnpj(cleanCnpj);
      }
    });
  }

  void _validateCnpj(String cnpj) {
    setState(() {
      _validationStatus = DocumentValidationStatus.loading;
      _lastValidatedCnpj = cnpj;
    });

    context.read<UsersBloc>().add(CheckCnpjExistsEvent(cnpj: cnpj));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is DocumentValidationSuccess && state.document == _lastValidatedCnpj) {
          setState(() {
            _validationStatus = state.exists
                ? DocumentValidationStatus.exists
                : DocumentValidationStatus.available;
            _errorMessage = state.exists ? 'Este CNPJ já está em uso' : null;
          });
          widget.onValidationChanged(!state.exists);
        } else if (state is DocumentValidationFailure && state.document == _lastValidatedCnpj) {
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
          label: 'CNPJ',
          controller: widget.cnpjController,
          inputFormatters: [_cnpjMask],
          validator: Validators.validateCNPJ,
          keyboardType: TextInputType.number,
            validationStatus: _validationStatus,
            errorMessage: _errorMessage,
            onChanged: (value) {
              // Reset status quando usuário edita
              if (_validationStatus != null) {
                setState(() {
                  _validationStatus = null;
                  _errorMessage = null;
                  _lastValidatedCnpj = null;
                });
                widget.onValidationChanged(false);
              }
            },
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
      ),
    );
  }
}