import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/artists/presentation/widgets/artist_area_option_card.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage(deferredLoading: true)
class EnsembleAreaScreen extends StatelessWidget {
  final String ensembleId;

  const EnsembleAreaScreen({super.key, required this.ensembleId});

  /// Dados mockados do conjunto (por id)
  static EnsembleEntity _mockEnsemble(String id) {
    return EnsembleEntity(
      id: id,
      ownerArtistId: 'artist1',
      profilePhotoUrl: null,
      professionalInfo: null,
      members: _mockMembers(id),
      presentationVideoUrl: null,
      isActive: true,
      allMembersApproved: false,
      hasIncompleteSections: true,
      incompleteSections: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static List<EnsembleMemberEntity> _mockMembers(String ensembleId) {
    return [
      EnsembleMemberEntity(
        id: 'm1',
        ensembleId: ensembleId,
        isOwner: true,
        artistId: 'artist1',
        name: 'Eu (Dono)',
        isApproved: true,
      ),
      EnsembleMemberEntity(
        id: 'm2',
        ensembleId: ensembleId,
        isOwner: false,
        name: 'Maria Silva',
        email: 'maria@email.com',
        isApproved: true,
      ),
      EnsembleMemberEntity(
        id: 'm3',
        ensembleId: ensembleId,
        isOwner: false,
        name: 'João Santos',
        email: 'joao@email.com',
        isApproved: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ensemble = _mockEnsemble(ensembleId);
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    final displayName = ensemble.professionalInfo?.bio != null &&
            ensemble.professionalInfo!.bio!.isNotEmpty
        ? ensemble.professionalInfo!.bio!
        : 'Conjunto ${ensemble.id ?? ''}';

    final hasIncompleteProfessionalInfo = ensemble.incompleteSections != null &&
        ensemble.incompleteSections!.values.any(
          (types) => types.contains('professionalInfo'),
        );
    final membersCount = ensemble.members?.length ?? 0;

    return BasePage(
      showAppBar: true,
      appBarTitle: displayName.length > 24
          ? '${displayName.substring(0, 24)}...'
          : displayName,
      showAppBarBackButton: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DSSizedBoxSpacing.vertical(16),
            ProfileHeader(
              imageUrl: ensemble.profilePhotoUrl,
              name: displayName,
              isArtist: false,
              isGroup: true,
              onProfilePictureTap: () {},
            ),
            DSSizedBoxSpacing.vertical(24),
            ArtistAreaOptionCard(
              title: 'Integrantes',
              description:
                  'Gerencie os integrantes do conjunto ($membersCount cadastrado${membersCount == 1 ? '' : 's'}).',
              icon: Icons.people_outline_rounded,
              iconColor: onPrimaryContainer,
              hasIncompleteInfo: (ensemble.allMembersApproved ?? false) ? false : true,
              onTap: () {
                context.router.push(EnsembleMembersRoute(ensembleId: ensembleId));
              },
            ),
            DSSizedBoxSpacing.vertical(8),
            ArtistAreaOptionCard(
              title: 'Dados Profissionais',
              description: 'Defina as informações de apresentação do conjunto.',
              icon: Icons.work_outline_rounded,
              iconColor: onPrimaryContainer,
              hasIncompleteInfo: hasIncompleteProfessionalInfo,
              onTap: () {
                // TODO: navegação para tela de dados profissionais do conjunto
              },
            ),
            DSSizedBoxSpacing.vertical(8),
            ArtistAreaOptionCard(
              title: 'Apresentações',
              description: 'Adicione o vídeo de apresentação do conjunto (até 1 min).',
              icon: Icons.video_library_outlined,
              iconColor: onPrimaryContainer,
              hasIncompleteInfo: ensemble.hasIncompleteSections ?? false,
              onTap: () {
                context.router.push(EnsemblePresentationsRoute());
              },
            ),
            
            DSSizedBoxSpacing.vertical(8),

            ArtistAreaOptionCard(
              title: 'Disponibilidade',
              description: 'Defina horários e raio de atuação do conjunto.',
              icon: Icons.calendar_today_outlined,
              iconColor: onPrimaryContainer,
              onTap: () {
                // TODO: navegação para disponibilidade do conjunto
              },
            ),
            DSSizedBoxSpacing.vertical(8),
            ArtistAreaOptionCard(
              title: 'Minha Página',
              description: 'Visualize como a página do conjunto aparece para os clientes.',
              icon: Icons.person_outline_rounded,
              iconColor: onPrimaryContainer,
              onTap: () {
                // TODO: navegação para visualização da página do conjunto
              },
            ),
            
            DSSizedBoxSpacing.vertical(24),
          ],
        ),
      ),
    );
  }
}
