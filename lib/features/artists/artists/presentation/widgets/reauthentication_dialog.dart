import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Modal para reautenticação com senha
/// 
/// Usado quando biometria falhou ou não está disponível.
/// Segue Clean Architecture: usa apenas AuthBloc.
class ReauthenticationModal extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;

  const ReauthenticationModal({
    super.key,
    required this.onSuccess,
    this.onCancel,
  });

  /// Método estático para exibir o modal de reautenticação
  static Future<bool> show({
    required BuildContext context,
  }) async {
    bool? result;
    
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (dialogContext) => ReauthenticationModal(
        onSuccess: () {
          result = true;
          Navigator.of(dialogContext).pop(true);
        },
        onCancel: () {
          result = false;
          Navigator.of(dialogContext).pop(false);
        },
      ),
    );

    return result ?? false;
  }

  @override
  State<ReauthenticationModal> createState() => _ReauthenticationModalState();
}

class _ReauthenticationModalState extends State<ReauthenticationModal> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  void _authenticateWithPassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Disparar evento com senha
    context.read<AuthBloc>().add(
      ReauthenticateUserEvent(password: _passwordController.text),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surfaceContainerHighest = colorScheme.surfaceContainerHighest;
    final onPrimary = colorScheme.onPrimary;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Reautenticação bem-sucedida
        if (state is ReauthenticateUserSuccess) {
          widget.onSuccess();
        }

        // Reautenticação com senha falhou
        if (state is ReauthenticateUserPasswordFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is ReauthenticateUserLoading;

          return Container(
            decoration: BoxDecoration(
              color: surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(DSSize.width(20)),
                topRight: Radius.circular(DSSize.width(20)),
              ),
            ),
            padding: EdgeInsets.only(
              left: DSSize.width(16),
              right: DSSize.width(16),
              top: DSSize.height(16),
              bottom: MediaQuery.of(context).viewInsets.bottom + DSSize.height(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: DSSize.width(40),
                    height: DSSize.height(4),
                    margin: EdgeInsets.only(bottom: DSSize.height(16)),
                    decoration: BoxDecoration(
                      color: onPrimary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(DSSize.width(2)),
                    ),
                  ),
                ),
                // Título
                Text(
                  'Reautenticação Necessária',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                DSSizedBoxSpacing.vertical(8),
                // Descrição
                Text(
                  'Por segurança, é necessário reautenticar para acessar seus dados bancários.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: onPrimary.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                DSSizedBoxSpacing.vertical(24),
                // Formulário
                Form(
                  key: _formKey,
                  child: CustomTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    obscureText: true,
                    validator: Validators.validateIsNull,
                    enabled: !isLoading,
                  ),
                ),
                DSSizedBoxSpacing.vertical(24),
                // Botões
                CustomButton(
                  label: 'Confirmar',
                  backgroundColor: colorScheme.onPrimaryContainer,
                  textColor: colorScheme.primaryContainer,
                  onPressed: isLoading ? null : _authenticateWithPassword,
                  isLoading: isLoading,
                ),
                DSSizedBoxSpacing.vertical(12),
                CustomButton(
                  label: 'Cancelar',
                  filled: false,
                  textColor: onPrimary,
                  onPressed: isLoading
                      ? null
                      : () {
                          widget.onCancel?.call();
                          Navigator.of(context).pop(false);
                        },
                ),
                DSSizedBoxSpacing.vertical(8),
              ],
            ),
          );
        },
      ),
    );
  }
}
