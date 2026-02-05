
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/confirmation_dialog.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/profile/shared/presentation/widgets/option_icon.dart';
import 'package:app/features/profile/shared/presentation/widgets/option_switch.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@RoutePage(deferredLoading: true)
class LoginSecurityPage extends StatefulWidget {
  const LoginSecurityPage({super.key});

  @override
  State<LoginSecurityPage> createState() => _LoginSecurityPageState();
}

class _LoginSecurityPageState extends State<LoginSecurityPage> {
  bool _biometriaHabilitada = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Verificar estado inicial da biometria
    context.read<AuthBloc>().add(CheckBiometricsEnabledEvent());
  }

  Future<void> _handleDisableBiometrics() async {
    final confirmed = await _showDisableDialog();
    if (confirmed == true) {
      // Obter usuário atual para o evento
      if (mounted) {
        context.read<AuthBloc>().add(DisableBiometricsEvent());
      } else {
        // Reverte o switch se não conseguir obter usuário
      setState(() {
          _biometriaHabilitada = true;
      });
      if (mounted) {
          context.showError('Erro ao obter informações do usuário');
        }
      }
    } else {
      // Reverte o switch se cancelar
      setState(() {
        _biometriaHabilitada = true;
      });
    }
  }

  Future<void> _handleEnableBiometrics() async {
    // Mostra dialog informando que precisará fazer login novamente
    final confirmed = await _showEnableDialog();
    if (confirmed == true) {
      // Obter usuário atual para o logout
      if (mounted) {
        // Fazer logout - isso redirecionará para a tela de login
        // No login, já existe a lógica para pedir biometria após login bem-sucedido
        context.read<AuthBloc>().add(UserLogoutEvent());
      } else {
        // Reverte o switch se não conseguir obter usuário
        setState(() {
          _biometriaHabilitada = false;
        });
        if (mounted) {
          context.showError('Erro ao obter informações do usuário');
        }
      }
    } else {
      // Reverte o switch se cancelar
      setState(() {
        _biometriaHabilitada = false;
      });
    }
  }

  Future<bool?> _showDisableDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryContainer = colorScheme.primaryContainer;
    return ConfirmationDialog.show(
      context: context,
      title: 'Desabilitar Biometria',
      message: 'Para ativar novamente a biometria, você precisará fazer logout e login novamente. Deseja continuar?',
      confirmText: 'Confirmar',
      confirmButtonTextColor: primaryContainer,
      cancelText: 'Cancelar',
    );
  }

  Future<bool?> _showEnableDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryContainer = colorScheme.primaryContainer;
    return ConfirmationDialog.show(
      context: context,
      title: 'Habilitar Biometria',
      message: 'Para habilitar a biometria, você precisará fazer login novamente. Deseja continuar?',
      confirmText: 'Confirmar',
      confirmButtonTextColor: primaryContainer,
      cancelText: 'Cancelar',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final error = colorScheme.error;
    final router = AutoRouter.of(context);
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is InitialLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is CheckBiometricsEnabledSuccess) {
          // Atualizar estado da biometria quando verificar status
          setState(() {
            _biometriaHabilitada = state.isEnabled;
            _isLoading = false;
          });
        } else if (state is AuthSuccess) {
          // Sucesso ao desabilitar biometria
          setState(() {
            _biometriaHabilitada = false;
            _isLoading = false;
          });
          if (mounted) {
            context.showSuccess(state.message);
          }
        } else if (state is AuthFailure) {
          // Erro ao desabilitar/habilitar biometria
          // Reverter estado do switch
          setState(() {
            _isLoading = false;
          });
          context.read<AuthBloc>().add(CheckBiometricsEnabledEvent());
          if (mounted) {
            context.showError(state.error);
          }
        } else if (state is AuthLoggedOut) {
          // Logout bem-sucedido - redirecionar para tela de login
          router.replaceAll([LoginRoute()]);
        } else if (state is AuthInitial) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: BasePage(
      showAppBar: true,
      appBarTitle: 'Login e Segurança',
      showAppBarBackButton: true,
        child: Stack(
          children: [
            Column(
              children: [
                DSSizedBoxSpacing.vertical(32),
                
                OptionSwitch(
                  title: 'Habilitar Biometria',
                  icon: Icons.fingerprint,
                  iconColor: onPrimary,
                  value: _biometriaHabilitada,
                  onChanged: _isLoading ? (_) {} : (value) async {
                    if (value) {
                      // Ativa biometria
                      await _handleEnableBiometrics();
                    } else {
                      // Desativa biometria
                      await _handleDisableBiometrics();
                    }
                  },
                ),
                DSSizedBoxSpacing.vertical(8),
                OptionIcon(
                  title: 'Alterar senha',
                  icon: Icons.lock_outline,
                  iconColor: onPrimary,
                  onTap: () {
                    router.push(const ChangePasswordRoute());
                  },
                ),
                // DSSizedBoxSpacing.vertical(8),
                // OptionIcon(
                //   title: 'Alterar E-mail',
                //   icon: Icons.email,
                //   iconColor: onPrimary,
                //   onTap: () {
                //     // TODO: Implementar navegação quando rota estiver disponível
                //     // router.push(const ChangePasswordRoute());
                //   },
                // ),
                DSSizedBoxSpacing.vertical(8),
                OptionIcon(
                  title: 'Excluir conta',
                  icon: Icons.delete,
                  iconColor: error,
                  onTap: () {
                    router.push(const DeleteAccountRoute());
                  },
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CustomLoadingIndicator(),
                ),
              ),
          ],
        ),
        ),
      );
  }
}

