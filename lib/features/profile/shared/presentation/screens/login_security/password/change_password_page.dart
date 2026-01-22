import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void _clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void _onChangePassword() {
    if (newPasswordController.text.length < 6) {
      context.showError('A nova senha deve ter pelo menos 6 caracteres');
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      context.showError('As senhas não coincidem');
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(newPasswordController.text) || !RegExp(r'[0-9]').hasMatch(newPasswordController.text)) {
      context.showError('A senha deve conter letras e números');
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Mock: Simula alteração de senha
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
      _clearFields();
      context.showSuccess('Senha alterada com sucesso!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      appBarTitle: 'Alterar Senha',
      showAppBarBackButton: true,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSSizedBoxSpacing.vertical(4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Senha Atual',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              DSSizedBoxSpacing.vertical(6),
              CustomPasswordField(
                controller: currentPasswordController,
                hintText: 'Digite sua senha atual',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite sua senha atual' : null,
              ),
              DSSizedBoxSpacing.vertical(16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nova Senha',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              DSSizedBoxSpacing.vertical(6),
              CustomPasswordField(
                controller: newPasswordController,
                hintText: 'Digite a nova senha',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite a nova senha' : null,
              ),
              DSSizedBoxSpacing.vertical(16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirmar Nova Senha',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              DSSizedBoxSpacing.vertical(6),
              CustomPasswordField(
                controller: confirmPasswordController,
                hintText: 'Digite a nova senha novamente',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme a nova senha';
                  }
                  if (value != newPasswordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              DSSizedBoxSpacing.vertical(40),
              CustomButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _onChangePassword();
                        }
                      },
                label: 'Alterar Senha',
                backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                textColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}