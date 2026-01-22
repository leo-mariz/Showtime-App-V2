import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/artists/presentation/widgets/artist_area_option_card.dart';
import 'package:app/features/profile/groups/presentation/bloc/events/groups_events.dart';
import 'package:app/features/profile/groups/presentation/bloc/groups_bloc.dart';
import 'package:app/features/profile/groups/presentation/bloc/states/groups_states.dart';
import 'package:app/features/profile/groups/presentation/widgets/group_header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class GroupAreaScreen extends StatefulWidget {
  final GroupEntity group;

  const GroupAreaScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupAreaScreen> createState() => _GroupAreaScreenState();
}

class _GroupAreaScreenState extends State<GroupAreaScreen> {
  @override
  void initState() {
    super.initState();
    // Buscar dados do grupo ao carregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleGetGroup();
    });
  }

  void _handleGetGroup({bool forceRefresh = false}) {
    if (!mounted) return;
    final groupsBloc = context.read<GroupsBloc>();
    final groupUid = widget.group.uid;
    
    if (groupUid == null || groupUid.isEmpty) {
      return;
    }
    
    // Buscar apenas se não tiver dados carregados ou se forçado a atualizar
    if (forceRefresh || groupsBloc.state is! GetGroupSuccess) {
      groupsBloc.add(GetGroupEvent(groupUid: groupUid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    return BlocListener<GroupsBloc, GroupsState>(
      listener: (context, state) {
        if (state is GetGroupFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          // Usar grupo do estado se disponível, senão usar o grupo inicial
          final currentGroup = state is GetGroupSuccess
              ? state.group
              : widget.group;

          return BasePage(
            showAppBar: true,
            appBarTitle: 'Área do Grupo',
            showAppBarBackButton: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Header
                  GroupHeader(
                    name: currentGroup.groupName ?? 'Grupo',
                    imageUrl: currentGroup.profilePicture,
                    onProfilePictureTap: () {
                      context.showError('Funcionalidade em desenvolvimento');
                    },
                    onEditName: () {
                      context.showError('Funcionalidade em desenvolvimento');
                    },
                  ),

                  DSSizedBoxSpacing.vertical(24),

                  // Opção: Dados Profissionais
                  ArtistAreaOptionCard(
                    title: 'Dados Profissionais',
                    description: 'Defina as informações de apresentação do grupo.',
                    icon: Icons.work_outline_rounded,
                    iconColor: onPrimaryContainer,
                    onTap: () {
                      // TODO: Navegar para dados profissionais do grupo
                      context.showError('Funcionalidade em desenvolvimento');
                    },
                  ),

                  DSSizedBoxSpacing.vertical(8),

                  // Opção: Apresentações
                  ArtistAreaOptionCard(
                    title: 'Apresentações',
                    description: 'Adicione vídeos para mostrar ao mundo o trabalho do grupo.',
                    icon: Icons.video_library_outlined,
                    iconColor: onPrimaryContainer,
                    onTap: () {
                      // TODO: Navegar para apresentações do grupo
                        context.showError('Funcionalidade em desenvolvimento');
                    },
                  ),

                  DSSizedBoxSpacing.vertical(8),

                  // Opção: Disponibilidade
                  ArtistAreaOptionCard(
                    title: 'Disponibilidade',
                    description: 'Abra ou feche datas para disponibilidade de shows do grupo.',
                    icon: Icons.calendar_today_outlined,
                    iconColor: onPrimaryContainer,
                    onTap: () {
                      // TODO: Navegar para disponibilidade do grupo
                      context.showError('Funcionalidade em desenvolvimento');
                    },
                  ),

                  DSSizedBoxSpacing.vertical(8),

                  // Opção: Minha página do grupo
                  ArtistAreaOptionCard(
                    title: 'Minha Página',
                    description: 'Visualize como a página do grupo aparece para os clientes',
                    icon: Icons.person_outline_rounded,
                    iconColor: onPrimaryContainer,
                    onTap: () {
                      // TODO: Navegar para visualização da página do grupo
                      context.showError('Funcionalidade em desenvolvimento');
                    },
                  ),

                  DSSizedBoxSpacing.vertical(8),

                  // Opção: Integrantes
                  ArtistAreaOptionCard(
                    title: 'Integrantes',
                    description: 'Gerencie os membros do grupo e convide novos artistas.',
                    icon: Icons.people_outline,
                    iconColor: onPrimaryContainer,
                    onTap: () {
                      // TODO: Navegar para gestão de integrantes
                      context.showError('Funcionalidade em desenvolvimento');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
