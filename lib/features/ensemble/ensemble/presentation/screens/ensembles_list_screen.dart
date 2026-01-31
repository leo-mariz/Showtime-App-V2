import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/options_modal.dart';
import 'package:app/features/ensemble/ensemble/domain/inputs/create_ensemble_input.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:app/features/ensemble/ensemble/presentation/screens/new_ensemble_modal.dart';
import 'package:app/features/ensemble/ensemble/presentation/widgets/empty_ensembles_placeholder.dart';
import 'package:app/features/ensemble/ensemble/presentation/widgets/ensemble_card.dart';
import 'package:app/features/ensemble/members/domain/entities/ensemble_member_input.dart';
import 'package:app/features/ensemble/members/presentation/bloc/events/members_events.dart';
import 'package:app/features/ensemble/members/presentation/bloc/members_bloc.dart';
import 'package:app/features/ensemble/members/presentation/bloc/states/members_states.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class EnsemblesListScreen extends StatefulWidget {
  const EnsemblesListScreen({super.key});

  @override
  State<EnsemblesListScreen> createState() => _EnsemblesListScreenState();
}

class _EnsemblesListScreenState extends State<EnsemblesListScreen> {
  @override
  void initState() {
    super.initState();
    _onGetAllEnsembles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onGetAllEnsembles();
    _onLoadAvailableMembers();
  }

  void _onGetAllEnsembles() {
    final currentState = context.read<EnsembleBloc>().state;
    if (currentState is! GetAllEnsemblesSuccess) {
      context.read<EnsembleBloc>().add(GetAllEnsemblesByArtistEvent());
    }
  }

  void _onLoadAvailableMembers() {
    final membersState = context.read<MembersBloc>().state;
    if (membersState is! GetAvailableMembersSuccess) {
      context.read<MembersBloc>().add(GetAvailableMembersForNewEnsembleEvent());
    }
  }

  /// Lista de integrantes disponíveis para o modal (obtida do MembersBloc).
  List<EnsembleMemberEntity> _getAvailableMembersForNewEnsemble() {
    final membersState = context.read<MembersBloc>().state;
    if (membersState is GetAvailableMembersSuccess) {
      return membersState.members;
    }
    return [];
  }

  void _onAddEnsemble() async {
    final availableMembers = _getAvailableMembersForNewEnsemble();
    final selected = await NewEnsembleModal.show(
      context: context,
      availableMembers: availableMembers,
    );
    if (selected != null && mounted) {
      final input = CreateEnsembleInput(
        members: selected
            .map((m) => EnsembleMemberInput(
                  name: m.name ?? '',
                  cpf: m.cpf ?? '',
                  email: m.email ?? '',
                ))
            .toList(),
      );
      context.read<EnsembleBloc>().add(CreateEnsembleEvent(input: input));
    }
  }

  void _onEditEnsemble(EnsembleEntity ensemble) {
    AutoRouter.of(context).push(EnsembleAreaRoute(ensembleId: ensemble.id ?? ''));
  }

  void _onDeleteEnsemble(EnsembleEntity ensemble) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir conjunto', style: Theme.of(context).textTheme.titleMedium),
        content: const Text(
          'Tem certeza que deseja excluir este conjunto? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<EnsembleBloc>().add(DeleteEnsembleEvent(ensembleId: ensemble.id ?? ''));
            },
            child: Text('Excluir', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showOptionsModalFor(BuildContext context, EnsembleEntity ensemble) {
    final actions = <OptionsModalAction>[
      OptionsModalAction(
        label: 'Editar',
        icon: Icons.edit,
        onPressed: () {
          Navigator.of(context).pop();
          _onEditEnsemble(ensemble);
        },
      ),
      OptionsModalAction(
        label: 'Excluir',
        icon: Icons.delete,
        backgroundColor: Theme.of(context).colorScheme.error,
        textColor: Theme.of(context).colorScheme.onError,
        iconColor: Theme.of(context).colorScheme.onError,
        onPressed: () {
          Navigator.of(context).pop();
          _onDeleteEnsemble(ensemble);
        },
      ),
    ];
    OptionsModal.show(context: context, title: 'Opções', actions: actions);
  }

  String _getArtistName() {
    final state = context.read<ArtistsBloc>().state;
    if (state is GetArtistSuccess) {
      return state.artist.artistName ?? 'Artista';
    }
    return 'Artista';
  }

  String _ensembleDisplayName(EnsembleEntity e) {
    final artistName = _getArtistName();
    final membersCount = e.members?.length ?? 0;
    return '$artistName + $membersCount';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnsembleBloc, EnsembleState>(
      listenWhen: (previous, current) =>
          current is GetAllEnsemblesFailure ||
          current is CreateEnsembleSuccess ||
          current is CreateEnsembleFailure ||
          current is DeleteEnsembleSuccess ||
          current is DeleteEnsembleFailure,
      listener: (context, state) {
        if (state is GetAllEnsemblesFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
        if (state is CreateEnsembleSuccess) {
          context.read<EnsembleBloc>().add(GetAllEnsemblesByArtistEvent(forceRemote: true));
          context.read<MembersBloc>().add(GetAvailableMembersForNewEnsembleEvent(forceRemote: true));
        }
        if (state is CreateEnsembleFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
        if (state is DeleteEnsembleSuccess) {
          context.read<EnsembleBloc>().add(GetAllEnsemblesByArtistEvent(forceRemote: true));
        }
        if (state is DeleteEnsembleFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: BasePage(
        showAppBar: true,
        appBarTitle: 'Meus Conjuntos',
        showAppBarBackButton: true,
        floatingActionButton: FloatingActionButton(
          onPressed: _onAddEnsemble,
          child: const Icon(Icons.add),
        ),
        child: BlocBuilder<EnsembleBloc, EnsembleState>(
          builder: (context, state) {
            if (state is GetAllEnsemblesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GetAllEnsemblesSuccess) {
              final ensembles = state.ensembles;
              final isEmpty = ensembles.isEmpty;
              if (isEmpty) {
                return EmptyEnsemblesPlaceholder(
                  message: 'Você ainda não possui conjuntos cadastrados.',
                  buttonLabel: 'Adicionar conjunto',
                  onButtonPressed: _onAddEnsemble,
                );
              }
              return Column(
                children: [
                  DSSizedBoxSpacing.vertical(16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ensembles.length,
                      itemBuilder: (context, index) {
                        final e = ensembles[index];
                        final membersCount = e.members?.length ?? 0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: DSSize.height(12)),
                          child: EnsembleCard(
                            displayName: _ensembleDisplayName(e),
                            photoUrl: e.profilePhotoUrl,
                            membersCount: membersCount,
                            allApproved: e.allMembersApproved ?? false,
                            onTap: () => _onEditEnsemble(e),
                            onOptionsTap: () => _showOptionsModalFor(context, e),
                          ),
                        );
                      },
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(16),
                ],
              );
            }
            // EnsembleInitial ou GetAllEnsemblesFailure (após emitir Initial)
            return EmptyEnsemblesPlaceholder(
              message: 'Você ainda não possui conjuntos cadastrados.',
              // buttonLabel: 'Adicionar conjunto',
              // onButtonPressed: _onAddEnsemble,
            );
          },
        ),
      ),
    );
  }
}
