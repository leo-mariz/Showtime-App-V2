import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_icon_button.dart';
import 'package:app/core/shared/widgets/custom_badge.dart';
import 'package:app/core/shared/widgets/tabs_section.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class ArtistProfileViewScreen extends StatefulWidget {
  const ArtistProfileViewScreen({super.key});

  @override
  State<ArtistProfileViewScreen> createState() => _ArtistProfileViewScreenState();
}

class _ArtistProfileViewScreenState extends State<ArtistProfileViewScreen> {
  @override
  void initState() {
    super.initState();
    // Buscar dados do artista ao carregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleGetArtist();
      }
    });
  }

  void _handleGetArtist({bool forceRefresh = false}) {
    final artistsBloc = context.read<ArtistsBloc>();
    // Buscar apenas se não tiver dados carregados ou se forçado a atualizar
    if (forceRefresh || artistsBloc.state is! GetArtistSuccess) {
      artistsBloc.add(GetArtistEvent());
    }
  }

  void _onVideoTap(BuildContext context, String videoUrl) {
    // TODO: Implementar abertura do vídeo em tela cheia
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: DSSize.width(64),
                ),
                SizedBox(height: DSSize.height(16)),
                Text(
                  'Vídeo: $videoUrl',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DSSize.height(24)),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final onPrimary = colorScheme.onPrimary;

    return BlocListener<ArtistsBloc, ArtistsState>(
      listener: (context, state) {
        if (state is GetArtistFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<ArtistsBloc, ArtistsState>(
        builder: (context, state) {
          final isLoading = state is GetArtistLoading || state is ArtistsInitial;
          final artist = state is GetArtistSuccess ? state.artist : null;

          return BasePage(
            horizontalPadding: 0,
            verticalPadding: 0,
            child: Stack(
              children: [
                if (isLoading)
                  const Center(child: CustomLoadingIndicator())
                else if (artist != null)
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        // Foto de perfil com gradiente
                        Stack(
                          children: [
                            // Imagem de perfil
                            Container(
                              height: DSSize.height(300),
                              width: double.infinity,
                              color: colorScheme.surfaceContainerHighest,
                              child: artist.profilePicture != null
                                  ? CachedNetworkImage(
                                      imageUrl: artist.profilePicture!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: CustomLoadingIndicator(
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_photo_alternate_outlined,
                                              size: DSSize.width(48),
                                              color: onSurfaceVariant.withOpacity(0.6),
                                            ),
                                            DSSizedBoxSpacing.vertical(8),
                                            Text(
                                              'Erro ao carregar imagem',
                                              style: textTheme.bodyMedium?.copyWith(
                                                color: onSurfaceVariant,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            size: DSSize.width(48),
                                            color: onSurfaceVariant.withOpacity(0.6),
                                          ),
                                          DSSizedBoxSpacing.vertical(8),
                                          Text(
                                            'Adicione uma foto de perfil',
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: onSurfaceVariant,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            // Gradiente
                            Container(
                              height: DSSize.height(300),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    colorScheme.surface.withOpacity(0.9),
                                  ],
                                ),
                              ),
                            ),
                            // Header com botões
                            SafeArea(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: DSPadding.horizontal(16),
                                  vertical: DSPadding.vertical(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomIconButton(
                                      icon: Icons.arrow_back_ios_new_rounded,
                                      onPressed: () => Navigator.of(context).pop(),
                                      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                                      color: onPrimaryContainer,
                                    ),
                                    CustomIconButton(
                                      icon: Icons.share,
                                      onPressed: () {
                                        // TODO: Implementar compartilhamento
                                      },
                                      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                                      color: onPrimaryContainer,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Conteúdo principal
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: DSPadding.horizontal(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DSSizedBoxSpacing.vertical(16),

                              // Nome artístico
                              Text(
                                artist.artistName ?? 'Artista',
                                style: textTheme.headlineLarge?.copyWith(
                                  color: onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              DSSizedBoxSpacing.vertical(12),

                              // Badges de avaliação, contratos e favorito
                              Row(
                                children: [
                                  CustomBadge(
                                    value: artist.rating.toString(),
                                    icon: Icons.star,
                                    color: onPrimaryContainer,
                                  ),
                                  DSSizedBoxSpacing.horizontal(8),
                                  CustomBadge(
                                    title: 'Contratos',
                                    value: artist.rateCount?.toString() ?? '0',
                                    color: onPrimaryContainer,
                                  ),
                                  const Spacer(),
                                  // FavoriteButton(
                                  //   isFavorite: isFavorite,
                                  //   onTap: () {
                                  //     // TODO: Implementar toggle de favorito
                                  //   },
                                  // ),
                                ],
                              ),

                              DSSizedBoxSpacing.vertical(16),

                              // Bio completa
                              Text(
                                artist.professionalInfo?.bio ?? 'Adicione uma biografia para descrever seu trabalho e experiência.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: artist.professionalInfo?.bio != null
                                      ? onSurfaceVariant
                                      : onSurfaceVariant.withOpacity(0.6),
                                  height: 1.5,
                                  fontStyle: artist.professionalInfo?.bio == null
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                              DSSizedBoxSpacing.vertical(24),

                              // Tabs de Estilos/Talentos
                              TabsSection(
                                artist: artist,
                                onVideoTap: (videoUrl) => _onVideoTap(context, videoUrl),
                              ),

                              DSSizedBoxSpacing.vertical(100), // Espaço para o footer
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Text(
                      'Artista não encontrado',
                      style: textTheme.bodyLarge?.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
