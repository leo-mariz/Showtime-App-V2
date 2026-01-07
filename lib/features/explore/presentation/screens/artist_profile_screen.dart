import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_icon_button.dart';
import 'package:app/core/shared/widgets/artist_footer.dart';
import 'package:app/core/shared/widgets/favorite_button.dart';
import 'package:app/core/shared/widgets/custom_badge.dart';
import 'package:app/core/shared/widgets/tabs_section.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

@RoutePage(deferredLoading: true)
class ArtistProfileScreen extends StatelessWidget {
  final ArtistEntity artist;
  final bool isFavorite;
  final bool viewOnly;

  const ArtistProfileScreen({
    super.key,
    required this.artist,
    this.isFavorite = false,
    this.viewOnly = false,
  });

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

  void _onRequestPressed(BuildContext context) {
    final router = context.router;
    final address = artist.residenceAddress;
    final addressString = address != null
        ? '${address.street ?? ''}, ${address.number ?? ''} - ${address.district ?? ''}, ${address.city ?? ''}'
        : 'Endereço não disponível';
    
    router.push(
      RequestRoute(
        selectedDate: DateTime.now(),
        selectedAddress: addressString,
        artist: artist,
        pricePerHour: artist.professionalInfo?.hourlyRate ?? 0.0,
        minimumDuration: Duration(
          minutes: artist.professionalInfo?.minimumShowDuration ?? 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final onPrimary = colorScheme.onPrimary;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return BasePage(
      horizontalPadding: 0,
      verticalPadding: 0,
      child: Stack(
        children: [
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
                      decoration: BoxDecoration(
                        image: artist.profilePicture != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                  artist.profilePicture!,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: artist.profilePicture == null
                            ? colorScheme.surfaceContainerHighest
                            : null,
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
                          CustomBadge(value: artist.rating.toString(), icon: Icons.star, color: onPrimaryContainer),
                          DSSizedBoxSpacing.horizontal(8),
                          CustomBadge(title: 'Contratos', value: artist.finalizedContracts.toString(), color: onPrimaryContainer),
                          const Spacer(),
                          FavoriteButton(
                            isFavorite: isFavorite,
                            onTap: () {
                              // TODO: Implementar toggle de favorito
                            },
                          ),
                        ],
                      ),

                      DSSizedBoxSpacing.vertical(16),

                      // Bio completa
                      if (artist.professionalInfo?.bio != null) ...[
                        Text(
                          artist.professionalInfo!.bio!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        DSSizedBoxSpacing.vertical(24),
                      ],

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
          ),

          // Footer fixo
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ArtistFooter(
              onRequestPressed: () => _onRequestPressed(context),
            ),
          ),
        ],
      ),
    );
  }
}

