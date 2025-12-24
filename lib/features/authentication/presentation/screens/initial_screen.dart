import 'package:app/core/shared/widgets/app_logo.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleLoginButton(BuildContext context) {
    // Verificar se biometria está habilitada
    context.read<AuthBloc>().add(CheckBiometricsEnabledEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final router = AutoRouter.of(context);
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is InitialLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthInitial) {
          setState(() {
            _isLoading = false;
          });
        }
        if (state is CheckBiometricsEnabledSuccess) {
          if (state.isEnabled) {
            // Biometria habilitada, tentar login com biometria
            context.read<AuthBloc>().add(LoginWithBiometricsEvent());
          } else {
            // Biometria não habilitada, ir para tela de login
            router.push(const LoginRoute());
          }
        } else if (state is LoginWithBiometricsSuccess) {
          // Login com biometria bem-sucedido - APENAS neste caso navegar
          router.replaceAll([NavigationRoute(isArtist: state.isArtist)]);
        } else if (state is BiometricFailure) {
          // Biometria falhou (erro, cancelado ou incorreta), ir para tela de login
          router.push(const LoginRoute());
        } else if (state is AuthFailure) {
          // Verificar se é um erro relacionado a biometria
          final isBiometricError = state.error.contains('Biometria') || 
                                   state.error.contains('biometria') ||
                                   state.error.contains('cancelada');
          
          if (isBiometricError) {
            router.push(const LoginRoute());
          }
        }
      },
      child: PopScope(
      canPop: false,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {                    
          return  BasePage(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomLogo(size: 140),
                    Text(
                      "A magia da música e da arte\n tornando seus momentos\n inesquecíveis.",
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall!.copyWith(color: colorScheme.onPrimaryContainer),
                    ),
                    // Botão Fazer Login
                    DSSizedBoxSpacing.vertical(40),
                    // Botão Cadastrar-se
                    CustomButton(
                      key: ValueKey('initial_screen_register_button'),
                      label: 'Cadastre-se',
                      filled: true,
                      icon: Icons.person_add,
                      iconColor: colorScheme.primaryContainer,
                      textColor: colorScheme.primaryContainer,
                      backgroundColor: colorScheme.onPrimaryContainer,
                      onPressed: _isLoading ? null : () {
                        router.push(const RegisterRoute());
                      },
                    ),
                    // Espaçamento entre botões
                    DSSizedBoxSpacing.vertical(16),
                    CustomButton(
                      key: const ValueKey('initial_screen_login_button'),
                      label: _isLoading ? 'Verificando' : 'Fazer Login',
                      icon: Icons.login,
                      iconColor: colorScheme.onPrimaryContainer,
                      textColor: colorScheme.onPrimaryContainer,
                      backgroundColor: colorScheme.primaryContainer,
                      filled: true,
                      onPressed: _isLoading ? null : () => _handleLoginButton(context),
                      isLoading: _isLoading,
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
