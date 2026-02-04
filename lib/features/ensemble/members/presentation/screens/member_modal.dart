import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/confirmation_dialog.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/ensemble/members/presentation/bloc/events/members_events.dart';
import 'package:app/features/ensemble/members/presentation/bloc/members_bloc.dart';
import 'package:app/features/ensemble/members/presentation/bloc/states/members_states.dart';
import 'package:app/features/ensemble/members/presentation/widgets/add_member_form_modal.dart';
import 'package:app/features/ensemble/members/presentation/widgets/empty_members_placeholder.dart';
import 'package:app/features/ensemble/members/presentation/widgets/member_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Modal para selecionar ou adicionar integrantes.
/// Usa [MembersBloc] para listar, criar e remover integrantes do pool do artista.
/// Retorna: [List<EnsembleMemberEntity>] ao confirmar, ou null ao cancelar.
class MemberModal extends StatefulWidget {
  /// Bloc de integrantes (obrigatório).
  final MembersBloc membersBloc;
  /// Integrantes já selecionados (ex.: vindos do NewEnsembleModal ou do conjunto atual).
  final List<EnsembleMemberEntity> initialSelected;
  /// Callback ao confirmar com a lista selecionada
  final void Function(List<EnsembleMemberEntity> selected) onConfirm;

  const MemberModal({
    super.key,
    required this.membersBloc,
    this.initialSelected = const [],
    required this.onConfirm,
  });

  /// Exibe o modal. Requer [membersBloc] do contexto. Retorna a lista selecionada ao confirmar, ou null ao cancelar.
  static Future<List<EnsembleMemberEntity>?> show({
    required BuildContext context,
    required MembersBloc membersBloc,
    List<EnsembleMemberEntity> initialSelected = const [],
  }) {
    return showModalBottomSheet<List<EnsembleMemberEntity>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: membersBloc,
        child: MemberModal(
          membersBloc: membersBloc,
          initialSelected: initialSelected,
          onConfirm: (selected) => Navigator.of(context).pop(selected),
        ),
      ),
    );
  }

  @override
  State<MemberModal> createState() => _MemberModalState();
}

