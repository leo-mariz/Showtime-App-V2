import 'dart:async';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/document_validation_indicator.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';

/// Campo de CNPJ com validação em tempo real
class CnpjFieldWithValidation extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool)? onValidationChanged; // Callback quando validação muda

  const CnpjFieldWithValidation({
    super.key,
    required this.controller,
    this.onValidationChanged,
  });

  @override
  State<CnpjFieldWithValidation> createState() => _CnpjFieldWithValidationState();
}

class _CnpjFieldWithValidationState extends State<CnpjFieldWithValidation> {
  Timer? _debounceTimer;
  String? _lastValidatedCnpj;
  DocumentValidationStatus? _validationStatus;
  String? _errorMessage;

  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCnpjChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onCnpjChanged);
    super.dispose();
  }

  void _onCnpjChanged() {
    // Se está carregando, não fazer nada (aguardar resultado)
    if (_validationStatus == DocumentValidationStatus.loading) return;

    // Sempre resetar estado quando o usuário edita (para permitir nova validação)
    final currentCnpj = widget.controller.text.replaceAll(RegExp(r'[^\d]'), '');
    if (currentCnpj != _lastValidatedCnpj) {
      // CNPJ mudou, resetar estado de validação completamente
      setState(() {
        _validationStatus = null;
        _errorMessage = null;
        _lastValidatedCnpj = null; // Resetar para forçar nova validação
      });
      // Resetar validação no parent
      widget.onValidationChanged?.call(true);
    }

    _debounceTimer?.cancel();
    // Debounce de 1.5 segundos
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      final cnpj = widget.controller.text.replaceAll(RegExp(r'[^\d]'), '');

      // Se CNPJ está vazio, reset status
      if (cnpj.isEmpty) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
          _lastValidatedCnpj = null;
        });
        widget.onValidationChanged?.call(true); // Válido porque ainda não validou
        return;
      }

      // Verificar se CNPJ tem 14 dígitos
      if (cnpj.length != 14) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
          _lastValidatedCnpj = null;
        });
        widget.onValidationChanged?.call(true); // Válido porque ainda não validou
        return;
      }

      // Verificar se CNPJ é válido (formato)
      if (!CNPJValidator.isValid(widget.controller.text)) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
          _lastValidatedCnpj = null;
        });
        widget.onValidationChanged?.call(true); // Válido porque ainda não validou
        return;
      }

      // CNPJ válido - sempre validar se for diferente do último validado
      if (cnpj != _lastValidatedCnpj) {
        _validateCnpj(cnpj);
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
          widget.onValidationChanged?.call(!state.exists);
        } else if (state is DocumentValidationFailure && state.document == _lastValidatedCnpj) {
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
              label: 'CNPJ',
              controller: widget.controller,
              validator: Validators.validateCNPJ,
              inputFormatters: [_cnpjMask],
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Reset status quando usuário edita - isso já é feito no _onCnpjChanged
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

