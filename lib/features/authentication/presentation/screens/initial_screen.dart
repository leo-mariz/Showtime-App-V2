import 'package:app/core/shared/widgets/app_logo.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/utils/bloc_reset_helper.dart';
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
  bool _shouldHandleBiometricsCheck = false; // Flag para controlar se deve processar o resultado
  bool _isNavigatingAfterLogin = false; // Flag para controlar se estamos navegando após login bem-sucedido
  bool _hasResetBlocs = false; // Flag para evitar resetar múltiplas vezes

  @override
  void initState() {
    super.initState();
    
    // Verificar se o estado já é AuthLoggedOut quando a tela é montada
    // Isso resolve o caso onde o logout acontece antes da tela estar montada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthLoggedOut && !_hasResetBlocs) {
          _resetAllBlocs(context);
        }
      }
    });
  }
  
  void _resetAllBlocs(BuildContext context) {
    if (_hasResetBlocs) return; // Evitar resetar múltiplas vezes
    
    _hasResetBlocs = true;
    print('🟡 [InitialScreen] Iniciando reset de BLoCs');
    try {
      BlocResetHelper.resetAllBlocs(context);
      print('🟡 [InitialScreen] Reset de BLoCs concluído');
    } catch (e, stackTrace) {
      print('❌ [InitialScreen] Erro ao resetar BLoCs: $e');
      print('❌ [InitialScreen] StackTrace: $stackTrace');
      _hasResetBlocs = false; // Permitir tentar novamente em caso de erro
    }
  }

  void _handleLoginButton(BuildContext context) {
    // Marcar que devemos processar o resultado da verificação
    setState(() {
      _shouldHandleBiometricsCheck = true;
      _isLoading = true; // Iniciar loading imediatamente
    });
    // Verificar se biometria está habilitada
    context.read<AuthBloc>().add(CheckBiometricsEnabledEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final router = AutoRouter.of(context);
    
    return BlocListener<AuthBloc, AuthState>(
      // listenWhen garante que o listener seja acionado mesmo se o estado já for AuthLoggedOut
      listener: (context, state) {
        // Resetar todos os BLoCs quando logout for detectado
        if (state is AuthLoggedOut) {
          _resetAllBlocs(context);
        }

        if (state is InitialLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is LoginLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthInitial) {
          // Só resetar loading se não estivermos esperando navegação
          // Não resetar aqui para manter loading durante navegação após login bem-sucedido
          if (!_isNavigatingAfterLogin) {
            setState(() {
              _isLoading = false;
            });
          }
        }
        
        if (state is CheckBiometricsEnabledSuccess) {
          // Só processar se foi disparado a partir do botão de login desta tela
          if (_shouldHandleBiometricsCheck) {
            setState(() {
              _shouldHandleBiometricsCheck = false; // Resetar flag
            });
            if (state.isEnabled) {
              // Biometria habilitada, tentar login com biometria
              context.read<AuthBloc>().add(LoginWithBiometricsEvent());
            } else {
              // Biometria não habilitada, ir para tela de login
              setState(() {
                _isLoading = false;
              });
              router.push(const LoginRoute());
            }
          }
        } else if (state is LoginWithBiometricsSuccess) {
          // Marcar que estamos navegando para manter loading
          setState(() {
            _isNavigatingAfterLogin = true;
            _isLoading = true; // Garantir que loading está ativo
          });
          
          // Login com biometria bem-sucedido - APENAS neste caso navegar
          // Manter loading durante navegação
          router.replaceAll([NavigationRoute(isArtist: state.isArtist)]);
          
          // Aguardar alguns frames antes de resetar loading (para garantir que a nova tela está sendo construída)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _isNavigatingAfterLogin = false;
                });
              }
            });
          });
        } else if (state is BiometricFailure) {
          // Biometria falhou (erro, cancelado ou incorreta), ir para tela de login
          setState(() {
            _isLoading = false;
          });
          router.push(const LoginRoute());
        } else if (state is AuthFailure) {
          // Verificar se é um erro relacionado a biometria
          final isBiometricError = state.error.contains('Biometria') || 
                                   state.error.contains('biometria') ||
                                   state.error.contains('cancelada');
          
          if (isBiometricError) {
            setState(() {
              _isLoading = false;
            });
            router.push(const LoginRoute());
          } else {
            setState(() {
              _isLoading = false;
            });
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
