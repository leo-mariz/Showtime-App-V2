import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:app/features/profile/artists/presentation/widgets/artist_area_option_card.dart';
import 'package:app/features/profile/artists/presentation/widgets/reauthentication_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class RegisterDataAreaScreen extends StatefulWidget {
  const RegisterDataAreaScreen({super.key});

  @override
  State<RegisterDataAreaScreen> createState() => _RegisterDataAreaScreenState();
}

class _RegisterDataAreaScreenState extends State<RegisterDataAreaScreen> {
  bool _isLoading = false;


  void _handleBankAccountTap() {
    // Tentar reautenticar via biometria primeiro (sem senha)
    context.read<AuthBloc>().add(
      ReauthenticateUserEvent(password: null),
    );
  }

  Future<void> _showPasswordModal() async {
    final authenticated = await ReauthenticationModal.show(
      context: context,
    );

    if (authenticated && mounted) {
      AutoRouter.of(context).push(const BankAccountRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ReauthenticateUserLoading) {
          setState(() {
            _isLoading = true;
          });
        }
        // Reautenticação bem-sucedida (biometria ou senha)
        if (state is ReauthenticateUserSuccess) {
          setState(() {
            _isLoading = false;
          });
          AutoRouter.of(context).push(const BankAccountRoute());
        }

        // Biometria falhou - mostrar modal para senha
        if (state is ReauthenticateUserBiometricFailure) {
          setState(() {
            _isLoading = false;
          });
          _showPasswordModal();
        }

        // Senha incorreta - erro já é mostrado pelo dialog
        if (state is ReauthenticateUserPasswordFailure) {
          setState(() {
            _isLoading = false;
          });
          // Erro já é tratado no dialog
        }
      },
      child: BasePage(
        showAppBar: true,
        appBarTitle: 'Dados Cadastrais',
        showAppBarBackButton: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Opção: Documentos
              ArtistAreaOptionCard(
                title: 'Documentos',
                description: 'Faça o envio dos seus documentos.',
                icon: Icons.document_scanner,
                iconColor: onPrimaryContainer,
                onTap: () {
                  AutoRouter.of(context).push(const DocumentsRoute());
                },
              ),

              DSSizedBoxSpacing.vertical(8),

              // Opção: Dados Bancários
              ArtistAreaOptionCard(
                title: 'Dados Bancários',
                description: 'Adicione seus dados bancários para receber pagamentos.',
                icon: Icons.payments,
                iconColor: onPrimaryContainer,
                onTap: _handleBankAccountTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
