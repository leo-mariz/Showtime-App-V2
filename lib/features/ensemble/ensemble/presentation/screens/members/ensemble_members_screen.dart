import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_member.dart';
import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/ensemble/member_documents/presentation/bloc/events/member_documents_events.dart';
import 'package:app/features/ensemble/member_documents/presentation/bloc/member_documents_bloc.dart';
import 'package:app/features/ensemble/member_documents/presentation/bloc/states/member_documents_states.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/confirmation_dialog.dart';
import 'package:app/core/shared/widgets/select_talents_sheet.dart';
import 'package:app/features/app_lists/presentation/bloc/app_lists_bloc.dart';
import 'package:app/features/app_lists/presentation/bloc/events/app_lists_events.dart';
import 'package:app/features/app_lists/presentation/bloc/states/app_lists_states.dart';
import 'package:app/features/artists/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/artists/artists/presentation/bloc/states/artists_states.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:app/features/ensemble/members/presentation/bloc/events/members_events.dart';
import 'package:app/features/ensemble/members/presentation/bloc/members_bloc.dart';
import 'package:app/features/ensemble/members/presentation/bloc/states/members_states.dart';
import 'package:app/features/ensemble/members/presentation/widgets/empty_members_placeholder.dart';
import 'package:app/features/ensemble/members/presentation/screens/member_modal.dart';
import 'package:app/features/ensemble/members/presentation/widgets/member_with_documents_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class EnsembleMembersScreen extends StatefulWidget {
  final String ensembleId;

  const EnsembleMembersScreen({super.key, required this.ensembleId});

  @override
  State<EnsembleMembersScreen> createState() => _EnsembleMembersScreenState();
}

