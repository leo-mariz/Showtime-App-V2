
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/presentation/widgets/artist_area_option_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opção: Dados Profissionais
            ArtistAreaOptionCard(
              title: 'Dados Profissionais',
              description: 'Defina as informações de sua apresentação.',
              icon: Icons.work_outline_rounded,
              iconColor: onPrimaryContainer,
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
              onTap: () {
                // TODO: Obter talentos do artista atual do professionalInfo.specialty
                // Por enquanto, usando lista mockada
                final talents = ['Cantor', 'Guitarrista'];
                router.push(PresentationsRoute(talents: talents));
              },
            ),

            DSSizedBoxSpacing.vertical(8),

            // Opção: Disponibilidade
            ArtistAreaOptionCard(
              title: 'Disponibilidade',
              description: 'Abra ou feche datas para disponibilidade de shows.',
              icon: Icons.calendar_today_outlined,
              iconColor: onPrimaryContainer,
              onTap: () {
                router.push(const AvailabilityRoute());
              },
            ),

            DSSizedBoxSpacing.vertical(8),

            // Opção: Endereços
            ArtistAreaOptionCard(
              icon: Icons.location_on_outlined,
              title: 'Endereços',
              description: 'Defina os seus endereços.',
              iconColor: onPrimaryContainer,
              onTap: () {},
            ),

            DSSizedBoxSpacing.vertical(8),

            // Opção: Minha página do artista
            ArtistAreaOptionCard(
              title: 'Minha Página',
              description: 'Visualize como sua página aparece para os clientes',
              icon: Icons.person_outline_rounded,
              iconColor: onPrimaryContainer,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

