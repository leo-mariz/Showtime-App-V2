import 'dart:async';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:flutter/material.dart';

/// Modal para editar nome artístico
class ArtistNameEditModal extends StatefulWidget {
  final String? currentName;
  final Future<bool> Function(String) onCheckName;
  final Future<void> Function(String) onSave;

  const ArtistNameEditModal({
    super.key,
    this.currentName,
    required this.onCheckName,
    required this.onSave,
  });

  /// Exibe o modal de edição de nome artístico
  static Future<void> show({
    required BuildContext context,
    String? currentName,
    required Future<bool> Function(String) onCheckName,
    required Future<void> Function(String) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArtistNameEditModal(
        currentName: currentName,
        onCheckName: onCheckName,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ArtistNameEditModal> createState() => _ArtistNameEditModalState();
}

class _ArtistNameEditModalState extends State<ArtistNameEditModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Timer? _debounceTimer;
  String? _lastValidatedName;
  bool _isChecking = false;
  bool _isSaving = false;
  bool _isNameVerified = false;
  String? _verificationMessage;
  bool _isNameAvailable = false;

  @override
  void initState() {
    super.initState();
    final initialName = widget.currentName ?? '';
    _nameController.text = initialName;
    if (initialName.isNotEmpty) {
      _lastValidatedName = initialName;
      _isNameVerified = true;
      _isNameAvailable = true;
      _verificationMessage = 'Este é seu nome atual';
    }
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    // Se está carregando, não fazer nada (aguardar resultado)
    if (_isChecking) return;

    // Sempre resetar estado quando o usuário edita
    final currentName = _nameController.text.trim();
    if (currentName != _lastValidatedName) {
      setState(() {
        _isNameVerified = false;
        _isNameAvailable = false;
        _verificationMessage = null;
        _lastValidatedName = null;
      });
    }

    _debounceTimer?.cancel();
    // Debounce de 1.5 segundos
    _debounceTimer = Timer(const Duration(milliseconds: 1300), () {
      final name = _nameController.text.trim();

      // Se nome está vazio, reset status
      if (name.isEmpty) {
        setState(() {
          _isNameVerified = false;
          _isNameAvailable = false;
          _verificationMessage = null;
          _lastValidatedName = null;
        });
        return;
      }

      // Se nome é igual ao atual, considerar válido
      if (name == widget.currentName) {
        setState(() {
          _verificationMessage = 'Este é seu nome atual';
          _isNameVerified = true;
          _isNameAvailable = true;
          _lastValidatedName = name;
        });
        return;
      }

      // Nome válido - sempre validar se for diferente do último validado
      if (name != _lastValidatedName) {
        _checkName(name);
      }
    });
  }

  Future<void> _checkName(String name) async {
    setState(() {
      _isChecking = true;
      _verificationMessage = null;
      _isNameVerified = false;
      _isNameAvailable = false;
      _lastValidatedName = name;
    });

    try {
      final nameExists = await widget.onCheckName(name);
      
      setState(() {
        _isChecking = false;
        _isNameVerified = true;
        _isNameAvailable = !nameExists;
        _verificationMessage = nameExists
            ? 'Este nome artístico já está em uso'
            : 'Nome disponível!';
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
        _isNameVerified = false;
        _isNameAvailable = false;
        _verificationMessage = 'Erro ao verificar nome. Tente novamente.';
        _lastValidatedName = null;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isNameVerified || !_isNameAvailable) {
      return;
    }

    final name = _nameController.text.trim();
    
    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(name);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  bool _hasNameChanged() {
    final currentName = _nameController.text.trim();
    final originalName = widget.currentName ?? '';
    return currentName != originalName;
  }

  Widget _buildValidationIndicator(ColorScheme colorScheme) {
    if (_isChecking) {
      return SizedBox(
        width: DSSize.width(20),
        height: DSSize.height(20),
        child: CustomLoadingIndicator(
          strokeWidth: 2,
          color: colorScheme.onPrimaryContainer,
        ),
      );
    }

    if (!_isNameVerified) {
      return const SizedBox.shrink();
    }

    if (_isNameAvailable) {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
        size: DSSize.width(20),
      );
    }

    return Tooltip(
      message: _verificationMessage ?? 'Este nome já está em uso',
      child: Icon(
        Icons.cancel,
        color: colorScheme.onError,
        size: DSSize.width(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSSize.width(20))),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: EdgeInsets.only(top: DSSize.height(12), bottom: DSSize.height(8)),
              child: Container(
                width: DSSize.width(40),
                height: DSSize.height(4),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(DSSize.width(2)),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar nome artístico',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            DSSizedBoxSpacing.vertical(16),

            // Campo de texto com indicador ao lado
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _nameController,
                      label: 'Nome artístico',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome artístico não pode ser vazio';
                        }
                        return null;
                      },
                    ),
                  ),
                  DSSizedBoxSpacing.horizontal(8),
                  Padding(
                    padding: EdgeInsets.only(top: DSSize.height(24)),
                    child: _buildValidationIndicator(colorScheme),
                  ),
                ],
              ),
            ),

            DSSizedBoxSpacing.vertical(8),

            // Mensagem de verificação
            if (_verificationMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                child: Text(
                  _verificationMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _isNameVerified && _isNameAvailable
                        ? Colors.green
                        : _isNameVerified && !_isNameAvailable
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            DSSizedBoxSpacing.vertical(32),

            // Botão Salvar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: _isSaving ? 'Salvando...' : 'Salvar',
                  onPressed: (_isSaving || !_hasNameChanged() || !_isNameVerified || !_isNameAvailable)
                      ? null
                      : _save,
                ),
              ),
            ),

            DSSizedBoxSpacing.vertical(16),
          ],
        ),
      ),
    );
  }
}

