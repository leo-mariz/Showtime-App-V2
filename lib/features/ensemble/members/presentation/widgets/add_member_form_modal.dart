import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Modal para preencher nome, email e CPF do integrante ao adicionar.
/// Retorna [EnsembleMemberEntity] ao confirmar "Adicionar", ou null ao cancelar.
class AddMemberFormModal extends StatefulWidget {
  const AddMemberFormModal({super.key});

  /// Exibe o modal. Retorna o integrante criado ao confirmar, ou null ao cancelar.
  static Future<EnsembleMemberEntity?> show({required BuildContext context}) {
    return showModalBottomSheet<EnsembleMemberEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMemberFormModal(),
    );
  }

  @override
  State<AddMemberFormModal> createState() => _AddMemberFormModalState();
}

class _AddMemberFormModalState extends State<AddMemberFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();

  static final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  void _onAdd() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final cpf = _cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
    final member = EnsembleMemberEntity(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      ensembleId: '',
      isOwner: false,
      name: name.isEmpty ? null : name,
      cpf: cpf.isEmpty ? null : cpf,
      email: email.isEmpty ? null : email,
      isApproved: false,
    );
    Navigator.of(context).pop(member);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DSSize.width(20)),
              topRight: Radius.circular(DSSize.width(20)),
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: DSSize.width(16),
                right: DSSize.width(16),
                bottom: MediaQuery.of(context).viewInsets.bottom + DSSize.height(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DSSizedBoxSpacing.vertical(8),
                  Center(
                    child: Container(
                      width: DSSize.width(40),
                      height: DSSize.height(4),
                      margin: EdgeInsets.only(bottom: DSSize.height(16)),
                      decoration: BoxDecoration(
                        color: onPrimary.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(DSSize.width(2)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: DSSize.width(4)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adicionar integrante',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onPrimary,
                              ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: onPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  Text(
                    'Preencha os dados do integrante que fará parte do conjunto. Lembre-se que, para cada novo integrante, precisaremos do envio de documentos do mesmo, a serem realizados em uma etapa posterior.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: onPrimary.withOpacity(0.8),
                        ),
                  ),
                  DSSizedBoxSpacing.vertical(16),
                  CustomTextField(
                    label: 'Nome',
                    controller: _nameController,
                    validator: Validators.validateIsNull,
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  CustomTextField(
                    label: 'CPF',
                    controller: _cpfController,
                    validator: Validators.validateCPF,
                    inputFormatters: [_cpfMask],
                    keyboardType: TextInputType.number,
                  ),
                  DSSizedBoxSpacing.vertical(24),
                  CustomButton(
                    label: 'Adicionar',
                    onPressed: _onAdd,
                    icon: Icons.person_add,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
