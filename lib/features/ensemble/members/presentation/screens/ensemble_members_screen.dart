import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/confirmation_dialog.dart';
import 'package:app/features/ensemble/members/presentation/widgets/empty_members_placeholder.dart';
import 'package:app/features/ensemble/members/presentation/widgets/member_with_documents_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Dados de exibição do status dos documentos de um integrante (mock ou vindo do repositório).
class MemberDocumentStatusDisplay {
  final String identityLabel;
  final Color? identityColor;
  final String antecedentsLabel;
  final Color? antecedentsColor;

  const MemberDocumentStatusDisplay({
    this.identityLabel = 'Pendente',
    this.identityColor,
    this.antecedentsLabel = 'Pendente',
    this.antecedentsColor,
  });
}

@RoutePage(deferredLoading: true)
class EnsembleMembersScreen extends StatefulWidget {
  final String ensembleId;

  const EnsembleMembersScreen({super.key, required this.ensembleId});

  @override
  State<EnsembleMembersScreen> createState() => _EnsembleMembersScreenState();
}

class _EnsembleMembersScreenState extends State<EnsembleMembersScreen> {
  /// Lista mockada de integrantes com status dos documentos
  late List<EnsembleMemberEntity> _members;
  late Map<String, MemberDocumentStatusDisplay> _documentStatusByMemberId;

  @override
  void initState() {
    super.initState();
    _members = _mockMembers(widget.ensembleId);
    _documentStatusByMemberId = _mockDocumentStatus();
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

  static Map<String, MemberDocumentStatusDisplay> _mockDocumentStatus() {
    return {
      'm1': const MemberDocumentStatusDisplay(
        identityLabel: 'Aprovado',
        antecedentsLabel: 'Aprovado',
      ),
      'm2': const MemberDocumentStatusDisplay(
        identityLabel: 'Aprovado',
        antecedentsLabel: 'Enviado',
      ),
      'm3': const MemberDocumentStatusDisplay(
        identityLabel: 'Pendente',
        antecedentsLabel: 'Rejeitado',
      ),
    };
  }

  void _onRemoveMember(EnsembleMemberEntity member) {
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
          setState(() {
            _members.removeWhere((m) => m.id == member.id);
            _documentStatusByMemberId.remove(member.id);
          });
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _onDocumentsTap(EnsembleMemberEntity member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Documentos de ${member.name ?? "integrante"} — em breve'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _members.isEmpty;

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Integrantes',
      showAppBarBackButton: true,
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
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                final isOwner = member.isOwner;

                return Padding(
                  padding: EdgeInsets.only(bottom: DSSize.height(12)),
                  child: MemberWithDocumentsCard(
                    name: member.name ?? 'Sem nome',
                    email: member.email,
                    photoUrl: null,
                    isOwner: isOwner,
                    isApproved: member.isApproved,
                    onDocumentsTap: isOwner ? null : () => _onDocumentsTap(member),
                    onRemove: isOwner ? null : () => _onRemoveMember(member),
                  ),
                );
              },
            ),
    );
  }
}
