import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/domain/artist/artist_groups/group_member_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/artists/groups/presentation/bloc/events/groups_events.dart';
import 'package:app/features/profile/artists/groups/presentation/bloc/groups_bloc.dart';
import 'package:app/features/profile/artists/groups/presentation/bloc/states/groups_states.dart';
import 'package:app/features/profile/artists/groups/presentation/widgets/create_group_modal.dart';
import 'package:app/features/profile/artists/groups/presentation/widgets/group_card.dart';
import 'package:app/features/profile/artists/groups/presentation/widgets/group_invite_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _currentArtistUid; // UID do artista atual
  List<GroupEntity> _myGroups = [];
  List<GroupEntity> _pendingInvites = []; // Grupos com convites pendentes
  Map<String, String> _inviteInvitedBy = {}; // UID do grupo -> nome de quem convidou

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Buscar grupos ao carregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleGetGroups();
    });
    _loadPendingInvites();
  }

  void _onTabChanged() {
    setState(() {}); // Atualiza para mostrar/esconder FAB
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleGetGroups({bool forceRefresh = false}) {
    if (!mounted) return;
    final groupsBloc = context.read<GroupsBloc>();
    // Buscar apenas se não tiver dados carregados ou se forçado a atualizar
    if (forceRefresh || groupsBloc.state is! GetGroupsSuccess) {
      groupsBloc.add(GetGroupsEvent());
    }
  }

  void _loadPendingInvites() {
    // TODO: Carregar convites pendentes
    final invite1 = GroupEntity(
      uid: 'invite1',
      groupName: 'Grupo de Jazz',
      profilePicture: null,
      dateRegistered: DateTime.now().subtract(const Duration(days: 5)),
      members: [
        GroupMemberEntity(
          artistUid: 'admin_artist_uid',
          isAdmin: true,
          isApproved: true,
        ),
      ],
      isActive: true,
    );
    
    setState(() {
      _pendingInvites = [invite1];
      _inviteInvitedBy = {
        'invite1': 'João Silva', // Nome de quem convidou (admin do grupo)
      };
    });
  }

  void _showCreateGroupModal() {
    CreateGroupModal.show(
      context: context,
      onCreate: (group, imageFile, emails) {
        if (!mounted) return;
        final groupsBloc = context.read<GroupsBloc>();
        // Disparar evento para adicionar grupo
        groupsBloc.add(AddGroupEvent(group: group));
      },
    );
  }

  /// Verifica se o artista atual é administrador do grupo
  bool _isCurrentArtistAdmin(GroupEntity group) {
    if (_currentArtistUid == null || group.members == null) return false;
    
    final currentMember = group.members!.firstWhere(
      (member) => member.artistUid == _currentArtistUid,
      orElse: () => GroupMemberEntity(isAdmin: false),
    );
    
    return currentMember.isAdmin;
  }

  void _onAcceptInvite(GroupEntity group) {
    setState(() {
      _pendingInvites.remove(group);
      _inviteInvitedBy.remove(group.uid);
      _myGroups.add(group);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Convite para ${group.groupName} aceito!')),
    );
    // TODO: Implementar aceitação via Bloc/Repository
  }

  void _onRejectInvite(GroupEntity group) {
    setState(() {
      _pendingInvites.remove(group);
      _inviteInvitedBy.remove(group.uid);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Convite para ${group.groupName} recusado.')),
    );
    // TODO: Implementar recusa via Bloc/Repository
  }

  void _onGroupTap(GroupEntity group) {
    final router = AutoRouter.of(context);
    router.push(GroupAreaRoute(group: group));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<GroupsBloc, GroupsState>(
      listener: (context, state) {
        if (state is GetGroupsSuccess) {
          setState(() {
            _myGroups = state.groups;
          });
        } else if (state is GetGroupsFailure) {
          context.showError(state.error);
        } else if (state is AddGroupSuccess) {
          // Recarregar grupos após adicionar
          _handleGetGroups(forceRefresh: true);
          context.showSuccess('Grupo criado com sucesso!');
        } else if (state is AddGroupFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          return BasePage(
      showAppBar: true,
      appBarTitle: 'Conjuntos',
      showAppBarBackButton: true,
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showCreateGroupModal,
              backgroundColor: colorScheme.onPrimaryContainer,
              foregroundColor: colorScheme.primaryContainer,
              child: const Icon(Icons.add),
            )
          : null,
      child: Column(
        children: [
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.onPrimaryContainer,
            labelStyle: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.onPrimaryContainer,
            tabs: const [
              Tab(text: 'Meus Grupos'),
              Tab(text: 'Convites'),
            ],
          ),
          DSSizedBoxSpacing.vertical(16),

          // Conteúdo das tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyGroupsTab(colorScheme, textTheme),
                _buildInvitesTab(colorScheme, textTheme),
              ],
            ),
          ),
        ],
      ),
          );
        },
      ),
    );
  }

  Widget _buildMyGroupsTab(ColorScheme colorScheme, TextTheme textTheme) {
    if (_myGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            DSSizedBoxSpacing.vertical(16),
            Text(
              'Nenhum grupo encontrado',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            DSSizedBoxSpacing.vertical(8),
            Text(
              'Toque no botão + para criar um novo grupo',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: _myGroups.length,
      itemBuilder: (context, index) {
        final group = _myGroups[index];
        final isAdmin = _isCurrentArtistAdmin(group);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GroupCard(
            group: group,
            isAdmin: isAdmin,
            onTap: () => _onGroupTap(group),
          ),
        );
      },
    );
  }

  Widget _buildInvitesTab(ColorScheme colorScheme, TextTheme textTheme) {
    if (_pendingInvites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            DSSizedBoxSpacing.vertical(16),
            Text(
              'Nenhum convite pendente',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            DSSizedBoxSpacing.vertical(8),
            Text(
              'Quando você receber convites para grupos,\neles aparecerão aqui',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: _pendingInvites.length,
      itemBuilder: (context, index) {
        final invite = _pendingInvites[index];
        final invitedBy = _inviteInvitedBy[invite.uid];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GroupInviteCard(
            group: invite,
            invitedBy: invitedBy,
            onAccept: () => _onAcceptInvite(invite),
            onReject: () => _onRejectInvite(invite),
          ),
        );
      },
    );
  }
}

