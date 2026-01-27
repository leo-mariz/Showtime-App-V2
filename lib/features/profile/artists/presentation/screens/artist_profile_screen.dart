import 'dart:io';
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/services/image_picker_service.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/profile/shared/presentation/widgets/icon_menu_button.dart';
import 'package:app/features/profile/shared/presentation/widgets/logout_button.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_header.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_option_tile.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_picture/photo_confirmation_dialog.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_picture/profile_picture_options_menu.dart';
import 'package:app/features/profile/shared/presentation/widgets/artist_name_edit_modal.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:app/features/profile/artists/domain/enums/artist_incomplete_info_type_enum.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:app/features/profile/clients/presentation/bloc/clients_bloc.dart';
import 'package:app/features/profile/clients/presentation/bloc/events/clients_events.dart';
import 'package:app/features/profile/clients/presentation/bloc/states/clients_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen>{
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  // Armazenar dados localmente para evitar desaparecer durante loading específico
  String? _cachedArtistName;
  String? _cachedProfilePicture;

  @override
  void initState() {
    super.initState();
    // Buscar dados do artista ao carregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleGetArtist();
      // _handleGetUserData();    
    });
  }

  void _handleGetArtist({bool forceRefresh = false}) {
    if (!mounted) return;
    final artistsBloc = context.read<ArtistsBloc>();
    // Buscar apenas se não tiver dados carregados ou se forçado a atualizar
    if (forceRefresh || artistsBloc.state is! GetArtistSuccess) {
      artistsBloc.add(GetArtistEvent());
    }
  }

  /// Extrai o nome artístico do artista
  String? _getArtistName(ArtistEntity? artist) {
    if (artist == null) return null;
    return artist.artistName;
  }

  /// Verifica se os dados estão carregando
  /// Retorna false se tivermos cache, mesmo durante loading
  bool _isLoadingData(ArtistsState artistsState) {
    // Se tivermos cache, não mostrar skeleton mesmo durante loading
    if (_cachedArtistName != null || _cachedProfilePicture != null) {
      return false;
    }
    return artistsState is GetArtistLoading ||
           artistsState is ArtistsInitial;
  }

  /// Verifica se os dados estão prontos para exibir
  bool _isDataReady(ArtistsState artistsState) {
    return artistsState is GetArtistSuccess;
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
          value: context.read<ArtistsBloc>(),
        ),
        BlocProvider.value(
          value: context.read<ClientsBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              debugPrint('🔵 [ArtistProfileScreen] AuthBloc state: ${state.runtimeType}');
              if (state is AuthLoggedOut) {
                router.replaceAll([InitialRoute()]);
              } else if (state is AuthFailure) {
                context.showError(state.error);
              } else if (state is SwitchUserTypeSuccess) {
                debugPrint('🟢 [ArtistProfileScreen] SwitchUserTypeSuccess - Navegando para cliente (isArtist: ${state.isArtist})');
                // Perfil já existe, navegar diretamente
                router.replaceAll([NavigationRoute(isArtist: false)]);
                debugPrint('✅ [ArtistProfileScreen] Navegação executada');
              } else if (state is SwitchUserTypeNeedsCreation) {
                debugPrint('🟡 [ArtistProfileScreen] SwitchUserTypeNeedsCreation - Mostrando modal de termos');
                // Perfil não existe, mostrar modal de termos
                _showClientTermsModal();
              } else if (state is SwitchUserTypeFailure) {
                debugPrint('🔴 [ArtistProfileScreen] SwitchUserTypeFailure: ${state.error}');
                context.showError(state.error);
              } else if (state is SwitchUserTypeLoading) {
                debugPrint('⏳ [ArtistProfileScreen] SwitchUserTypeLoading');
              }
            },
          ),
          BlocListener<ClientsBloc, ClientsState>(
            listener: (context, state) {
              debugPrint('🔵 [ArtistProfileScreen] ClientsBloc state: ${state.runtimeType}');
              final router = AutoRouter.of(context);
              if (state is AddClientSuccess) {
                debugPrint('🟢 [ArtistProfileScreen] AddClientSuccess - Navegando para cliente');
                context.showSuccess('Perfil de cliente criado com sucesso!');
                // Usar WidgetsBinding para garantir que a navegação aconteça após o frame atual
                router.replaceAll([NavigationRoute(isArtist: false)]);
                debugPrint('✅ [ArtistProfileScreen] Navegação executada após criar cliente');
              } else if (state is AddClientFailure) {
                debugPrint('🔴 [ArtistProfileScreen] AddClientFailure: ${state.error}');
                context.showError(state.error);
              } else if (state is AddClientLoading) {
                debugPrint('⏳ [ArtistProfileScreen] AddClientLoading');
              }
            },
          ),
          BlocListener<ArtistsBloc, ArtistsState>(
            listener: (context, state) {
              if (state is GetArtistFailure) {
                context.showError(state.error);
              } else if (state is UpdateArtistProfilePictureSuccess) {
                context.showSuccess('Foto de perfil atualizada com sucesso!');
                // Fazer refresh silencioso após um pequeno delay para atualizar dados
                // mas manter cache para não mostrar skeleton
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    _handleGetArtist(forceRefresh: true);
                  }
                });
              } else if (state is UpdateArtistProfilePictureFailure) {
                context.showError(state.error);
              } else if (state is UpdateArtistNameSuccess) {
                context.showSuccess('Nome artístico atualizado com sucesso!');
                // Fazer refresh silencioso após um pequeno delay para atualizar dados
                // mas manter cache para não mostrar skeleton
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    _handleGetArtist(forceRefresh: true);
                  }
                });
              } else if (state is UpdateArtistNameFailure) {
                context.showError(state.error);
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<ClientsBloc, ClientsState>(
              builder: (context, clientsState) {
                return BlocBuilder<ArtistsBloc, ArtistsState>(
                  builder: (context, artistsState) {
                    final artist = artistsState is GetArtistSuccess
                        ? artistsState.artist
                        : null;
                    
                    final isLoadingProfilePicture = artistsState is UpdateArtistProfilePictureLoading;
                    final isLoadingName = artistsState is UpdateArtistNameLoading;
                    
                    // Atualizar cache apenas quando dados realmente mudarem (não durante loading)
                    if (artist != null && !isLoadingProfilePicture && !isLoadingName) {
                      final newArtistName = _getArtistName(artist);
                      if (newArtistName != null && newArtistName != _cachedArtistName) {
                        _cachedArtistName = newArtistName;
                      }
                      
                      if (artist.profilePicture != _cachedProfilePicture) {
                        _cachedProfilePicture = artist.profilePicture;
                      }
                    }
                    
                    // Usar dados em cache se disponíveis, senão usar dados atuais
                    final displayName = _cachedArtistName ?? _getArtistName(artist) ?? 'Artista';
                    final displayPicture = _cachedProfilePicture ?? artist?.profilePicture;
                    
                    final isLoadingData = _isLoadingData(artistsState);
                    final isDataReady = _isDataReady(artistsState);
                    
                    // Verificar se está em processo de alternância de conta
                    final isSwitchingAccount = authState is SwitchUserTypeLoading ||
                        clientsState is AddClientLoading;

                    // Helper para verificar se uma seção está incompleta
                    bool _isSectionIncomplete(ArtistIncompleteInfoType infoType) {
                      if (artist == null || 
                          artist.incompleteSections == null || 
                          artist.incompleteSections!.isEmpty) {
                        return false;
                      }
                      
                      final incompleteSections = artist.incompleteSections!;
                      return incompleteSections.values.any(
                        (types) => types.contains(infoType.name),
                      );
                    }

                    // Verificar se há informações incompletas na "Área do Artista"
                    final hasArtistAreaIncomplete = _isSectionIncomplete(ArtistIncompleteInfoType.professionalInfo) ||
                        _isSectionIncomplete(ArtistIncompleteInfoType.presentations) ||
                        _isSectionIncomplete(ArtistIncompleteInfoType.availability);

                    // Verificar se há informações incompletas em "Dados Cadastrais"
                    final hasRegisterDataIncomplete = _isSectionIncomplete(ArtistIncompleteInfoType.documents) ||
                        _isSectionIncomplete(ArtistIncompleteInfoType.bankAccount);

                    return Stack(
                      children: [
                        BasePage(
                          showAppBar: true,
                          appBarTitle: 'Perfil',
                          child: SingleChildScrollView(
                            child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Header com dados do artista
                                    if (isLoadingData)
                                      // Mostrar skeleton enquanto carrega
                                      _buildHeaderSkeleton()
                                    else if (isDataReady || _cachedArtistName != null || _cachedProfilePicture != null)
                                      // Mostrar header real quando dados estiverem prontos ou se tiver cache
                                      ProfileHeader(
                                        name: displayName,
                                        isArtist: true,
                                        imageUrl: displayPicture,
                                        onProfilePictureTap: () => _handleProfilePictureTap(),
                                        isLoadingProfilePicture: isLoadingProfilePicture,
                                        onSwitchUserType: () => _showSwitchAccountConfirmation(),
                                        onEditName: () => _handleEditName(_cachedArtistName ?? artist?.artistName),
                                      )
                                    else
                                      // Fallback: mostrar skeleton se não tiver dados nem cache
                                      _buildHeaderSkeleton(),
                                
                                DSSizedBoxSpacing.vertical(24),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    IconMenuButton(
                                      icon: Icons.music_note,
                                      label: 'Área do Artista',
                                      onPressed: () => router.push(const ArtistAreaRoute()),
                                      showWarning: hasArtistAreaIncomplete,
                                    ),
                                    IconMenuButton(
                                      icon: Icons.edit_document,
                                      label: 'Dados Cadastrais',
                                      onPressed: () => router.push(const RegisterDataAreaRoute()),
                                      showWarning: hasRegisterDataIncomplete,
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
        ),
      ),
    );
  }

  /// Gerencia o tap no avatar da foto de perfil
  Future<void> _handleProfilePictureTap() async {
    if (!mounted) return;

    final artistsBloc = context.read<ArtistsBloc>();
    final artist = artistsBloc.state is GetArtistSuccess
        ? (artistsBloc.state as GetArtistSuccess).artist
        : null;
    
    final hasImage = artist?.profilePicture != null && artist!.profilePicture!.isNotEmpty;

    // Mostrar modal de opções
    final option = await ProfilePictureOptionsMenu.show(
      context,
      hasImage: hasImage,
    );

    if (option == null || !mounted) return;

    switch (option) {
      case ProfilePictureOption.view:
        // Visualizar imagem em tela cheia
        _showImageViewDialog(artist?.profilePicture);
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
      context.read<ArtistsBloc>().add(
        UpdateArtistProfilePictureEvent(
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

  /// Gerencia a edição do nome artístico
  Future<void> _handleEditName(String? currentName) async {
    if (!mounted) return;

    final artistsBloc = context.read<ArtistsBloc>();

    await ArtistNameEditModal.show(
      context: context,
      currentName: currentName,
      onCheckName: (name) async {
        final result = await artistsBloc.checkArtistNameExistsUseCase(name);
        return result.fold(
          (_) => true, // Em caso de erro, considerar como existente para segurança
          (exists) => exists,
        );
      },
      onSave: (name) async {
        artistsBloc.add(UpdateArtistNameEvent(artistName: name));
        // Aguardar o estado de sucesso ser emitido
        await artistsBloc.stream.firstWhere(
          (state) => state is UpdateArtistNameSuccess || state is UpdateArtistNameFailure,
        );
      },
    );
  }

  /// Gerencia o logout do usuário
  void _handleLogout(BuildContext context) {
    // Dispara o evento de logout no AuthBloc
    context.read<AuthBloc>().add(UserLogoutEvent());
  }

  /// Mostra modal de confirmação para alternar tipo de conta
  Future<void> _showSwitchAccountConfirmation() async {
    debugPrint('🔵 [ArtistProfileScreen] _showSwitchAccountConfirmation chamado');
    if (!mounted) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => _SwitchAccountConfirmationModal(
        title: 'Alternar para Anfitrião',
        message: 'Deseja realmente alternar para a área de Anfitrião?',
        onConfirm: () {
          debugPrint('🟢 [ArtistProfileScreen] Modal confirmado - Disparando SwitchUserTypeEvent');
          context.read<AuthBloc>().add(
            SwitchUserTypeEvent(switchToArtist: false),
          );
          Navigator.of(context).pop();
        },
      ),
    );
    debugPrint('🔵 [ArtistProfileScreen] Modal fechado com resultado: $confirmed');
  }

  /// Mostra modal de termos de uso para clientes
  Future<void> _showClientTermsModal() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => _ClientTermsModal(),
    );

    if (confirmed == true && mounted) {
      
      context.read<ClientsBloc>().add(
        AddClientEvent(),
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

/// Modal para aceitar termos de uso de cliente
class _ClientTermsModal extends StatelessWidget {
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
            'Termos de Uso para Anfitriões',
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
                const TextSpan(text: 'Para criar um perfil de anfitrião, é necessário aceitar os '),
                TextSpan(
                  text: 'Termos de Uso para Anfitriões',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      router.push(const ClientTermsOfUseRoute());
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
                  label: 'Aceitar e Criar',
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