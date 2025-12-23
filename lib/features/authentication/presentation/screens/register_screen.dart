import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/shared/widgets/link_text.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/features/authentication/presentation/widgets/auth_base_page.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validações
    if (email.isEmpty) {
      context.showError('Por favor, informe seu email');
      return;
    }

    if (password.isEmpty) {
      context.showError('Por favor, informe sua senha');
      return;
    }

    if (password.length < 6) {
      context.showError('A senha deve ter no mínimo 6 caracteres');
      return;
    }

    if (confirmPassword.isEmpty) {
      context.showError('Por favor, confirme sua senha');
      return;
    }

    if (password != confirmPassword) {
      context.showError('As senhas não coincidem');
      return;
    }

    // Validar formato de email básico
    if (!email.contains('@') || !email.contains('.')) {
      context.showError('Por favor, informe um email válido');
      return;
    }

    // Criar UserEntity com os dados do formulário
    final user = UserEntity(
      email: email,
      password: password,
    );

    // Disparar evento de registro
    context.read<AuthBloc>().add(RegisterUserEmailAndPasswordEvent(user: user));
  }

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is RegisterLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthInitial) {
          setState(() {
            _isLoading = false;
          });
        }
        if (state is AuthSuccess) {
          // Resetar loading antes de navegar
          setState(() {
            _isLoading = false;
          });
          // Mostrar mensagem de sucesso
          context.showSuccess(state.message);
          // Navegar para tela de verificação de email
          router.push(EmailVerificationRoute(email: _emailController.text.trim()));
        } else if (state is AuthFailure) {
          setState(() {
            _isLoading = false;
          });
          context.showError(state.error);
        } else if (state is AuthConnectionFailure) {
          setState(() {
            _isLoading = false;
          });
          context.showError(state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {

          return AuthBasePage(
            title: 'CADASTRO',
            subtitle: 'Crie sua conta',
            children: [
              // Campo de Email
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                onChanged: (value) {},
              ),
              
              DSSizedBoxSpacing.vertical(4),
              
              // Campo de Senha
              CustomTextField(
                label: 'Senha',
                obscureText: true,
                isPassword: true,
                keyboardType: TextInputType.text,
                controller: _passwordController,
                enabled: !_isLoading,
                onChanged: (value) {},
              ),

              DSSizedBoxSpacing.vertical(4),
              
              // Campo de Confirmar Senha
              CustomTextField(
                label: 'Confirmar Senha',
                obscureText: true,
                isPassword: true,
                keyboardType: TextInputType.text,
                controller: _confirmPasswordController,
                enabled: !_isLoading,
                onChanged: (value) {},
              ),
              
              DSSizedBoxSpacing.vertical(24),
              
              // Botão de Cadastrar
              CustomButton(
                key: ValueKey('register_screen_button'),
                label: _isLoading ? 'Cadastrando...' : 'Cadastrar',
                filled: true,
                onPressed: _isLoading ? null : _handleRegister,
              ),
              
              DSSizedBoxSpacing.vertical(190),
              
              // Link "Já tenho uma conta"
              IgnorePointer(
                ignoring: _isLoading,
                child: Opacity(
                  opacity: _isLoading ? 0.5 : 1.0,
                  child: Center(
                    child: CustomLinkText(
                      text: 'Já possui uma conta? Faça login',
                      textColor: onPrimaryContainer,
                      onTap: () {
                        router.push(const LoginRoute());
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