class _EnsembleMembersScreenState extends State<EnsembleMembersScreen> {
  /// Slot do integrante cujos talentos vamos editar (aguardando GetTalentsSuccess).
  EnsembleMember? _pendingSlotForTalents;
  /// Nome do integrante para o título do sheet de talentos.
  String? _pendingSlotDisplayName;
  /// Documentos por memberId (carregados via MemberDocumentsBloc).
  Map<String, List<MemberDocumentEntity>> _documentsByMember = {};
  /// Índice do próximo integrante a carregar documentos (carregamento sequencial).
  int _loadingMemberIndex = 0;
  /// IDs dos integrantes (não-dono) para carregar documentos.
  List<String>? _memberIdsToLoad;
  /// memberId cujo carregamento acabou de retornar (para associar ao success).
  String? _loadingMemberId;
  /// true quando estamos refrescando um único integrante (ex.: ao voltar da tela de documentos).
  bool _isRefreshingOneMember = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<EnsembleBloc>().add(GetEnsembleByIdEvent(ensembleId: widget.ensembleId));
    context.read<MembersBloc>().add(GetAllMembersEvent(forceRemote: false));
  }

  void _onRemoveMember(EnsembleEntity ensemble, EnsembleMember slot, String displayName) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Remover integrante',
        message:
            'Tem certeza que deseja remover $displayName do conjunto?',
        confirmText: 'Remover',
        cancelText: 'Cancelar',
        confirmButtonColor: Theme.of(context).colorScheme.error,
        confirmButtonTextColor: Theme.of(context).colorScheme.onError,
        onConfirm: () {
          Navigator.of(ctx).pop();
          final current = ensemble.members ?? [];
          final newList = current.where((m) => m.memberId != slot.memberId).toList();
          context.read<EnsembleBloc>().add(
                UpdateEnsembleEvent(ensemble: ensemble.copyWith(members: newList)),
              );
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _onDocumentsTap(EnsembleMember slot) {
    final memberId = slot.memberId;
    if (memberId.isEmpty) return;
    final router = AutoRouter.of(context);
    router.push(MemberDocumentsRoute(ensembleId: widget.ensembleId, memberId: memberId)).then((_) {
      if (!mounted) return;
      setState(() => _documentsByMember.remove(memberId));
      _loadingMemberId = memberId;
      _isRefreshingOneMember = true;
      context.read<MemberDocumentsBloc>().add(
        GetAllMemberDocumentsEvent(
          ensembleId: widget.ensembleId,
          memberId: memberId,
          forceRemote: false,
        ),
      );
    });
  }

  void _onEditTalentsTap(EnsembleMember slot, EnsembleMemberEntity? detail) {
    setState(() {
      _pendingSlotForTalents = slot;
      _pendingSlotDisplayName = detail?.name;
    });
    context.read<AppListsBloc>().add(GetTalentsEvent());
  }

  void _showEditTalentsSheetWithList(
    BuildContext context,
    EnsembleMember slot,
    String displayName,
    List<String> talentNames,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocConsumer<EnsembleBloc, EnsembleState>(
        listenWhen: (previous, current) =>
            current is UpdateEnsembleMemberTalentsSuccess ||
            current is UpdateEnsembleMemberTalentsFailure,
        listener: (ctx, state) {
          if (state is UpdateEnsembleMemberTalentsSuccess) {
            Navigator.of(ctx).pop();
            if (context.mounted) {
              context.showSuccess('Talentos atualizados.');
            }
          }
          if (state is UpdateEnsembleMemberTalentsFailure) {
            if (context.mounted) {
              context.showError(state.error);
            }
          }
        },
        buildWhen: (previous, current) =>
            current is UpdateEnsembleMemberTalentsLoading ||
            current is UpdateEnsembleMemberTalentsSuccess ||
            current is UpdateEnsembleMemberTalentsFailure ||
            current is GetAllEnsemblesSuccess,
        builder: (ctx, state) => SelectTalentsSheet(
          title: 'Talentos de $displayName',
          subtitle: 'Selecione os talentos deste integrante neste conjunto. O mesmo integrante pode ter talentos diferentes em outros conjuntos.',
          talentNames: talentNames,
          initialSelected: slot.specialty ?? [],
          loading: state is UpdateEnsembleMemberTalentsLoading,
          confirmButtonLabel: 'Salvar',
          onConfirm: (selected) {
            context.read<EnsembleBloc>().add(
              UpdateEnsembleMemberTalentsEvent(
                ensembleId: widget.ensembleId,
                memberId: slot.memberId,
                talents: selected,
              ),
            );
          },
        ),
      ),
    );
  }

  void _reloadEnsemble() {
    context.read<EnsembleBloc>().add(
          GetEnsembleByIdEvent(ensembleId: widget.ensembleId, forceRefresh: false),
        );
  }

  void _onAddMemberTap() {
    final ensembleState = context.read<EnsembleBloc>().state;
    final currentEnsemble = ensembleState is GetAllEnsemblesSuccess
        ? ensembleState.currentEnsemble
        : null;
    final membersState = context.read<MembersBloc>().state;
    final allMembers = membersState is GetAllMembersSuccess
        ? membersState.members
        : <EnsembleMemberEntity>[];
    final memberDetailsById = {
      for (final m in allMembers) if (m.id != null) m.id!: m
    };
    final isThisEnsemble = currentEnsemble?.id == widget.ensembleId;
    final slots = isThisEnsemble
        ? (currentEnsemble!.members ?? []).where((m) => !m.isOwner).toList()
        : <EnsembleMember>[];
    final initialSelected = slots
        .map((s) => memberDetailsById[s.memberId])
        .whereType<EnsembleMemberEntity>()
        .toList();
    final initialSelectedIds = slots.map((s) => s.memberId).toSet();
    _openAddMemberModal(
      initialSelected: initialSelected,
      initialSelectedIds: initialSelectedIds,
      currentEnsemble: isThisEnsemble ? currentEnsemble : null,
    );
  }

  /// Abre o modal de integrantes (usa MembersBloc internamente para listar/criar/remover).
  Future<void> _openAddMemberModal({
    required List<EnsembleMemberEntity> initialSelected,
    required Set<String> initialSelectedIds,
    required EnsembleEntity? currentEnsemble,
  }) async {
    final result = await MemberModal.show(
      context: context,
      membersBloc: context.read<MembersBloc>(),
      initialSelected: initialSelected,
      initialSelectedIds: initialSelectedIds,
    );
    if (!mounted) return;

    if (result == null) return;
    if (currentEnsemble == null) return;

    final artistId = context.read<ArtistsBloc>().state is GetArtistSuccess
        ? (context.read<ArtistsBloc>().state as GetArtistSuccess).artist.uid
        : null;
    final ownerSlot = artistId != null
        ? EnsembleMember(memberId: artistId, specialty: null, isOwner: true)
        : null;
    final newMembers = [
      if (ownerSlot != null) ownerSlot,
      ...result.map((e) => EnsembleMember(
            memberId: e.id!,
            specialty: e.specialty,
            isOwner: false,
          )),
    ];
    context.read<EnsembleBloc>().add(
          UpdateEnsembleEvent(ensemble: currentEnsemble.copyWith(members: newMembers)),
        );
    _reloadEnsemble();
    if (mounted) {
      context.showSuccess('Integrantes atualizados.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppListsBloc, AppListsState>(
      listenWhen: (previous, current) =>
          current is GetTalentsSuccess || current is GetTalentsFailure,
      listener: (context, state) {
        if (state is GetTalentsSuccess && _pendingSlotForTalents != null && mounted) {
          final slot = _pendingSlotForTalents!;
          final displayName = _pendingSlotDisplayName ?? 'Integrante';
          final talentNames = state.talents
              .map((t) => t.name)
              .where((n) => n.isNotEmpty)
              .toList()
            ..sort();
          setState(() {
            _pendingSlotForTalents = null;
            _pendingSlotDisplayName = null;
          });
          _showEditTalentsSheetWithList(context, slot, displayName, talentNames);
        }
        if (state is GetTalentsFailure && _pendingSlotForTalents != null && mounted) {
          setState(() {
            _pendingSlotForTalents = null;
            _pendingSlotDisplayName = null;
          });
          context.showError(state.error);
        }
      },
      child: BlocListener<EnsembleBloc, EnsembleState>(
        listenWhen: (previous, current) =>
            current is UpdateEnsembleSuccess || current is UpdateEnsembleFailure,
        listener: (context, state) {
          if (state is UpdateEnsembleSuccess) {
            context.showSuccess('Integrantes atualizados.');
            _reloadEnsemble();
          }
          if (state is UpdateEnsembleFailure) {
            context.showError(state.error);
          }
        },
      child: BlocListener<MemberDocumentsBloc, MemberDocumentsState>(
        listenWhen: (previous, current) => current is GetAllMemberDocumentsSuccess,
        listener: (context, state) {
          if (state is GetAllMemberDocumentsSuccess && _loadingMemberId != null && mounted) {
            final currentId = _loadingMemberId!;
            setState(() {
              _documentsByMember[currentId] = state.documents;
              if (_isRefreshingOneMember) {
                _isRefreshingOneMember = false;
                _loadingMemberId = null;
              } else {
                _loadingMemberIndex++;
                if (_memberIdsToLoad != null && _loadingMemberIndex < _memberIdsToLoad!.length) {
                  _loadingMemberId = _memberIdsToLoad![_loadingMemberIndex];
                } else {
                  _loadingMemberId = null;
                }
              }
            });
            if (_loadingMemberId != null) {
              context.read<MemberDocumentsBloc>().add(
                GetAllMemberDocumentsEvent(
                  ensembleId: widget.ensembleId,
                  memberId: _loadingMemberId!,
                ),
              );
            }
          }
        },
      child: BlocListener<MembersBloc, MembersState>(
      listenWhen: (previous, current) =>
          current is UpdateMemberSuccess ||
          current is UpdateMemberFailure ||
          current is DeleteMemberSuccess ||
          current is DeleteMemberFailure,
      listener: (context, state) {
        if (state is UpdateMemberSuccess) {
          context.showSuccess('Talentos atualizados.');
          _reloadEnsemble();
        }
        if (state is UpdateMemberFailure) {
          context.showError(state.error);
        }
        if (state is DeleteMemberSuccess && mounted) {
          _reloadEnsemble();
        }
        if (state is DeleteMemberFailure && mounted) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<MembersBloc, MembersState>(
        buildWhen: (previous, current) => current is GetAllMembersSuccess || current is GetAllMembersLoading,
        builder: (context, _) {
          return BlocBuilder<EnsembleBloc, EnsembleState>(
            buildWhen: (previous, current) =>
                current is GetAllEnsemblesSuccess ||
                current is GetEnsembleByIdFailure ||
                current is UpdateEnsembleMemberTalentsSuccess ||
                current is UpdateEnsembleMembersSuccess ||
                current is UpdateEnsembleSuccess,
            builder: (context, ensembleState) {
              if (ensembleState is GetEnsembleByIdFailure) {
                return BasePage(
                  showAppBar: true,
                  appBarTitle: 'Integrantes',
                  showAppBarBackButton: true,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ensembleState.error,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _reloadEnsemble,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final currentEnsemble = ensembleState is GetAllEnsemblesSuccess
                  ? ensembleState.currentEnsemble
                  : null;
              final isThisEnsemble = currentEnsemble?.id == widget.ensembleId;
              final rawStored = isThisEnsemble ? (currentEnsemble?.members ?? []) : <EnsembleMember>[];
              final artistsState = context.read<ArtistsBloc>().state;
              final ownerDisplayName = artistsState is GetArtistSuccess
                  ? (artistsState.artist.artistName ?? 'Conta principal')
                  : 'Conta principal';
              final artistId = artistsState is GetArtistSuccess ? artistsState.artist.uid : null;
              final membersState = context.read<MembersBloc>().state;
              final allMembers = membersState is GetAllMembersSuccess
                  ? membersState.members
                  : <EnsembleMemberEntity>[];
              final memberDetailsById = {
                for (final m in allMembers) if (m.id != null) m.id!: m
              };
              // Dono primeiro (slot com isOwner ou sintético se artistId presente), depois os demais slots.
              final ownerSlots = rawStored.where((m) => m.isOwner).toList();
              final ownerSlot = ownerSlots.isNotEmpty ? ownerSlots.first : (artistId != null ? EnsembleMember(memberId: artistId, specialty: null, isOwner: true) : null);
              final nonOwnerSlots = rawStored.where((m) => !m.isOwner && m.memberId != artistId).toList();
              final displayRows = <({EnsembleMember slot, String displayName, String? email, bool isApproved})>[];
              if (ownerSlot != null) {
                displayRows.add((slot: ownerSlot, displayName: ownerDisplayName, email: null, isApproved: true));
              }
              for (final slot in nonOwnerSlots) {
                final detail = memberDetailsById[slot.memberId];
                displayRows.add((
                  slot: slot,
                  displayName: detail?.name ?? 'Sem nome',
                  email: detail?.email,
                  isApproved: detail?.isApproved ?? false,
                ));
              }
              final isEmpty = displayRows.isEmpty;
              final memberIds = nonOwnerSlots.map((m) => m.memberId).toList();
              if (memberIds.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  final listChanged = _memberIdsToLoad == null ||
                      _memberIdsToLoad!.length != memberIds.length ||
                      !listEquals(_memberIdsToLoad, memberIds);
                  if (listChanged) {
                    setState(() {
                      _memberIdsToLoad = memberIds;
                      _loadingMemberIndex = 0;
                      _documentsByMember = {};
                      _loadingMemberId = memberIds[0];
                    });
                    context.read<MemberDocumentsBloc>().add(
                      GetAllMemberDocumentsEvent(
                        ensembleId: widget.ensembleId,
                        memberId: memberIds[0],
                      ),
                    );
                  }
                });
              }

              return BasePage(
                showAppBar: true,
                appBarTitle: 'Integrantes',
                showAppBarBackButton: true,
                floatingActionButton: FloatingActionButton(
                  onPressed: _onAddMemberTap,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.add),
                ),
                child: isEmpty
                    ? EmptyMembersPlaceholder(
                        message:
                            'Nenhum integrante neste conjunto. Adicione integrantes na área do conjunto.',
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          top: DSSize.height(16),
                          bottom: DSSize.height(24),
                        ),
                        itemCount: displayRows.length,
                        itemBuilder: (context, index) {
                          final row = displayRows[index];
                          final isOwner = row.slot.isOwner;
                          final ownerTalents = artistsState is GetArtistSuccess
                              ? artistsState.artist.professionalInfo?.specialty
                              : null;

                          return Padding(
                            padding: EdgeInsets.only(bottom: DSSize.height(12)),
                            child: MemberWithDocumentsCard(
                              name: row.displayName,
                              email: row.email,
                              photoUrl: null,
                              isOwner: isOwner,
                              isApproved: row.isApproved,
                              talents: isOwner ? ownerTalents : row.slot.specialty,
                              memberDocuments: _documentsByMember[row.slot.memberId],
                              onEditTalentsTap: isOwner
                                  ? null
                                  : () => _onEditTalentsTap(row.slot, memberDetailsById[row.slot.memberId]),
                              onDocumentsTap: isOwner ? null : () => _onDocumentsTap(row.slot),
                              onRemove: isOwner || currentEnsemble == null
                                  ? null
                                  : () => _onRemoveMember(currentEnsemble, row.slot, row.displayName),
                            ),
                          );
                        },
                      ),
              );
            },
          );
        },
      ),
    ),
    ),
    ),
  );
}
}
