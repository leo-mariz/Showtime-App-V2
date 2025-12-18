
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/presentation/widgets/option_icon.dart';
import 'package:app/features/profile/presentation/widgets/option_switch.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage(deferredLoading: true)
class LoginSecurityPage extends StatefulWidget {
  const LoginSecurityPage({super.key});

  @override
  State<LoginSecurityPage> createState() => _LoginSecurityPageState();
}

class _LoginSecurityPageState extends State<LoginSecurityPage> {
  bool _biometriaHabilitada = false; // Mock: estado inicial
  bool _isLoading = false;

  Future<void> _handleDisableBiometrics() async {
    final confirmed = await _showDisableDialog();
    if (confirmed == true) {
      setState(() {
        _biometriaHabilitada = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometria desabilitada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
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
      // Mock: Simula habilitação
      setState(() {
        _biometriaHabilitada = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometria habilitada! Faça logout e login novamente para ativar.'),
            backgroundColor: Colors.green,
          ),
        );
        // TODO: Implementar logout quando Bloc estiver disponível
        // AutoRouter.of(context).replaceAll([const LoginRoute()]);
      }
    } else {
      // Reverte o switch se cancelar
      setState(() {
        _biometriaHabilitada = false;
      });
    }
  }

  Future<bool?> _showDisableDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Desabilitar Biometria', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),),
        content: Text(
          'Para ativar novamente a biometria, você precisará fazer logout e login novamente. Deseja continuar?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirmar', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer,),),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showEnableDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Habilitar Biometria', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),),
        content: Text(
          'Para habilitar a biometria, você precisará fazer login novamente. Deseja continuar?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirmar', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer,),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final onError = colorScheme.onError;
    final error = colorScheme.error;
    final router = AutoRouter.of(context);
    
    return BasePage(
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
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      );
  }
}

