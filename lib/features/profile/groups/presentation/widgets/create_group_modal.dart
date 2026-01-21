import 'dart:io';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/services/image_picker_service.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/material.dart';

/// Modal para criar novo grupo
class CreateGroupModal extends StatefulWidget {
  final Function(GroupEntity, File?, List<String>) onCreate;

  const CreateGroupModal({
    super.key,
    required this.onCreate,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(GroupEntity, File?, List<String>) onCreate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateGroupModal(onCreate: onCreate),
    );
  }

  @override
  State<CreateGroupModal> createState() => _CreateGroupModalState();
}

class _CreateGroupModalState extends State<CreateGroupModal> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _imagePickerService = ImagePickerService();
  final List<TextEditingController> _emailControllers = [];
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Inicia com um campo de email vazio
    _emailControllers.add(TextEditingController());
    _groupNameController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
  }

  Future<void> _pickImage() async {
    final file = await _imagePickerService.pickImageFromGallery();
    if (file != null && mounted) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _addEmailField() {
    setState(() {
      _emailControllers.add(TextEditingController());
    });
  }

  void _removeEmailField(int index) {
    if (_emailControllers.length > 1) {
      setState(() {
        _emailControllers[index].dispose();
        _emailControllers.removeAt(index);
      });
    }
  }

  void _onCreate() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Coletar emails válidos
    final emails = <String>[];
    for (var controller in _emailControllers) {
      final email = controller.text.trim();
      if (email.isNotEmpty) {
        final emailValidation = Validators.validateEmail(email);
        if (emailValidation == null) {
          emails.add(email);
        } else {
          context.showError('Email inválido: $email');
          return;
        }
      }
    }

    final group = GroupEntity(
      groupName: _groupNameController.text.trim(),
      dateRegistered: DateTime.now(),
      isActive: false,
      members: [],
      invitationEmails: emails.isNotEmpty ? emails : null,
    );

    widget.onCreate(group, _selectedImage, emails);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  bool get _isFormValid {
    return _groupNameController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSSize.width(20))),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
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
                    'Novo Grupo',
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
                    // Foto de perfil e Nome do Grupo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto de perfil (CircleAvatar)
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: DSSize.width(40),
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : null,
                            child: _selectedImage == null
                                ? Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: colorScheme.onPrimaryContainer,
                                    size: DSSize.width(32),
                                  )
                                : null,
                          ),
                        ),
                        DSSizedBoxSpacing.horizontal(16),
                        // Nome do Grupo
                        Expanded(
                          child: CustomTextField(
                            controller: _groupNameController,
                            label: 'Nome do Grupo',
                            validator: Validators.validateIsNull,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedImage != null) ...[
                      DSSizedBoxSpacing.vertical(8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _removeImage,
                          icon: Icon(
                            Icons.close,
                            size: DSSize.width(16),
                            color: colorScheme.error,
                          ),
                          label: Text(
                            'Remover foto',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: DSSize.width(8),
                              vertical: DSSize.height(4),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                    DSSizedBoxSpacing.vertical(24),
                    
                    // Integrantes
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: DSSize.width(20),
                          color: colorScheme.onPrimary,
                        ),
                        DSSizedBoxSpacing.horizontal(8),
                        Text(
                          'Integrantes',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    DSSizedBoxSpacing.vertical(12),
                    
                    // Lista de campos de email
                    ...List.generate(_emailControllers.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: DSSize.height(12)),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _emailControllers[index],
                                label: 'Email do integrante',
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            if (_emailControllers.length > 1) ...[
                              DSSizedBoxSpacing.horizontal(8),
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: colorScheme.error,
                                  size: DSSize.width(24),
                                ),
                                onPressed: () => _removeEmailField(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    
                    // Botão para adicionar mais campos
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addEmailField,
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: DSSize.width(20),
                          color: colorScheme.onPrimaryContainer,
                        ),
                        label: Text(
                          'Adicionar integrante',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: DSSize.width(8),
                            vertical: DSSize.height(4),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    Text(
                      'Você pode adicionar foto e integrantes posteriormente.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
                child: CustomButton(
                  label: 'Criar Grupo',
                  onPressed: _isFormValid ? _onCreate : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}