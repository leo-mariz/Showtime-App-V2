import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/authentication/presentation/widgets/auth_base_page.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/validators/input_validator.dart';

@RoutePage(deferredLoading: true)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    // Validar formulário
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    
    // Enviar evento para o bloc
    context.read<AuthBloc>().add(SendForgotPasswordEmailEvent(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          context.showSuccess(state.message);
          // Opcional: Navegar de volta para login após sucesso
          // context.router.pop();
        } else if (state is ForgotPasswordFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is ForgotPasswordLoading;

    return AuthBasePage(
      title: 'ESQUECI MINHA SENHA',
      subtitle: 'Redefina sua senha',
      children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        // Campo de Email
        CustomTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      enabled: !isLoading,
                      onChanged: (value) {},
        ),

        DSSizedBoxSpacing.vertical(16),

        Text(
          'Um link para redefinir sua senha será enviado para seu endereço de email',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
        ),
        
        DSSizedBoxSpacing.vertical(24),
        
                    // Botão de Enviar
                    IgnorePointer(
                      ignoring: isLoading,
                      child: Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: CustomButton(
                          label: isLoading
                              ? 'Enviando...'
                              : 'Enviar link de redefinição',
          filled: true,
                          onPressed: isLoading ? null : _handleForgotPassword,
        ),        
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

