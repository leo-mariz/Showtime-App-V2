import 'dart:io';
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/services/image_picker_service.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/profile/shared/presentation/widgets/logout_button.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_header.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_option_tile.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_picture/photo_confirmation_dialog.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_picture/profile_picture_options_menu.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:app/features/artists/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/artists/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/artists/artists/presentation/bloc/states/artists_states.dart';
import 'package:app/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:app/features/clients/presentation/bloc/events/clients_events.dart';
import 'package:app/features/clients/presentation/bloc/states/clients_states.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';
import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen>{
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  // Armazenar dados localmente para evitar desaparecer durante loading específico
  String? _cachedUserName;
  String? _cachedProfilePicture;

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
    if (!mounted) return;
    final clientsBloc = context.read<ClientsBloc>();
    // Buscar apenas se não tiver dados carregados ou se forçado a atualizar
    if (forceRefresh || clientsBloc.state is! GetClientSuccess) {
      clientsBloc.add(GetClientEvent());
    }
  }

  void _handleGetUserData({bool forceRefresh = false}) {
    if (!mounted) return;
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
  /// Retorna false se tivermos cache, mesmo durante loading
  bool _isLoadingData(UsersState usersState, ClientsState clientsState) {
    // Se tivermos cache, não mostrar skeleton mesmo durante loading
    if (_cachedUserName != null || _cachedProfilePicture != null) {
      return false;
    }
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
        BlocProvider.value(
          value: context.read<ArtistsBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              debugPrint('🔵 [ClientProfileScreen] AuthBloc state: ${state.runtimeType}');
              if (state is AuthLoggedOut) {
                router.replaceAll([InitialRoute()]);
              } else if (state is AuthFailure) {
                context.showError(state.error);
              } else if (state is SwitchUserTypeSuccess) {
                debugPrint('🟢 [ClientProfileScreen] SwitchUserTypeSuccess - Navegando para artista (isArtist: ${state.isArtist})');
                // Perfil já existe, navegar diretamente
                router.replaceAll([NavigationRoute(isArtist: true)]);
                debugPrint('✅ [ClientProfileScreen] Navegação executada');
              } else if (state is SwitchUserTypeNeedsCreation) {
                debugPrint('🟡 [ClientProfileScreen] SwitchUserTypeNeedsCreation - Mostrando modal de termos');
                // Perfil não existe, mostrar modal de termos
                _showArtistTermsModal();
              } else if (state is SwitchUserTypeFailure) {
                debugPrint('🔴 [ClientProfileScreen] SwitchUserTypeFailure: ${state.error}');
                context.showError(state.error);
              } else if (state is SwitchUserTypeLoading) {
                debugPrint('⏳ [ClientProfileScreen] SwitchUserTypeLoading');
              }
            },
          ),
          BlocListener<ArtistsBloc, ArtistsState>(
            listener: (context, state) {
              debugPrint('🔵 [ClientProfileScreen] ArtistsBloc state: ${state.runtimeType}');
              if (state is AddArtistSuccess) {
                debugPrint('🟢 [ClientProfileScreen] AddArtistSuccess - Navegando para artista');
                context.showSuccess('Perfil de artista criado com sucesso!');
                router.replaceAll([NavigationRoute(isArtist: true)]);
                debugPrint('✅ [ClientProfileScreen] Navegação executada após criar artista');
              } else if (state is AddArtistFailure) {
                debugPrint('🔴 [ClientProfileScreen] AddArtistFailure: ${state.error}');
                context.showError(state.error);
              } else if (state is AddArtistLoading) {
                debugPrint('⏳ [ClientProfileScreen] AddArtistLoading');
              }
            },
          ),
          BlocListener<ClientsBloc, ClientsState>(
            listener: (context, state) {
              if (state is GetClientFailure) {
                context.showError(state.error);
              } else if (state is UpdateClientProfilePictureSuccess) {
                context.showSuccess('Foto de perfil atualizada com sucesso!');
                // Fazer refresh silencioso após um pequeno delay para atualizar dados
                // mas manter cache para não mostrar skeleton
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    _handleGetClient(forceRefresh: true);
                  }
                });
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
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<UsersBloc, UsersState>(
              builder: (context, usersState) {
                return BlocBuilder<ClientsBloc, ClientsState>(
                  builder: (context, clientsState) {
                    return BlocBuilder<ArtistsBloc, ArtistsState>(
                      builder: (context, artistsState) {
                        final user = usersState is GetUserDataSuccess
                            ? usersState.user
                            : null;
                        
                        final client = clientsState is GetClientSuccess
                            ? clientsState.client
                            : null;
                        
                        final isLoadingProfilePicture = clientsState is UpdateClientProfilePictureLoading;
                        
                        // Atualizar cache apenas quando dados realmente mudarem (não durante loading)
                        if (user != null && !isLoadingProfilePicture) {
                          final newUserName = _getUserName(user);
                          if (newUserName != null && newUserName != _cachedUserName) {
                            _cachedUserName = newUserName;
                          }
                        }
                        
                        if (client != null && !isLoadingProfilePicture) {
                          if (client.profilePicture != _cachedProfilePicture) {
                            _cachedProfilePicture = client.profilePicture;
                          }
                        }
                        
                        // Usar dados em cache se disponíveis, senão usar dados atuais
                        final displayName = _cachedUserName ?? _getUserName(user) ?? 'Cliente';
                        final displayPicture = _cachedProfilePicture ?? client?.profilePicture;
                        
                        final isLoadingData = _isLoadingData(usersState, clientsState);
                        final isDataReady = _isDataReady(usersState, clientsState);
                        
                        // Verificar se está em processo de alternância de conta
                        final isSwitchingAccount = authState is SwitchUserTypeLoading ||
                            artistsState is AddArtistLoading;

                        return Stack(
                          children: [
                            BasePage(
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
                                    else if (isDataReady || _cachedUserName != null || _cachedProfilePicture != null)
                                      // Mostrar header real quando dados estiverem prontos ou se tiver cache
                                      ProfileHeader(
                                        name: displayName,
                                        isArtist: false,
                                        imageUrl: displayPicture,
                                        onProfilePictureTap: () => _handleProfilePictureTap(),
                                        isLoadingProfilePicture: isLoadingProfilePicture,
                                        onSwitchUserType: () => _showSwitchAccountConfirmation(),
                                        rating: client?.rating,
                                        rateCount: client?.rateCount,
                                      )
                                    else
                                      // Fallback: mostrar skeleton se dados não estiverem prontos
                                      _buildHeaderSkeleton(),
                                
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
                                            // ProfileOptionTile(
                                            //   icon: Icons.star,
                                            //   title: 'Preferências',
                                            //   showDivider: true,
                                            //   onTap: () {},
                                            //   isLast: false,
                                            // ),
                                            ProfileOptionTile(
                                              icon: Icons.support_agent,
                                              title: 'Atendimento',
                                              showDivider: true,
                                              onTap: () {
                                                router.push(SupportRoute());
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
                            if (isSwitchingAccount)
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: CustomLoadingIndicator(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
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
        final result = await _imagePickerService.pickImageFromGallery();
        if (!mounted) return;
        if (result.file != null) {
          await _confirmAndUpdateProfilePicture(result.file!);
        } else if (result.errorMessage != null) {
          context.showError(result.errorMessage!);
        }
        break;

      case ProfilePictureOption.camera:
        // Capturar da câmera
        final result = await _imagePickerService.captureImageFromCamera();
        if (!mounted) return;
        if (result.file != null) {
          await _confirmAndUpdateProfilePicture(result.file!);
        } else if (result.errorMessage != null) {
          context.showError(result.errorMessage!);
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

  /// Mostra modal de confirmação para alternar tipo de conta
  Future<void> _showSwitchAccountConfirmation() async {
    debugPrint('🔵 [ClientProfileScreen] _showSwitchAccountConfirmation chamado');
    if (!mounted) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => _SwitchAccountConfirmationModal(
        title: 'Alternar para Artista',
        message: 'Deseja realmente alternar para a área de Artista?',
        onConfirm: () {
          debugPrint('🟢 [ClientProfileScreen] Modal confirmado - Disparando SwitchUserTypeEvent');
          context.read<AuthBloc>().add(
            SwitchUserTypeEvent(switchToArtist: true),
          );
          Navigator.of(context).pop();
        },
      ),
    );
    debugPrint('🔵 [ClientProfileScreen] Modal fechado com resultado: $confirmed');
  }

  /// Mostra modal de termos de uso para artistas
  Future<void> _showArtistTermsModal() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => _ArtistTermsModal(),
    );

    if (confirmed == true && mounted) {
      
      context.read<ArtistsBloc>().add(
        AddArtistEvent(),
      );
    }
  }
}

/// Modal de confirmação para alternar tipo de conta
class _SwitchAccountConfirmationModal extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const _SwitchAccountConfirmationModal({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: DSSize.width(16),
        right: DSSize.width(16),
        top: DSSize.height(16),
        bottom: MediaQuery.of(context).viewInsets.bottom + DSSize.height(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(16),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              DSSizedBoxSpacing.horizontal(16),
              Expanded(
                child: CustomButton(
                  label: 'Confirmar',
                  backgroundColor: colorScheme.onPrimaryContainer,
                  textColor: colorScheme.primaryContainer,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Modal para aceitar termos de uso de artista
class _ArtistTermsModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final router = AutoRouter.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: DSSize.width(16),
        right: DSSize.width(16),
        top: DSSize.height(16),
        bottom: MediaQuery.of(context).viewInsets.bottom + DSSize.height(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          Text(
            'Termos de Uso para Artistas',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(16),
          RichText(
            text: TextSpan(
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
              children: [
                const TextSpan(text: 'Para criar um perfil de artista, é necessário aceitar os '),
                TextSpan(
                  text: 'Termos de Uso para Artistas',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      router.push(const ArtistsTermsOfUseRoute());
                    },
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          DSSizedBoxSpacing.vertical(24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancelar',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              DSSizedBoxSpacing.horizontal(16),
              Expanded(
                child: CustomButton(
                  label: 'Aceitar',
                  backgroundColor: colorScheme.onPrimaryContainer,
                  textColor: colorScheme.primaryContainer,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}