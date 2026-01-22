import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/password_field.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;


  void _onDeleteShowDialog() async {
    // Segunda confirmação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmação Final', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onError)),
        content: Text(
          'Tem certeza que deseja excluir sua conta? Esta ação é irreversível.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir Conta', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    
    setState(() {
      isLoading = true;
    });

    // Mock: Simula exclusão
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
      context.showSuccess('Conta excluída com sucesso!');
      // TODO: Navegar para tela inicial quando implementar
      // AutoRouter.of(context).pushAndClearStack(const InitialRoute());
    });
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = confirmTextController.text.trim().toLowerCase() == 'excluir';
    
    return BasePage(
      showAppBar: true,
      appBarTitle: 'Excluir Conta',
      showAppBarBackButton: true,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSSizedBoxSpacing.vertical(4),
              Text(
                'Para excluir sua conta permanentemente, digite sua senha e escreva "excluir" no campo de confirmação.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              DSSizedBoxSpacing.vertical(24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Senha',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              DSSizedBoxSpacing.vertical(6),
              CustomPasswordField(
                controller: passwordController,
                hintText: 'Digite sua senha',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite sua senha' : null,
              ),
              DSSizedBoxSpacing.vertical(16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirmação',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              DSSizedBoxSpacing.vertical(6),
              CustomTextField(
                controller: confirmTextController,
                label: 'Digite "excluir" para confirmar',
                onChanged: (value) {
                  setState(() {}); // Atualiza o estado para habilitar/desabilitar botão
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite "excluir" para confirmar';
                  }
                  if (value.trim().toLowerCase() != 'excluir') {
                    return 'Você deve digitar exatamente "excluir"';
                  }
                  return null;
                },
              ),
              DSSizedBoxSpacing.vertical(40),
              CustomButton(
                backgroundColor: Theme.of(context).colorScheme.onError,
                textColor: Theme.of(context).colorScheme.error,
                iconOnLeft: true,
                icon: Icons.delete,
                iconColor: Theme.of(context).colorScheme.error,
                onPressed: (isLoading || !canDelete)
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _onDeleteShowDialog();
                        }
                      },
                label: 'Excluir Conta',
              ),
            ],
          ),
        ),
      ),
    );
  }
}