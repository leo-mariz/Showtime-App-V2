import 'dart:async';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/document_validation_indicator.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/artists/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/artists/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/artists/artists/presentation/bloc/states/artists_states.dart';

/// Campo de nome artístico com validação em tempo real
class ArtistNameField extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool) onValidationChanged; // Callback quando validação muda

  const ArtistNameField({
    super.key,
    required this.controller,
    required this.onValidationChanged,
  });

  @override
  State<ArtistNameField> createState() => _ArtistNameFieldState();
}

class _ArtistNameFieldState extends State<ArtistNameField> {
  Timer? _debounceTimer;
  String? _lastValidatedName;
  DocumentValidationStatus? _validationStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onNameChanged);
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
    // Debounce de 2 segundos
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      final name = widget.controller.text.trim();

      // Se nome está vazio, reset status (campo é opcional)
      if (name.isEmpty) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
        });
        widget.onValidationChanged(true); // Válido porque é opcional
        return;
      }

      // Verificar se nome tem pelo menos 2 caracteres
      if (name.length < 2) {
        setState(() {
          _validationStatus = null;
          _errorMessage = null;
        });
        widget.onValidationChanged(true); // Válido porque é opcional
        return;
      }

      // Nome válido - buscar no banco se for diferente do último validado
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

    context.read<ArtistsBloc>().add(CheckArtistNameExistsEvent(artistName: name));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ArtistsBloc, ArtistsState>(
      listener: (context, state) {
        if (state is CheckArtistNameExistsSuccess && state.artistName == _lastValidatedName) {
          setState(() {
            _validationStatus = state.exists
                ? DocumentValidationStatus.exists
                : DocumentValidationStatus.available;
            _errorMessage = state.exists ? 'Este Nome Artístico já está em uso' : null;
          });
          widget.onValidationChanged(!state.exists);
        } else if (state is CheckArtistNameExistsFailure && state.artistName == _lastValidatedName) {
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
              label: 'Nome Artístico (opcional)',
              controller: widget.controller,
              onChanged: (value) {
                // Reset status quando usuário edita
                if (_validationStatus != null) {
                  setState(() {
                    _validationStatus = null;
                    _errorMessage = null;
                    _lastValidatedName = null;
                  });
                  widget.onValidationChanged(true); // Válido porque é opcional
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

