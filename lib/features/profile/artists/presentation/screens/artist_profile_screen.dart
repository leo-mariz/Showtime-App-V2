import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/services/image_picker_service.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/profile/shared/presentation/widgets/icon_menu_button.dart';
import 'package:app/features/profile/shared/presentation/widgets/logout_button.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_header.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_option_tile.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_picture/photo_confirmation_dialog.dart';
import 'package:app/features/profile/shared/presentation/widgets/artist_name_edit_modal.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen>{
  final ImagePickerService _imagePickerService = ImagePickerService();

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
  bool _isLoadingData(ArtistsState artistsState) {
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
          BlocListener<ArtistsBloc, ArtistsState>(
            listener: (context, state) {
              if (state is GetArtistFailure) {
                context.showError(state.error);
              } else if (state is UpdateArtistProfilePictureSuccess) {
                context.showSuccess('Foto de perfil atualizada com sucesso!');
                // Forçar recarregamento após atualização
                _handleGetArtist(forceRefresh: true);
              } else if (state is UpdateArtistProfilePictureFailure) {
                context.showError(state.error);
              } else if (state is UpdateArtistNameSuccess) {
                context.showSuccess('Nome artístico atualizado com sucesso!');
                // Forçar recarregamento após atualização
                _handleGetArtist(forceRefresh: true);
              } else if (state is UpdateArtistNameFailure) {
                context.showError(state.error);
              }
            },
          ),
        ],
        child: BlocBuilder<ArtistsBloc, ArtistsState>(
          builder: (context, artistsState) {
            final artist = artistsState is GetArtistSuccess
                ? artistsState.artist
                : null;
            
            final isLoadingProfilePicture = artistsState is UpdateArtistProfilePictureLoading;
            final artistName = _getArtistName(artist);
            final isLoadingData = _isLoadingData(artistsState);
            final isDataReady = _isDataReady(artistsState);

            return BasePage(
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
                        else if (isDataReady && artistName != null)
                          // Mostrar header real quando dados estiverem prontos
                          ProfileHeader(
                            name: artistName,
                            isArtist: true,
                            imageUrl: artist?.profilePicture,
                            onProfilePictureTap: () => _handleProfilePictureTap(),
                            isLoadingProfilePicture: isLoadingProfilePicture,
                            onSwitchUserType: () {
                              // TODO: Implementar troca de tipo de usuário
                            },
                            onEditName: () => _handleEditName(artist?.artistName),
                          )
                        else
                          // Fallback caso não tenha nome (não deveria acontecer, mas por segurança)
                          ProfileHeader(
                            name: 'Artista',
                            isArtist: true,
                            imageUrl: artist?.profilePicture,
                            onProfilePictureTap: () => _handleProfilePictureTap(),
                            isLoadingProfilePicture: isLoadingProfilePicture,
                            onSwitchUserType: () {
                              // TODO: Implementar troca de tipo de usuário
                            },
                            onEditName: () => _handleEditName(artist?.artistName),
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
            );
          },  
        ),
      ),
    );
  }

  /// Gerencia o tap no avatar da foto de perfil
  Future<void> _handleProfilePictureTap() async {
    // Selecionar imagem da galeria
    final imageFile = await _imagePickerService.pickImageFromGallery();
    
    if (imageFile == null || !mounted) return;

    // Mostrar dialog de confirmação
    final confirmed = await PhotoConfirmationDialog.show(
      context,
      imageFile: imageFile,
    );

    if (confirmed == true && mounted) {
      // Disparar evento de atualização
      context.read<ArtistsBloc>().add(
        UpdateArtistProfilePictureEvent(
          localFilePath: imageFile.path,
        ),
      );
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

}