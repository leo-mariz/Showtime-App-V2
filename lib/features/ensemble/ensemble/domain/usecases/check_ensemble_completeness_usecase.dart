import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/enums/document_status_enum.dart';
import 'package:app/core/enums/document_type_enum.dart';
import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/ensemble_completeness_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/ensemble_info_status_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/enums/ensemble_info_type_enum.dart';
import 'package:flutter/foundation.dart';

/// Verifica a completude do conjunto (ensemble).
///
/// São 7 verificações, cada uma com mensagem própria quando incompleta:
///
/// **Conjunto:**
/// 1. Há pelo menos um integrante além do administrador (isOwner = false).
/// 2. O(s) integrante(s) têm ambos os documentos (identidade e antecedentes) enviados ou aprovados.
/// 3. Há foto de perfil do grupo.
/// 4. Há vídeo de apresentação.
/// 5. Dados profissionais do conjunto preenchidos.
///
/// **Administrador:**
/// 6. Administrador tem todos os documentos enviados (feature artists).
/// 7. Administrador tem PIX ou conta bancária preenchidos.
class CheckEnsembleCompletenessUseCase {
  const CheckEnsembleCompletenessUseCase();

  static const _logTag = '[CheckEnsembleCompleteness]';

  EnsembleCompletenessEntity call({
    required EnsembleEntity ensemble,
    required List<DocumentsEntity> ownerDocuments,
    BankAccountEntity? ownerBankAccount,
    required Map<String, List<MemberDocumentEntity>> memberDocumentsByMemberId,
  }) {
    final statuses = <EnsembleInfoStatusEntity>[
      _checkMembers(ensemble),
      _checkMemberDocuments(ensemble, memberDocumentsByMemberId),
      _checkProfilePhoto(ensemble),
      _checkPresentations(ensemble),
      _checkProfessionalInfo(ensemble),
      _checkOwnerDocuments(ownerDocuments),
      _checkOwnerBankAccount(ownerBankAccount),
    ];
    final completeness = EnsembleCompletenessEntity(infoStatuses: statuses);
    final incomplete = completeness.incompleteStatuses;
    debugPrint('$_logTag ensembleId=${ensemble.id} | incomplete=${incomplete.length} | types=${incomplete.map((s) => s.type.name).toList()}');
    for (final s in statuses) {
      debugPrint('$_logTag   ${s.type.name}: isComplete=${s.isComplete}');
    }
    return completeness;
  }

