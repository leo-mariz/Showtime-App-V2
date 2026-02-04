import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/ensemble/members/presentation/bloc/members_bloc.dart';
import 'package:app/features/ensemble/members/presentation/screens/member_modal.dart';
import 'package:app/features/ensemble/members/presentation/widgets/member_selection_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Modal para criar um novo conjunto.
/// Fluxo: um único botão — primeiro "Selecionar integrantes" (abre modal de integrantes);
/// ao voltar, exibe os selecionados e o botão vira "Criar".
/// Retorna a lista de integrantes selecionados ao confirmar "Criar".
class NewEnsembleModal extends StatefulWidget {
  const NewEnsembleModal({super.key});

  /// Exibe o modal. Retorna lista de integrantes ao criar, ou null ao cancelar.
  static Future<List<EnsembleMemberEntity>?> show({
    required BuildContext context,
  }) {
    return showModalBottomSheet<List<EnsembleMemberEntity>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewEnsembleModal(),
    );
  }

  @override
  State<NewEnsembleModal> createState() => _NewEnsembleModalState();
}

class _NewEnsembleModalState extends State<NewEnsembleModal> {
  List<EnsembleMemberEntity> _selectedMembers = [];

  Future<void> _openMemberModal() async {
    final selected = await MemberModal.show(
      context: context,
      membersBloc: context.read<MembersBloc>(),
      initialSelected: _selectedMembers,
    );
    if (selected != null && mounted) {
      setState(() => _selectedMembers = selected);
    }
  }

  void _removeMember(EnsembleMemberEntity member) {
    setState(() => _selectedMembers.removeWhere((m) => m.id == member.id));
  }

  void _onCreate() {
    Navigator.of(context).pop(_selectedMembers);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
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
                      'Novo conjunto',
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
              Expanded(
                child: _selectedMembers.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Selecione os integrantes que farão parte deste conjunto.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: onPrimary.withOpacity(0.8),
                                  ),
                            ),
                            DSSizedBoxSpacing.vertical(24),
                            CustomButton(
                              label: 'Selecionar integrantes',
                              onPressed: _openMemberModal,
                              icon: Icons.person_add,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                            child: Text(
                              'Integrantes selecionados (${_selectedMembers.length})',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: onPrimary.withOpacity(0.8),
                                  ),
                            ),
                          ),
                          DSSizedBoxSpacing.vertical(8),
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                              itemCount: _selectedMembers.length,
                              itemBuilder: (context, index) {
                                final member = _selectedMembers[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: DSSize.height(8)),
                                  child: MemberSelectionChip(
                                    name: member.name ?? 'Sem nome',
                                    email: member.email,
                                    onTap: () => _openMemberModal(),
                                    onRemove: () => _removeMember(member),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(DSSize.width(16)),
                            child: CustomButton(
                              label: 'Criar',
                              onPressed: _onCreate,
                              icon: Icons.check,
                            ),
                          ),
                        ],
                      ),
              ),
              if (_selectedMembers.isEmpty) DSSizedBoxSpacing.vertical(24),
            ],
          ),
        );
      },
    );
  }
}