class _MemberModalState extends State<MemberModal> {
  /// Lista de integrantes (atualizada a partir do bloc).
  List<EnsembleMemberEntity> _allMembers = [];
  /// IDs dos integrantes selecionados.
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialSelected
        .where((m) => m.id != null && !m.isOwner)
        .map((m) => m.id!)
        .toSet();
    widget.membersBloc.add(GetAllMembersEvent(forceRemote: true));
  }

  void _toggleSelection(EnsembleMemberEntity member) {
    if (member.id == null) return;
    setState(() {
      if (_selectedIds.contains(member.id)) {
        _selectedIds.remove(member.id);
      } else {
        _selectedIds.add(member.id!);
      }
    });
  }

  /// Mostra diálogo de confirmação e retorna true se o usuário confirmar.
  Future<bool> _confirmRemoveMember(EnsembleMemberEntity member) async {
    final name = member.name?.trim().isNotEmpty == true
        ? member.name!
        : 'este integrante';
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Remover integrante',
      message:
          'Ao remover $name, ele será retirado de todos os conjuntos em que participa. Essa ação não pode ser desfeita. Deseja continuar?',
      confirmText: 'Remover',
      cancelText: 'Cancelar',
      confirmButtonColor: Theme.of(context).colorScheme.error,
      confirmButtonTextColor: Theme.of(context).colorScheme.onError,
    );
    return confirmed == true;
  }

  /// Remove o integrante da lista local imediatamente (evita erro do Dismissible) e dispara o evento de delete.
  void _onRemoveMember(EnsembleMemberEntity member) {
    final id = member.id;
    if (id == null || id.isEmpty) return;
    setState(() {
      _allMembers = _allMembers.where((m) => m.id != id).toList();
      _selectedIds.remove(id);
    });
    context.read<MembersBloc>().add(
          DeleteMemberEvent(ensembleId: '', memberId: id),
        );
  }

  Future<void> _onAddNew() async {
    final draft = await AddMemberFormModal.show(context: context);
    if (draft != null && mounted) {
      final memberToCreate = EnsembleMemberEntity(
        id: null,
        ensembleIds: [],
        isOwner: false,
        name: draft.name,
        cpf: draft.cpf,
        email: draft.email,
        isApproved: false,
      );
      context.read<MembersBloc>().add(
            CreateMemberEvent(
              ensembleId: '',
              member: memberToCreate,
            ),
          );
    }
  }

  void _onConfirm() {
    final selected = _allMembers
        .where((m) => m.id != null && _selectedIds.contains(m.id))
        .toList();
    widget.onConfirm(selected);
  }

  List<EnsembleMemberEntity> get _displayMembers =>
      _allMembers.where((m) => !m.isOwner).toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;

    return BlocConsumer<MembersBloc, MembersState>(
      listenWhen: (previous, current) =>
          current is GetAllMembersSuccess ||
          current is CreateMemberSuccess ||
          current is CreateMemberFailure ||
          current is DeleteMemberSuccess ||
          current is DeleteMemberFailure,
      listener: (context, state) {
        if (state is GetAllMembersSuccess) {
          setState(() => _allMembers = state.members);
        }
        if (state is CreateMemberSuccess) {
          setState(() {
            _allMembers = [..._allMembers, state.member];
            if (state.member.id != null) {
              _selectedIds.add(state.member.id!);
            }
          });
          if (mounted) context.showSuccess('Integrante adicionado.');
        }
        if (state is CreateMemberFailure && mounted) {
          context.showError(state.error);
        }
        if (state is DeleteMemberSuccess) {
          setState(() {
            _allMembers =
                _allMembers.where((m) => m.id != state.memberId).toList();
            _selectedIds.remove(state.memberId);
          });
          if (mounted) context.showSuccess('Integrante removido.');
        }
        if (state is DeleteMemberFailure && mounted) {
          context.showError(state.error);
        }
      },
      buildWhen: (previous, current) =>
          current is GetAllMembersLoading ||
          current is GetAllMembersSuccess ||
          current is GetAllMembersFailure ||
          current is MembersInitial,
      builder: (context, state) {
        // Não sobrescrever _allMembers aqui: o listener já atualiza em GetAllMembersSuccess/Create/Delete.
        // Evita que, após onDismissed remover o item, o builder restaure a lista antiga e deixe o Dismissible na árvore.
        final displayMembers = _displayMembers;
        final isLoading = state is GetAllMembersLoading;
        final hasError = state is GetAllMembersFailure;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(DSSize.width(20)),
                    topRight: Radius.circular(DSSize.width(20)),
                  ),
                ),
                child: Column(
                  children: [
                    DSSizedBoxSpacing.vertical(8),
                    Container(
                      width: DSSize.width(40),
                      height: DSSize.height(4),
                      margin: EdgeInsets.only(bottom: DSSize.height(16)),
                      decoration: BoxDecoration(
                        color: onPrimary.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(DSSize.width(2)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Integrantes',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: onPrimary,
                                ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: onPrimary),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    Text(
                      'Toque para selecionar. Arraste para o lado para remover.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: onPrimary.withOpacity(0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : hasError
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(DSSize.width(16)),
                                    child: Text(
                                      state.error,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : displayMembers.isEmpty
                                  ? EmptyMembersPlaceholder(
                                      message:
                                          'Nenhum integrante disponível. Adicione um novo.',
                                    )
                                  : ListView.builder(
                                      controller: scrollController,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: DSSize.width(16)),
                                      itemCount: displayMembers.length,
                                      itemBuilder: (context, index) {
                                        final member = displayMembers[index];
                                        final isSelected = member.id != null &&
                                            _selectedIds.contains(member.id);
                                        final canDismiss = member.id != null &&
                                            !member.id!.startsWith('new_');
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: DSSize.height(12)),
                                          child: Dismissible(
                                            key: ValueKey(member.id ?? index),
                                            direction: DismissDirection.endToStart,
                                            confirmDismiss: (_) async {
                                              if (!canDismiss) return false;
                                              return _confirmRemoveMember(member);
                                            },
                                            onDismissed: (_) =>
                                                _onRemoveMember(member),
                                            background: canDismiss
                                                ? Container(
                                                    alignment: Alignment.centerRight,
                                                    padding: EdgeInsets.only(
                                                        right: DSSize.width(16)),
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.error,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              DSSize.width(12)),
                                                    ),
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      color: colorScheme.onError,
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                            child: GestureDetector(
                                              onTap: () => _toggleSelection(member),
                                              child: MemberListItem(
                                                name: member.name ?? 'Sem nome',
                                                email: member.email,
                                                photoUrl: null,
                                                isApproved: member.isApproved,
                                                isOwner: member.isOwner,
                                                onTap: () => _toggleSelection(member),
                                                onRemove: null,
                                                isSelected: isSelected,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(DSSize.width(16)),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: 'Novo',
                              onPressed: isLoading ? null : _onAddNew,
                              icon: Icons.person_add,
                            ),
                          ),
                          DSSizedBoxSpacing.horizontal(12),
                          Expanded(
                            child: CustomButton(
                              label: 'Confirmar',
                              onPressed: _onConfirm,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