  /// 1. Há pelo menos um integrante além do administrador.
  EnsembleInfoStatusEntity _checkMembers(EnsembleEntity ensemble) {
    final nonOwner = ensemble.members
            ?.where((m) => !m.isOwner && m.id != null && m.id!.isNotEmpty)
            .toList() ??
        [];
    final isComplete = nonOwner.isNotEmpty;
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.members,
      isComplete: isComplete,
      missingItems: isComplete ? [] : ['O grupo precisa de pelo menos um integrante (além do administrador).'],
    );
  }

  /// 2. Cada integrante (não dono) tem identidade e antecedentes enviados (1) ou aprovados (2).
  EnsembleInfoStatusEntity _checkMemberDocuments(
    EnsembleEntity ensemble,
    Map<String, List<MemberDocumentEntity>> memberDocumentsByMemberId,
  ) {
    final nonOwner = ensemble.members
            ?.where((m) => !m.isOwner && m.id != null && m.id!.isNotEmpty)
            .toList() ??
        [];
    if (nonOwner.isEmpty) {
      return const EnsembleInfoStatusEntity(
        type: EnsembleInfoType.memberDocuments,
        isComplete: true,
        missingItems: [],
      );
    }
    final missing = <String>[];
    for (final member in nonOwner) {
      final memberId = member.id!;
      final docs = memberDocumentsByMemberId[memberId] ?? [];
      final identityList = docs.where((d) => d.documentType == MemberDocumentType.identity).toList();
      final antecedentsList = docs.where((d) => d.documentType == MemberDocumentType.antecedents).toList();
      final identity = identityList.isNotEmpty ? identityList.first : null;
      final antecedents = antecedentsList.isNotEmpty ? antecedentsList.first : null;
      final identityOk = identity != null && (identity.status == 1 || identity.status == 2);
      final antecedentsOk = antecedents != null && (antecedents.status == 1 || antecedents.status == 2);
      debugPrint('$_logTag memberDocuments memberId=$memberId docs=${docs.length} identity=${identity?.status} ok=$identityOk antecedents=${antecedents?.status} ok=$antecedentsOk');
      if (!identityOk || !antecedentsOk) {
        missing.add('Cada integrante deve ter documentos (identidade e antecedentes) enviados ou aprovados.');
        break;
      }
    }
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.memberDocuments,
      isComplete: missing.isEmpty,
      missingItems: missing,
    );
  }

  /// 3. Há foto de perfil do grupo.
  EnsembleInfoStatusEntity _checkProfilePhoto(EnsembleEntity ensemble) {
    final hasPhoto = ensemble.profilePhotoUrl != null &&
        ensemble.profilePhotoUrl!.trim().isNotEmpty;
    debugPrint('$_logTag profilePhoto hasUrl=${ensemble.profilePhotoUrl != null} hasPhoto=$hasPhoto');
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.profilePhoto,
      isComplete: hasPhoto,
      missingItems: hasPhoto ? [] : ['É necessário foto de perfil do grupo.'],
    );
  }

  /// 4. Há vídeo de apresentação.
  EnsembleInfoStatusEntity _checkPresentations(EnsembleEntity ensemble) {
    final hasVideo = ensemble.presentationVideoUrl != null &&
        ensemble.presentationVideoUrl!.trim().isNotEmpty;
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.presentations,
      isComplete: hasVideo,
      missingItems: hasVideo ? [] : ['É necessário o vídeo de apresentação do conjunto.'],
    );
  }

  /// 5. Dados profissionais do conjunto preenchidos (campos do formulário: duração, preparação, bio).
  /// Não exige specialty pois o formulário do conjunto não coleta esse campo.
  EnsembleInfoStatusEntity _checkProfessionalInfo(EnsembleEntity ensemble) {
    final info = ensemble.professionalInfo;
    if (info == null) {
      return const EnsembleInfoStatusEntity(
        type: EnsembleInfoType.professionalInfo,
        isComplete: false,
        missingItems: ['É necessário preencher todos os dados profissionais do conjunto.'],
      );
    }
    final missing = <String>[];
    if (info.minimumShowDuration == null) missing.add('Duração mínima do show');
    if (info.preparationTime == null) missing.add('Tempo de preparação');
    if (info.bio == null || info.bio!.trim().isEmpty) missing.add('Bio');
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.professionalInfo,
      isComplete: missing.isEmpty,
      missingItems: missing.isEmpty ? [] : ['É necessário preencher todos os dados profissionais do conjunto.'],
    );
  }

  /// 6. Administrador tem todos os documentos enviados (submitted ou approved).
  EnsembleInfoStatusEntity _checkOwnerDocuments(List<DocumentsEntity> ownerDocuments) {
    const requiredTypes = <DocumentTypeEnum>[
      DocumentTypeEnum.identity,
      DocumentTypeEnum.residence,
      DocumentTypeEnum.curriculum,
      DocumentTypeEnum.antecedents,
    ];
    for (final docType in requiredTypes) {
      DocumentsEntity? doc;
      for (final d in ownerDocuments) {
        if (d.documentType == docType.name) {
          doc = d;
          break;
        }
      }
      if (doc == null ||
          doc.status == DocumentStatusEnum.pending.value ||
          doc.status == DocumentStatusEnum.rejected.value) {
        return const EnsembleInfoStatusEntity(
          type: EnsembleInfoType.ownerDocuments,
          isComplete: false,
          missingItems: ['O administrador deve ter todos os documentos enviados.'],
        );
      }
    }
    return const EnsembleInfoStatusEntity(
      type: EnsembleInfoType.ownerDocuments,
      isComplete: true,
      missingItems: [],
    );
  }

  /// 7. Administrador tem PIX ou conta bancária preenchidos.
  EnsembleInfoStatusEntity _checkOwnerBankAccount(BankAccountEntity? ownerBankAccount) {
    final hasBank = ownerBankAccount != null &&
        (ownerBankAccount.fullName?.trim().isNotEmpty ?? false) &&
        (ownerBankAccount.cpfOrCnpj?.trim().isNotEmpty ?? false) &&
        ((ownerBankAccount.pixKey?.trim().isNotEmpty ?? false) &&
                (ownerBankAccount.pixType?.trim().isNotEmpty ?? false) ||
            ((ownerBankAccount.agency?.trim().isNotEmpty ?? false) &&
                (ownerBankAccount.accountNumber?.trim().isNotEmpty ?? false) &&
                (ownerBankAccount.accountType?.trim().isNotEmpty ?? false)));
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.ownerBankAccount,
      isComplete: hasBank,
      missingItems: hasBank ? [] : ['O administrador deve ter PIX ou conta bancária preenchidos.'],
    );
  }
}
