import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
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
  bool _isChecking = false;
  bool _isSaving = false;
  bool _isNameVerified = false;
  String? _verificationMessage;
  bool _isNameAvailable = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkName() async {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      setState(() {
        _verificationMessage = 'Digite um nome artístico';
        _isNameVerified = false;
        _isNameAvailable = false;
      });
      return;
    }

    if (name == widget.currentName) {
      setState(() {
        _verificationMessage = 'Este é seu nome atual';
        _isNameVerified = true;
        _isNameAvailable = true;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _verificationMessage = null;
      _isNameVerified = false;
      _isNameAvailable = false;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

            // Campo de texto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomTextField(
                controller: _nameController,
                label: 'Nome artístico',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome artístico não pode ser vazio';
                  }
                  return null;
                },
                onChanged: (_) {
                  setState(() {
                    _isNameVerified = false;
                    _isNameAvailable = false;
                    _verificationMessage = null;
                  });
                },
              ),
            ),

            DSSizedBoxSpacing.vertical(16),

            // Mensagem de verificação
            if (_verificationMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      _isNameVerified && _isNameAvailable
                          ? Icons.check_circle
                          : _isNameVerified && !_isNameAvailable
                              ? Icons.error
                              : Icons.info_outline,
                      color: _isNameVerified && _isNameAvailable
                          ? Colors.green
                          : _isNameVerified && !_isNameAvailable
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                    Expanded(
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
                  ],
                ),
              ),

            DSSizedBoxSpacing.vertical(16),

            // Botões
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Botão Verificar
                  Expanded(
                    child: CustomButton(
                      label: _isChecking ? 'Verificando...' : 'Verificar',
                      onPressed: _isChecking ? null : _checkName,
                      filled: false,
                    ),
                  ),
                  DSSizedBoxSpacing.horizontal(12),
                  // Botão Salvar
                  Expanded(
                    child: CustomButton(
                      label: _isSaving ? 'Salvando...' : 'Salvar',
                      onPressed: (_isSaving || !_isNameVerified || !_isNameAvailable)
                          ? null
                          : _save,
                    ),
                  ),
                ],
              ),
            ),

            DSSizedBoxSpacing.vertical(16),
          ],
        ),
      ),
    );
  }
}

