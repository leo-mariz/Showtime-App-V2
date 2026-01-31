import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/ensemble/members/presentation/widgets/add_member_form_modal.dart';
import 'package:app/features/ensemble/members/presentation/widgets/empty_members_placeholder.dart';
import 'package:app/features/ensemble/members/presentation/widgets/member_list_item.dart';
import 'package:flutter/material.dart';

/// Modal para selecionar ou adicionar integrantes.
/// Retorna a lista de integrantes selecionados ao confirmar.
class MemberModal extends StatefulWidget {
  /// Integrantes já selecionados (ex.: vindos do NewEnsembleModal)
  final List<EnsembleMemberEntity> initialSelected;
  /// Integrantes disponíveis para seleção (obtidos do MembersBloc).
  final List<EnsembleMemberEntity> availableMembers;
  /// Callback ao confirmar com a lista selecionada
  final void Function(List<EnsembleMemberEntity> selected) onConfirm;

  const MemberModal({
    super.key,
    this.initialSelected = const [],
    this.availableMembers = const [],
    required this.onConfirm,
  });

  /// Exibe o modal e retorna a lista selecionada ao confirmar, ou null ao cancelar.
  static Future<List<EnsembleMemberEntity>?> show({
    required BuildContext context,
    List<EnsembleMemberEntity> initialSelected = const [],
    List<EnsembleMemberEntity> availableMembers = const [],
  }) {
    return showModalBottomSheet<List<EnsembleMemberEntity>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemberModal(
        initialSelected: initialSelected,
        availableMembers: availableMembers,
        onConfirm: (selected) => Navigator.of(context).pop(selected),
      ),
    );
  }

  @override
  State<MemberModal> createState() => _MemberModalState();
}

class _MemberModalState extends State<MemberModal> {
  /// Lista de integrantes disponíveis (vinda do MembersBloc via availableMembers).
  late List<EnsembleMemberEntity> _availableMembers;
  /// IDs dos integrantes selecionados neste modal
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _availableMembers = List.from(widget.availableMembers);
    _selectedIds = widget.initialSelected
        .where((m) => m.id != null)
        .map((m) => m.id!)
        .toSet();
    // Incluir na lista disponível os que já vinham selecionados mas não estão na lista
    for (final m in widget.initialSelected) {
      if (m.id != null && !_availableMembers.any((a) => a.id == m.id)) {
        _availableMembers.insert(0, m);
      }
    }
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

  Future<void> _onAddNew() async {
    final newMember = await AddMemberFormModal.show(context: context);
    if (newMember != null && mounted) {
      setState(() {
        _availableMembers.insert(0, newMember);
        if (newMember.id != null) _selectedIds.add(newMember.id!);
      });
    }
  }

  void _onConfirm() {
    final selected = _availableMembers
        .where((m) => m.id != null && _selectedIds.contains(m.id))
        .toList();
    widget.onConfirm(selected);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
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
                'Selecione os integrantes que farão parte do conjunto',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: onPrimary.withOpacity(0.8),
                    ),
                textAlign: TextAlign.center,
              ),
              DSSizedBoxSpacing.vertical(16),
              Expanded(
                child: _availableMembers.isEmpty
                    ? EmptyMembersPlaceholder(
                        message: 'Nenhum integrante disponível. Adicione um novo.',
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                        itemCount: _availableMembers.length,
                        itemBuilder: (context, index) {
                          final member = _availableMembers[index];
                          final isSelected = member.id != null &&
                              _selectedIds.contains(member.id);
                          return Padding(
                            padding: EdgeInsets.only(bottom: DSSize.height(12)),
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
                        onPressed: _onAddNew,
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
        );
      },
    );
  }
}
