import 'dart:async';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/document_validation_indicator.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Campo de nome do conjunto com validação em tempo real (verifica se o nome já existe).
/// [considerEmptyAsValid]: quando false (padrão), reporta válido apenas após
/// verificação retornar "disponível". Quando true, nome vazio reporta válido.
class EnsembleNameField extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool) onValidationChanged;
  final String? excludeEnsembleId;
  final bool considerEmptyAsValid;

  const EnsembleNameField({
    super.key,
    required this.controller,
    required this.onValidationChanged,
    this.excludeEnsembleId,
    this.considerEmptyAsValid = false,
  });

  @override
  State<EnsembleNameField> createState() => _EnsembleNameFieldState();
}

class _EnsembleNameFieldState extends State<EnsembleNameField> {
  Timer? _debounceTimer;
  String? _lastValidatedName;
  DocumentValidationStatus? _validationStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onNameChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final name = widget.controller.text.trim();
      if (name.length >= 2 && name != _lastValidatedName) {
        _validateName(name);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onNameChanged);
    super.dispose();
  }

  void _onNameChanged() {
    if (_validationStatus == DocumentValidationStatus.loading) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      final name = widget.controller.text.trim();

      if (name.isEmpty) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
        });
        widget.onValidationChanged(widget.considerEmptyAsValid);
        return;
      }

      if (name.length < 2) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
        });
        widget.onValidationChanged(widget.considerEmptyAsValid);
        return;
      }

      if (name != _lastValidatedName) {
        _validateName(name);
      }
    });
  }

  void _validateName(String name) {
    setState(() {
      _validationStatus = DocumentValidationStatus.loading;
      _lastValidatedName = name;
    });

    context.read<EnsembleBloc>().add(CheckEnsembleNameExistsEvent(
          ensembleName: name,
          excludeEnsembleId: widget.excludeEnsembleId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnsembleBloc, EnsembleState>(
      listener: (context, state) {
        if (state is CheckEnsembleNameExistsSuccess &&
            state.ensembleName == _lastValidatedName) {
          setState(() {
            _validationStatus = state.exists
                ? DocumentValidationStatus.exists
                : DocumentValidationStatus.available;
            _errorMessage =
                state.exists ? 'Este nome de conjunto já está em uso' : null;
          });
          widget.onValidationChanged(!state.exists);
        } else if (state is CheckEnsembleNameExistsFailure &&
            state.ensembleName == _lastValidatedName) {
          setState(() {
            _validationStatus = DocumentValidationStatus.error;
            _errorMessage = state.error;
          });
          widget.onValidationChanged(false);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomTextField(
              label: 'Nome do conjunto (opcional)',
              controller: widget.controller,
              onChanged: (value) {
                if (_validationStatus != null) {
                  setState(() {
                    _validationStatus = null;
                    _errorMessage = null;
                    _lastValidatedName = null;
                  });
                  widget.onValidationChanged(false);
                }
              },
            ),
          ),
          DSSizedBoxSpacing.horizontal(8),
          Padding(
            padding: EdgeInsets.only(top: DSSize.height(24)),
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
