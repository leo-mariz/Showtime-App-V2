import 'dart:io';
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/services/image_picker_service.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/profile/shared/presentation/widgets/icon_menu_button.dart';
import 'package:app/features/profile/shared/presentation/widgets/logout_button.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_header.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_option_tile.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_picture/photo_confirmation_dialog.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_picture/profile_picture_options_menu.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:app/features/profile/clients/presentation/bloc/clients_bloc.dart';
import 'package:app/features/profile/clients/presentation/bloc/events/clients_events.dart';
import 'package:app/features/profile/clients/presentation/bloc/states/clients_states.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';
import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen>{
  final ImagePickerService _imagePickerService = ImagePickerService();

  @override
  void initState() {
    super.initState();
    // Buscar dados do cliente e usuário ao carregar apenas se ainda não estiverem carregados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleGetClient();
      _handleGetUserData();
    });
  }

  void _handleGetClient({bool forceRefresh = false}) {
    final clientsBloc = context.read<ClientsBloc>();
    // Buscar apenas se não tiver dados carregados ou se forçado a atualizar
    if (forceRefresh || clientsBloc.state is! GetClientSuccess) {
      clientsBloc.add(GetClientEvent());
    }
  }

  void _handleGetUserData({bool forceRefresh = false}) {
    final usersBloc = context.read<UsersBloc>();
    // Buscar apenas se não tiver dados carregados ou se forçado a atualizar
    if (forceRefresh || usersBloc.state is! GetUserDataSuccess) {
      usersBloc.add(GetUserDataEvent());
    }
  }

  /// Extrai o nome do usuário baseado em CPF ou CNPJ
  String? _getUserName(UserEntity? user) {
    if (user == null) return null;
    
    // Se for CNPJ, usar companyName ou fantasyName
    if (user.isCnpj == true && user.cnpjUser != null) {
      return user.cnpjUser?.companyName ?? 
             user.cnpjUser?.fantasyName;
    }
    
    // Se for CPF, usar firstName + lastName
    if (user.cpfUser != null) {
      final firstName = user.cpfUser?.firstName ?? '';
      final lastName = user.cpfUser?.lastName ?? '';
      final fullName = [firstName, lastName].where((n) => n.isNotEmpty).join(' ');
      return fullName.isNotEmpty ? fullName : null;
    }
    
    return null;
  }

  /// Verifica se os dados estão carregando
  bool _isLoadingData(UsersState usersState, ClientsState clientsState) {
    return usersState is GetUserDataLoading || 
           clientsState is GetClientLoading ||
           usersState is UsersInitial ||
           clientsState is ClientsInitial;
  }

  /// Verifica se os dados estão prontos para exibir
  bool _isDataReady(UsersState usersState, ClientsState clientsState) {
    return usersState is GetUserDataSuccess && 
           clientsState is GetClientSuccess;
  }

  /// Widget skeleton para o header enquanto carrega
  Widget _buildHeaderSkeleton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        // Skeleton do avatar
        Container(
          width: DSSize.width(80),
          height: DSSize.width(80),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surfaceContainerHighest,
          ),
        ),
        DSSizedBoxSpacing.horizontal(12),
        // Skeleton do nome e badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton do nome
              Container(
                width: DSSize.width(150),
                height: DSSize.height(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: colorScheme.surfaceContainerHighest,
                ),
              ),
              DSSizedBoxSpacing.vertical(8),
              // Skeleton do badge
              Container(
                width: DSSize.width(100),
                height: DSSize.height(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DSSize.width(12)),
                  color: colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final router = AutoRouter.of(context);
    final colorScheme = theme.colorScheme;
    final primaryContainerWithOpacity = colorScheme.primaryContainer.withOpacity(0.1);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<AuthBloc>(),
        ),
        BlocProvider.value(
          value: context.read<ClientsBloc>(),
        ),
        BlocProvider.value(
          value: context.read<UsersBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoggedOut) {
                router.replaceAll([InitialRoute()]);
              } else if (state is AuthFailure) {
                context.showError(state.error);
              }
            },
          ),
          BlocListener<ClientsBloc, ClientsState>(
            listener: (context, state) {
              if (state is GetClientFailure) {
                context.showError(state.error);
              } else if (state is UpdateClientProfilePictureSuccess) {
                context.showSuccess('Foto de perfil atualizada com sucesso!');
                // Forçar recarregamento após atualização
                _handleGetClient(forceRefresh: true);
              } else if (state is UpdateClientProfilePictureFailure) {
                context.showError(state.error);
              }
            },
          ),
          BlocListener<UsersBloc, UsersState>(
            listener: (context, state) {
              if (state is GetUserDataFailure) {
                context.showError(state.error);
              }
            },
          ),
        ],
        child: BlocBuilder<UsersBloc, UsersState>(
          builder: (context, usersState) {
            return BlocBuilder<ClientsBloc, ClientsState>(
              builder: (context, clientsState) {
                final user = usersState is GetUserDataSuccess
                    ? usersState.user
                    : null;
                
                final client = clientsState is GetClientSuccess
                    ? clientsState.client
                    : null;
                
                final isLoadingProfilePicture = clientsState is UpdateClientProfilePictureLoading;
                final userName = _getUserName(user);
                final isLoadingData = _isLoadingData(usersState, clientsState);
                final isDataReady = _isDataReady(usersState, clientsState);

                return BasePage(
                  showAppBar: true,
                  appBarTitle: 'Perfil',
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header com dados do cliente
                        if (isLoadingData)
                          // Mostrar skeleton enquanto carrega
                          _buildHeaderSkeleton()
                        else if (isDataReady)
                          // Mostrar header real quando dados estiverem prontos
                          ProfileHeader(
                            name: userName ?? 'Cliente',
                            isArtist: false,
                            imageUrl: client?.profilePicture,
                            onProfilePictureTap: () => _handleProfilePictureTap(),
                            isLoadingProfilePicture: isLoadingProfilePicture,
                            onSwitchUserType: () {
                              // TODO: Implementar troca de tipo de usuário
                            },
                          )
                        else
                          // Fallback: mostrar skeleton se dados não estiverem prontos
                          _buildHeaderSkeleton(),
                    
                        DSSizedBoxSpacing.vertical(24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconMenuButton(
                              icon: Icons.star,
                              label: 'Preferências',
                              onPressed: () {},
                              showWarning: false,
                            ),
                            IconMenuButton(
                              icon: Icons.location_on,
                              label: 'Endereços',
                              onPressed: () => router.push(const AddressesListRoute()),
                              showWarning: false,
                            ),
                            IconMenuButton(
                              icon: Icons.history,
                              label: 'Histórico',
                              onPressed: () {},
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
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Gerencia o tap no avatar da foto de perfil
  Future<void> _handleProfilePictureTap() async {
    if (!mounted) return;

    final clientsBloc = context.read<ClientsBloc>();
    final client = clientsBloc.state is GetClientSuccess
        ? (clientsBloc.state as GetClientSuccess).client
        : null;
    
    final hasImage = client?.profilePicture != null && client!.profilePicture!.isNotEmpty;

    // Mostrar modal de opções
    final option = await ProfilePictureOptionsMenu.show(
      context,
      hasImage: hasImage,
    );

    if (option == null || !mounted) return;

    switch (option) {
      case ProfilePictureOption.view:
        // Visualizar imagem em tela cheia
        _showImageViewDialog(client?.profilePicture);
        break;

      case ProfilePictureOption.gallery:
        // Selecionar da galeria
        final imageFile = await _imagePickerService.pickImageFromGallery();
        if (imageFile != null && mounted) {
          await _confirmAndUpdateProfilePicture(imageFile);
        }
        break;

      case ProfilePictureOption.camera:
        // Capturar da câmera
        final imageFile = await _imagePickerService.captureImageFromCamera();
        if (imageFile != null && mounted) {
          await _confirmAndUpdateProfilePicture(imageFile);
        }
        break;

      case ProfilePictureOption.remove:
        // Remover foto de perfil
        await _confirmAndRemoveProfilePicture();
        break;
    }
  }

  /// Mostra a imagem em tela cheia
  void _showImageViewDialog(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: DSSize.width(48),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: DSSize.height(16),
              right: DSSize.width(16),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: DSSize.width(32),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirma e atualiza a foto de perfil
  Future<void> _confirmAndUpdateProfilePicture(File imageFile) async {
    final confirmed = await PhotoConfirmationDialog.show(
      context,
      imageFile: imageFile,
    );

    if (confirmed == true && mounted) {
      context.read<ClientsBloc>().add(
        UpdateClientProfilePictureEvent(
          localFilePath: imageFile.path,
        ),
      );
    }
  }

  /// Confirma e remove a foto de perfil
  Future<void> _confirmAndRemoveProfilePicture() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover foto de perfil'),
        content: const Text('Tem certeza que deseja remover sua foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Implementar evento para remover foto de perfil
      // Por enquanto, apenas mostra uma mensagem
      context.showError('Funcionalidade de remoção em desenvolvimento');
    }
  }

  /// Gerencia o logout do usuário
  void _handleLogout(BuildContext context) {
    // Dispara o evento de logout no AuthBloc
    context.read<AuthBloc>().add(UserLogoutEvent());
  }

}