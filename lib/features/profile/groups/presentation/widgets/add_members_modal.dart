import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/material.dart';

/// Modal para adicionar membros ao grupo
class AddMembersModal extends StatefulWidget {
  final Function(List<String> emails) onSendInvites;
  final Function()? onSkip;

  const AddMembersModal({
    super.key,
    required this.onSendInvites,
    this.onSkip,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(List<String> emails) onSendInvites,
    Function()? onSkip,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMembersModal(
        onSendInvites: onSendInvites,
        onSkip: onSkip,
      ),
    );
  }

  @override
  State<AddMembersModal> createState() => _AddMembersModalState();
}

class _AddMembersModalState extends State<AddMembersModal> {
  final _emailController = TextEditingController();
  final List<String> _addedEmails = [];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _addEmail() {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      context.showError('Digite um email');
      return;
    }

    final emailValidation = Validators.validateEmail(email);
    if (emailValidation != null) {
      context.showError(emailValidation);
      return;
    }

    if (_addedEmails.contains(email)) {
      context.showError('Este email já foi adicionado');
      return;
    }

    setState(() {
      _addedEmails.add(email);
      _emailController.clear();
    });
  }

  void _removeEmail(String email) {
    setState(() {
      _addedEmails.remove(email);
    });
  }

  void _onSendInvites() {
    if (_addedEmails.isEmpty) {
      context.showError('Adicione pelo menos um email');
      return;
    }

    widget.onSendInvites(_addedEmails);
    if (mounted) {
      Navigator.of(context).pop();
      context.showSuccess('${_addedEmails.length} convite${_addedEmails.length > 1 ? 's' : ''} enviado${_addedEmails.length > 1 ? 's' : ''}!');
    }
  }

  void _onSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSSize.width(20))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adicionar Membros',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: colorScheme.onPrimary,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: DSSize.width(16),
                right: DSSize.width(16),
                top: DSSize.height(16),
                bottom: bottomPadding + DSSize.height(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adicione os emails dos artistas que deseja convidar para o grupo.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(24),
                  
                  // Campo de email
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _emailController,
                          label: 'Email do artista',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      DSSizedBoxSpacing.horizontal(8),
                      SizedBox(
                        height: DSSize.height(48),
                        child: CustomButton(
                          label: 'Adicionar',
                          width: DSSize.width(100),
                          height: DSSize.height(48),
                          onPressed: _addEmail,
                        ),
                      ),
                    ],
                  ),
                  
                  if (_addedEmails.isNotEmpty) ...[
                    DSSizedBoxSpacing.vertical(24),
                    Text(
                      'Emails adicionados:',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(12),
                    Wrap(
                      spacing: DSSize.width(8),
                      runSpacing: DSSize.height(8),
                      children: _addedEmails.map((email) {
                        return Chip(
                          label: Text(
                            email,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          deleteIcon: Icon(
                            Icons.close,
                            size: DSSize.width(16),
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onDeleted: () => _removeEmail(email),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Actions
          Container(
            padding: EdgeInsets.only(
              left: DSSize.width(16),
              right: DSSize.width(16),
              top: DSSize.height(16),
              bottom: bottomPadding > 0 ? bottomPadding + DSSize.height(16) : DSSize.height(16),
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: DSSize.width(10),
                  offset: Offset(0, -DSSize.height(2)),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  CustomButton(
                    label: 'Enviar Convites',
                    onPressed: _addedEmails.isNotEmpty ? _onSendInvites : null,
                  ),
                  if (widget.onSkip != null) ...[
                    DSSizedBoxSpacing.vertical(12),
                    CustomButton(
                      label: 'Pular',
                      buttonType: CustomButtonType.cancel,
                      onPressed: _onSkip,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
