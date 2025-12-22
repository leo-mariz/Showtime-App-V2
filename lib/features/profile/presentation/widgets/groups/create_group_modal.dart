import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/material.dart';

/// Modal para criar novo grupo
class CreateGroupModal extends StatefulWidget {
  final Function(GroupEntity) onCreate;

  const CreateGroupModal({
    super.key,
    required this.onCreate,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(GroupEntity) onCreate,
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

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final group = GroupEntity(
      groupName: _groupNameController.text.trim(),
      dateRegistered: DateTime.now(),
      isActive: true,
      members: [],
    );

    widget.onCreate(group);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grupo criado com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: bottomPadding + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Digite o nome do grupo que deseja criar.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(24),
                    CustomTextField(
                      controller: _groupNameController,
                      label: 'Nome do Grupo',
                      validator: Validators.validateIsNull,
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: bottomPadding > 0 ? bottomPadding + 16 : 16,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  label: 'Criar Grupo',
                  onPressed: _onCreate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

