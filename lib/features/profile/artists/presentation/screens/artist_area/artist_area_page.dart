
import 'package:app/core/config/auto_router_config.gr.dart';
// import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/artists/domain/enums/artist_incomplete_info_type_enum.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:app/features/profile/artists/presentation/widgets/artist_area_option_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class ArtistAreaScreen extends StatelessWidget {
  const ArtistAreaScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final router = AutoRouter.of(context);

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Área do Artista',
      showAppBarBackButton: true,
      child: BlocBuilder<ArtistsBloc, ArtistsState>(
        builder: (context, artistsState) {
          final artist = artistsState is GetArtistSuccess ? artistsState.artist : null;
          
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
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSizedBoxSpacing.vertical(16),
            
                // Opção: Dados Profissionais
                ArtistAreaOptionCard(
                  title: 'Dados Profissionais',
                  description: 'Defina as informações de sua apresentação.',
                  icon: Icons.work_outline_rounded,
                  iconColor: onPrimaryContainer,
                  hasIncompleteInfo: _isSectionIncomplete(ArtistIncompleteInfoType.professionalInfo),
                  onTap: () {
                    router.push(const ProfessionalInfoRoute());
                  },
                ),

                DSSizedBoxSpacing.vertical(8),

                // Opção: Apresentações
                ArtistAreaOptionCard(
                  title: 'Apresentações',
                  description: 'Adicione vídeos para mostrar ao mundo o seu trabalho.',
                  icon: Icons.video_library_outlined,
                  iconColor: onPrimaryContainer,
                  hasIncompleteInfo: _isSectionIncomplete(ArtistIncompleteInfoType.presentations),
                  onTap: () {
                    router.push(PresentationsRoute());
                  },
                ),
                


            DSSizedBoxSpacing.vertical(8),

            // Opção: Minha página do artista
            ArtistAreaOptionCard(
              title: 'Minha Página',
              description: 'Visualize como sua página aparece para os clientes',
              icon: Icons.person_outline_rounded,
              iconColor: onPrimaryContainer,
              onTap: () => router.push(ArtistExploreRoute(artist: artist!, viewOnly: true)),
            ),

            DSSizedBoxSpacing.vertical(8),

            // ProfileVisibilityCard(
            //   isActive: false, // TODO: Buscar do estado/bloc
            //   isEnabled: false, // TODO: Verificar se todos os campos obrigatórios estão preenchidos
            //   blockingReason: 'Complete seu perfil para ativar a visibilidade. Preencha todas as informações obrigatórias em "Dados Profissionais".',
            //   onChanged: (value) {
            //     // TODO: Implementar lógica para ativar/desativar perfil
            //   },
            // ),
              ],
            ),
          );
        },
      ),
    );
  }
}

