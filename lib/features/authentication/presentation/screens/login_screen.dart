import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:app/core/enums/user_type.dart';
import 'package:app/core/shared/widgets/link_text.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/features/authentication/presentation/widgets/auth_base_page.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/features/authentication/presentation/widgets/user_type_selector.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/authentication/presentation/widgets/biometrics_prompt_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  UserType _selectedUserType = UserType.artist;
  bool _waitingForBiometricsCheck = false;
  UserEntity? _pendingUser;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validação básica
    if (email.isEmpty) {
      _showErrorMessage('Por favor, informe seu email');
      return;
    }

    if (password.isEmpty) {
      _showErrorMessage('Por favor, informe sua senha');
      return;
    }

    // Criar UserEntity com os dados do formulário
    final user = UserEntity(
      email: email,
      password: password,
      isArtist: _selectedUserType == UserType.artist,
    );

    // Disparar evento de login
    context.read<AuthBloc>().add(LoginUserEvent(user: user));
  }

  void _showErrorMessage(String message) {
    context.showError(message);
  }

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthInitial) {
          setState(() {
            _isLoading = false;
          });
        }
        
        if (state is LoginSuccess) {
          // Resetar loading e aguardar verificação de biometria antes de navegar
            _waitingForBiometricsCheck = true;
            _pendingUser = state.user;
          // Mostrar mensagem de sucesso
          context.showSuccess('Login realizado com sucesso!');
        } else if (state is CheckShouldShowBiometricsPromptSuccess) {
          // Mostrar modal de biometria se necessário
          if (state.shouldShow && state.user != null) {
            // Mostrar modal e aguardar seu fechamento antes de navegar
            BiometricsPromptDialog.show(
              context: context,
              user: state.user!,
            ).then((_) {
              // Modal foi fechado, agora navegar (se estava aguardando)
              if (_waitingForBiometricsCheck && _pendingUser != null) {
                final isArtist = _pendingUser!.isArtist ?? false;
                router.replaceAll([NavigationRoute(isArtist: isArtist)]);
                setState(() {
                  _waitingForBiometricsCheck = false;
                  _pendingUser = null;
                });
              }
            });
          } else {
            // Não deve mostrar modal, navegar imediatamente
            if (_waitingForBiometricsCheck && _pendingUser != null) {
              final isArtist = _pendingUser!.isArtist ?? false;
              router.replaceAll([NavigationRoute(isArtist: isArtist)]);
              setState(() {
                _waitingForBiometricsCheck = false;
                _pendingUser = null;
              });
            }
          }
        } else if (state is AuthProfileMismatch) {
          context.showError(state.error);
        } else if (state is AuthFailure) {
          context.showError(state.error);
        } else if (state is AuthConnectionFailure) {
          context.showError(state.message);
        } else if (state is EmailNotVerified) {
          // Email não verificado - mostrar warning e redirecionar para verificação
          context.showWarning('Por favor, verifique seu e-mail antes de continuar.');
          router.replace(EmailVerificationRoute(email: state.email));
        } else if (state is AuthDataIncomplete) {
          // Outros dados incompletos (ex: CPF/CNPJ) - redirecionar para onboarding
          context.showSuccess(state.message);
          router.replace(OnboardingRoute(email: _emailController.text.trim()));
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
          return AuthBasePage(
            title: 'LOGIN',
            subtitle: 'Acessar conta',
            children: [
              
              // Campo de Email
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                onChanged: (value) {
                },
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
                onChanged: (value) {
                },
              ),
              
              DSSizedBoxSpacing.vertical(20),

              // Link para esqueci senha
              Align(
                alignment: Alignment.centerRight,
                child: IgnorePointer(
                  ignoring: _isLoading,
                  child: Opacity(
                    opacity: _isLoading ? 0.5 : 1.0,
                    child: CustomLinkText(
                      text: 'Esqueci minha senha',
                      onTap: () {
                        router.push(const ForgotPasswordRoute());
                      },
                    ),
                  ),
                ),
              ),
              
              DSSizedBoxSpacing.vertical(12),
              
              // Seleção de Tipo de Usuário
              IgnorePointer(
                ignoring: _isLoading,
                child: Opacity(
                  opacity: _isLoading ? 0.5 : 1.0,
                  child: UserTypeSelector(
                  selectedType: _selectedUserType,
                  onChanged: (type) {
                      setState(() => _selectedUserType = type);
                  },
                  ),
                ),
              ),
              
              DSSizedBoxSpacing.vertical(48),
              
              // Botão de Login
              CustomButton(
                key: ValueKey('login_screen_button'),
                label: _isLoading ? 'Entrando...' : 'Entrar',
                filled: true,
                iconColor: colorScheme.primaryContainer,
                textColor: colorScheme.primaryContainer,
                backgroundColor: colorScheme.onPrimaryContainer,
                onPressed: _isLoading ? null : _handleLogin,
                isLoading: _isLoading,
              ),

              
              DSSizedBoxSpacing.vertical(16),
              
            ],
          );
        },
      ),
    );
  }
}

