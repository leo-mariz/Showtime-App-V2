import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_member.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/confirmation_dialog.dart';
import 'package:app/core/shared/widgets/options_modal.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:app/features/ensemble/ensemble/presentation/screens/new_ensemble_modal.dart';
import 'package:app/features/ensemble/ensemble/presentation/widgets/empty_ensembles_placeholder.dart';
import 'package:app/features/ensemble/ensemble/presentation/widgets/ensemble_card.dart';
import 'package:app/features/ensemble/members/presentation/bloc/events/members_events.dart';
import 'package:app/features/ensemble/members/presentation/bloc/members_bloc.dart';
import 'package:app/features/ensemble/members/presentation/bloc/states/members_states.dart';
import 'package:app/features/artists/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/artists/artists/presentation/bloc/states/artists_states.dart';
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
    context.read<MembersBloc>().add(GetAllMembersEvent(forceRemote: false));
  }

  void _onGetAllEnsembles() {
    final currentState = context.read<EnsembleBloc>().state;
    if (currentState is! GetAllEnsemblesSuccess) {
      context.read<EnsembleBloc>().add(GetAllEnsemblesByArtistEvent());
    } else {
      final ensembles = currentState.ensembles;
      if (ensembles.isEmpty) {
        context.read<EnsembleBloc>().add(GetAllEnsemblesByArtistEvent(forceRemote: false));
      }
    }
  }

  void _onAddEnsemble() async {
    final selected = await NewEnsembleModal.show(context: context);
    if (selected != null && mounted) {
      final slots = selected
          .where((e) => e.id != null && e.id!.isNotEmpty)
          .map((e) => EnsembleMember(
                memberId: e.id!,
                specialty: e.specialty,
                isOwner: false,
              ))
          .toList();
      context.read<EnsembleBloc>().add(CreateEnsembleEvent(members: slots));
    }
  }

  void _onEditEnsemble(EnsembleEntity ensemble) {
    AutoRouter.of(context).push(EnsembleAreaRoute(ensembleId: ensemble.id ?? ''));
  }

  void _onDeleteEnsemble(EnsembleEntity ensemble) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Excluir conjunto',
        message: 'Tem certeza que deseja excluir este conjunto? Esta ação não pode ser desfeita.',
        confirmText: 'Excluir',
        cancelText: 'Cancelar',
        confirmButtonColor: Theme.of(context).colorScheme.error,
        confirmButtonTextColor: Theme.of(context).colorScheme.onError,
        onConfirm: () {
          AutoRouter.of(context).maybePop();
          context.read<EnsembleBloc>().add(DeleteEnsembleEvent(ensembleId: ensemble.id ?? ''));
        },
      ),
    );
  }

  void _showOptionsModalFor(BuildContext context, EnsembleEntity ensemble) {
    final actions = <OptionsModalAction>[
      OptionsModalAction(
        label: 'Editar',
        icon: Icons.edit,
        onPressed: () {
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
          _onDeleteEnsemble(ensemble);
        },
      ),
    ];
    OptionsModal.show(context: context, title: 'Conjunto +${_totalMembersCount(ensemble)}', actions: actions);
  }

  String _getArtistName() {
    final state = context.read<ArtistsBloc>().state;
    if (state is GetArtistSuccess) {
      return state.artist.artistName ?? 'Artista';
    }
    return 'Artista';
  }

  /// Total de integrantes (apenas os que não são dono).
  int _totalMembersCount(EnsembleEntity e) {
    final members = e.members ?? [];
    return members.where((m) => !m.isOwner).length;
  }

  /// Primeiros nomes dos integrantes que não são dono, resolvidos via [memberIdToName], separados por vírgula.
  String? _membersFirstNames(EnsembleEntity e, Map<String, String> memberIdToName) {
    final members = e.members ?? [];
    final names = <String>[];
    for (final m in members) {
      if (m.isOwner) continue;
      final full = memberIdToName[m.memberId]?.trim();
      if (full == null || full.isEmpty) continue;
      final first = full.split(RegExp(r'\s+')).first;
      if (first.isNotEmpty) names.add(first);
    }
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  /// Título do card: apenas "Nome + num" (sem a palavra "integrantes").
  String _ensembleDisplayName(EnsembleEntity e) {
    final artistName = _getArtistName();
    final total = _totalMembersCount(e);
    return '$artistName + $total';
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
        if (state is EnsembleInitial) {
          _onGetAllEnsembles();
        }
        if (state is GetAllEnsemblesFailure) {
          context.showError(state.error);
        }
        if (state is CreateEnsembleSuccess) {
          context.read<EnsembleBloc>().add(GetAllEnsemblesByArtistEvent(forceRemote: false));
          context.read<MembersBloc>().add(GetAllMembersEvent(forceRemote: false));
        }
        if (state is CreateEnsembleFailure) {
          context.showError(state.error);
        }
        if (state is DeleteEnsembleSuccess) {
          context.read<EnsembleBloc>().add(GetAllEnsemblesByArtistEvent(forceRemote: false));
        }
        if (state is DeleteEnsembleFailure) {
          context.showError(state.error);
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
        child: BlocBuilder<MembersBloc, MembersState>(
          buildWhen: (previous, current) => current is GetAllMembersSuccess || current is GetAllMembersLoading,
          builder: (context, membersState) {
            final memberIdToName = membersState is GetAllMembersSuccess
                ? {
                    for (final m in membersState.members)
                      if (m.id != null && m.name != null && m.name!.trim().isNotEmpty)
                        m.id!: m.name!,
                  }
                : <String, String>{};
            return BlocBuilder<EnsembleBloc, EnsembleState>(
              builder: (context, state) {
                if (state is GetAllEnsemblesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final ensembles = state is GetAllEnsemblesSuccess
                    ? state.ensembles
                    : null;
                if (ensembles != null) {
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
                            return Padding(
                              padding: EdgeInsets.only(bottom: DSSize.height(12)),
                              child: EnsembleCard(
                                displayName: _ensembleDisplayName(e),
                                photoUrl: e.profilePhotoUrl,
                                membersFirstNames: _membersFirstNames(e, memberIdToName),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
