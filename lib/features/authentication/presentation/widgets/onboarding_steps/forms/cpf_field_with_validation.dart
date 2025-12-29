import 'dart:async';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/document_validation_indicator.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';

/// Campo de CPF com validação em tempo real
class CpfFieldWithValidation extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool)? onValidationChanged; // Callback quando validação muda

  const CpfFieldWithValidation({
    super.key,
    required this.controller,
    this.onValidationChanged,
  });

  @override
  State<CpfFieldWithValidation> createState() => _CpfFieldWithValidationState();
}

class _CpfFieldWithValidationState extends State<CpfFieldWithValidation> {
  Timer? _debounceTimer;
  String? _lastValidatedCpf;
  DocumentValidationStatus? _validationStatus;
  String? _errorMessage;

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCpfChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onCpfChanged);
    super.dispose();
  }

  void _onCpfChanged() {
    // Se está carregando, não fazer nada (aguardar resultado)
    if (_validationStatus == DocumentValidationStatus.loading) return;

    // Sempre resetar estado quando o usuário edita (para permitir nova validação)
    final currentCpf = widget.controller.text.replaceAll(RegExp(r'[^\d]'), '');
    if (currentCpf != _lastValidatedCpf) {
      // CPF mudou, resetar estado de validação completamente
      setState(() {
        _validationStatus = null;
        _errorMessage = null;
        _lastValidatedCpf = null; // Resetar para forçar nova validação
      });
      // Resetar validação no parent
      widget.onValidationChanged?.call(true);
    }

    _debounceTimer?.cancel();
    // Debounce de 1.5 segundos
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      final cpf = widget.controller.text.replaceAll(RegExp(r'[^\d]'), '');

      // Se CPF está vazio, reset status
      if (cpf.isEmpty) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
          _lastValidatedCpf = null;
        });
        widget.onValidationChanged?.call(true); // Válido porque ainda não validou
        return;
      }

      // Verificar se CPF tem 11 dígitos
      if (cpf.length != 11) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
          _lastValidatedCpf = null;
        });
        widget.onValidationChanged?.call(true); // Válido porque ainda não validou
        return;
      }

      // Verificar se CPF é válido (formato)
      if (!CPFValidator.isValid(widget.controller.text)) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
          _lastValidatedCpf = null;
        });
        widget.onValidationChanged?.call(true); // Válido porque ainda não validou
        return;
      }

      // CPF válido - sempre validar se for diferente do último validado
      if (cpf != _lastValidatedCpf) {
        _validateCpf(cpf);
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
          widget.onValidationChanged?.call(!state.exists);
        } else if (state is DocumentValidationFailure && state.document == _lastValidatedCpf) {
          setState(() {
            _validationStatus = DocumentValidationStatus.error;
            _errorMessage = state.error;
          });
          widget.onValidationChanged?.call(false);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomTextField(
              label: 'CPF',
              controller: widget.controller,
              validator: Validators.validateCPF,
              inputFormatters: [_cpfMask],
              onChanged: (value) {
                // Reset status quando usuário edita - isso já é feito no _onCpfChanged
                // Mas garantimos que o callback seja chamado para resetar o estado no parent
                if (_validationStatus != null) {
                  widget.onValidationChanged?.call(true); // Resetar validação
                }
              },
            ),
          ),
          DSSizedBoxSpacing.horizontal(8),
          Padding(
            padding: EdgeInsets.only(top: DSSize.height(24)), // Alinha com o campo
            child: DocumentValidationIndicator(
              status: _validationStatus,
              errorMessage: _errorMessage,
            ),
          ),
        ],
      ),
    );
  }
}

