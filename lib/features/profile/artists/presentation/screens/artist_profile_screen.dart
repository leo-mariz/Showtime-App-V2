import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/services/image_picker_service.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/profile/shared/presentation/widgets/icon_menu_button.dart';
import 'package:app/features/profile/shared/presentation/widgets/logout_button.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_header.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_option_tile.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen>{
  
  @override
  ImagePickerService get imagePickerService => ImagePickerService();

  @override
  void initState() {
    super.initState();
    // Carrega os dados do estudante quando a tela é iniciada
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final router = AutoRouter.of(context);
    final colorScheme = theme.colorScheme;
    final primaryContainerWithOpacity = colorScheme.primaryContainer.withOpacity(0.1);

    return MultiBlocProvider(
      providers: [
        // AuthBloc já está disponível globalmente, mas adicionamos aqui
        // para preparar para futuros blocs que serão necessários
        BlocProvider.value(
          value: context.read<AuthBloc>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            // Logout bem-sucedido - redirecionar para tela inicial
            router.replaceAll([InitialRoute()]);
          } else if (state is AuthFailure) {
            // Erro no logout - mostrar notificação
            context.showError(state.error);
          }
        },
        child: BasePage(
          showAppBar: true,
          appBarTitle: 'Perfil',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header com dados do estudante
              ProfileHeader(
                name: 'Artista',
                isArtist: true,
                imageUrl: null,
                userId: null,
                onProfilePictureTap: () {},
                isLoadingProfilePicture: false,
                onSwitchUserType: () {
                  // TODO: Implementar lógica de troca de tipo de usuário
                  // Exemplo: context.read<AuthBloc>().add(SwitchUserTypeEvent());
                },
                onEditName: () {
                  // TODO: Implementar lógica de editar nome
                  // Exemplo: mostrar diálogo ou navegar para tela de edição
                },
              ),
              
              DSSizedBoxSpacing.vertical(24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconMenuButton(
                    icon: Icons.music_note,
                    label: 'Área do Artista',
                    onPressed: () => router.push(const ArtistAreaRoute()),
                    showWarning: false,
                  ),
                  IconMenuButton(
                    icon: Icons.edit_document,
                    label: 'Dados Cadastrais',
                    onPressed: () => router.push(const RegisterDataAreaRoute()),
                    showWarning: false,
                  ),
                  IconMenuButton(
                    icon: Icons.group,
                    label: 'Conjuntos',
                    onPressed: () {
                      router.push(const GroupsRoute());
                    },
                    showWarning: false,
                  ),
                ],
              ),

              DSSizedBoxSpacing.vertical(24),
              
              // Opções do perfil
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: primaryContainerWithOpacity,
                  child: Column(
                    children: [
                      ProfileOptionTile(
                        icon: Icons.person,
                        title: 'Informações pessoais',
                        showDivider: true,
                        isFirst: true,
                        onTap: () {
                          router.push(const PersonalInfoRoute());
                        },
                      ),
                      ProfileOptionTile(
                        icon: Icons.security,
                        title: 'Login e Segurança',
                        showDivider: true,
                        onTap: () {
                          router.push(const LoginSecurityRoute());
                        },
                      ),
                      ProfileOptionTile(
                        icon: Icons.support_agent,
                        title: 'Atendimento',
                        showDivider: true,
                        onTap: () {
                          router.push(const SupportRoute());
                        },
                      ),
                      ProfileOptionTile(
                        icon: Icons.description,
                        title: 'Termos de uso',
                        showDivider: true,
                        onTap: () {
                          router.push(const ClientTermsOfUseRoute());
                        },
                      ),
                      ProfileOptionTile(
                        icon: Icons.privacy_tip,
                        title: 'Política de privacidade',
                        showDivider: false,
                        isLast: true,
                        onTap: () {
                          router.push(const TermsOfPrivacyRoute());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              DSSizedBoxSpacing.vertical(40),

              
              // Botão de logout
              LogoutButton(
                onLogout: () => _handleLogout(context),
              ),
              DSSizedBoxSpacing.vertical(16),
            ],
          ),
        ),
      ),
    );
  }

        

  /// Gerencia o tap no avatar da foto de perfil
  Future<void> _handleProfilePictureTap(String? imageUrl) async {
    // await showProfilePictureOptions(context, imageUrl, handleProfilePictureOption);
  }

  /// Gerencia o logout do usuário
  void _handleLogout(BuildContext context) {
    // Dispara o evento de logout no AuthBloc
    context.read<AuthBloc>().add(UserLogoutEvent());
  }

}