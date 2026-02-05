import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
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
  /// Quando não null, estamos aguardando GetTalentsSuccess para abrir o sheet deste integrante.
  EnsembleMemberEntity? _pendingMemberForTalents;
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
  }

  void _onRemoveMember(EnsembleEntity ensemble, EnsembleMemberEntity member) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Remover integrante',
        message:
            'Tem certeza que deseja remover ${member.name ?? "este integrante"} do conjunto?',
        confirmText: 'Remover',
        cancelText: 'Cancelar',
        confirmButtonColor: Theme.of(context).colorScheme.error,
        confirmButtonTextColor: Theme.of(context).colorScheme.onError,
        onConfirm: () {
          Navigator.of(ctx).pop();
          final current = ensemble.members ?? [];
          final newList = current.where((m) => m.id != member.id).toList();
          context.read<EnsembleBloc>().add(
                UpdateEnsembleEvent(ensemble: ensemble.copyWith(members: newList)),
              );
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _onDocumentsTap(EnsembleMemberEntity member) {
    final memberId = member.id ?? '';
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
          forceRemote: true,
        ),
      );
    });
  }

  void _onEditTalentsTap(EnsembleMemberEntity member) {
    setState(() => _pendingMemberForTalents = member);
    context.read<AppListsBloc>().add(GetTalentsEvent());
  }

  void _showEditTalentsSheetWithList(
    BuildContext context,
    EnsembleMemberEntity member,
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
          title: 'Talentos de ${member.name ?? "Integrante"}',
          subtitle: 'Selecione os talentos deste integrante neste conjunto. O mesmo integrante pode ter talentos diferentes em outros conjuntos.',
          talentNames: talentNames,
          initialSelected: member.specialty ?? [],
          loading: state is UpdateEnsembleMemberTalentsLoading,
          confirmButtonLabel: 'Salvar',
          onConfirm: (selected) {
            context.read<EnsembleBloc>().add(
              UpdateEnsembleMemberTalentsEvent(
                ensembleId: widget.ensembleId,
                memberId: member.id ?? '',
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
    final isThisEnsemble = currentEnsemble?.id == widget.ensembleId;
    final initialSelected = isThisEnsemble ? (currentEnsemble?.members ?? []) : <EnsembleMemberEntity>[];
    _openAddMemberModal(
      initialSelected: initialSelected,
      currentEnsemble: isThisEnsemble ? currentEnsemble : null,
    );
  }

  /// Abre o modal de integrantes (usa MembersBloc internamente para listar/criar/remover).
  Future<void> _openAddMemberModal({
    required List<EnsembleMemberEntity> initialSelected,
    required EnsembleEntity? currentEnsemble,
  }) async {
    final result = await MemberModal.show(
      context: context,
      membersBloc: context.read<MembersBloc>(),
      initialSelected: initialSelected,
    );
    if (!mounted) return;

    if (result == null) return;
    if (currentEnsemble == null) return;

    context.read<EnsembleBloc>().add(
          UpdateEnsembleEvent(ensemble: currentEnsemble.copyWith(members: result)),
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
        if (state is GetTalentsSuccess && _pendingMemberForTalents != null && mounted) {
          final member = _pendingMemberForTalents!;
          final talentNames = state.talents
              .map((t) => t.name)
              .where((n) => n.isNotEmpty)
              .toList()
            ..sort();
          setState(() => _pendingMemberForTalents = null);
          _showEditTalentsSheetWithList(context, member, talentNames);
        }
        if (state is GetTalentsFailure && _pendingMemberForTalents != null && mounted) {
          setState(() => _pendingMemberForTalents = null);
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
          final ensembleState = context.read<EnsembleBloc>().state;
          final currentEnsemble = ensembleState is GetAllEnsemblesSuccess
              ? ensembleState.currentEnsemble
              : null;
          if (currentEnsemble != null &&
              currentEnsemble.id == widget.ensembleId &&
              currentEnsemble.members != null) {
            final updated = state.member;
            final newList = currentEnsemble.members!
                .map((m) => m.id == updated.id ? updated : m)
                .toList();
            context.read<EnsembleBloc>().add(
                  UpdateEnsembleEvent(
                    ensemble: currentEnsemble.copyWith(members: newList),
                  ),
                );
          } else {
            _reloadEnsemble();
          }
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
      child: BlocBuilder<EnsembleBloc, EnsembleState>(
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
          final rawStored = isThisEnsemble ? (currentEnsemble?.members ?? []) : <EnsembleMemberEntity>[];
          final artistsState = context.read<ArtistsBloc>().state;
          final ownerDisplayName = artistsState is GetArtistSuccess
              ? (artistsState.artist.artistName ?? 'Conta principal')
              : 'Conta principal';
          final artistId = artistsState is GetArtistSuccess ? artistsState.artist.uid : null;
          // Não exibir o dono vindo do Firestore (compatibilidade com dados antigos); o dono vem do ArtistsBloc.
          final storedMembers = rawStored.where((m) => !m.isOwner && m.id != artistId).toList();
          final ownerEntity = artistId != null
              ? EnsembleMemberEntity(
                  id: artistId,
                  ensembleIds: [widget.ensembleId],
                  isOwner: true,
                  artistId: artistId,
                  isApproved: true,
                )
              : null;
          final displayMembers = ownerEntity != null
              ? [ownerEntity, ...storedMembers]
              : storedMembers;
          final isEmpty = displayMembers.isEmpty;
          final memberIds = storedMembers.map((m) => m.id).whereType<String>().toList();
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
                    itemCount: displayMembers.length,
                    itemBuilder: (context, index) {
                      final member = displayMembers[index];
                      final isOwner = member.isOwner;
                      final displayName = isOwner
                          ? ownerDisplayName
                          : (member.name ?? 'Sem nome');

                      return Padding(
                        padding: EdgeInsets.only(bottom: DSSize.height(12)),
                        child: MemberWithDocumentsCard(
                          name: displayName,
                          email: member.email,
                          photoUrl: null,
                          isOwner: isOwner,
                          isApproved: member.isApproved,
                          talents: member.specialty,
                          memberDocuments: member.id != null ? _documentsByMember[member.id!] : null,
                          onEditTalentsTap: isOwner ? null : () => _onEditTalentsTap(member),
                          onDocumentsTap: isOwner ? null : () => _onDocumentsTap(member),
                          onRemove: isOwner || currentEnsemble == null
                              ? null
                              : () => _onRemoveMember(currentEnsemble, member),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    ),
    ),
    ),
  );
  }
}
