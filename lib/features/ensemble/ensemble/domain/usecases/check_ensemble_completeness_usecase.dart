import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/ensemble_completeness_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/ensemble_info_status_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/enums/ensemble_info_type_enum.dart';

/// Verifica a completude do conjunto (ensemble).
///
/// Informações incompletas verificadas:
/// - nome do grupo → não vazio
/// - talentos → não vazio
/// - dados profissionais → todos os campos preenchidos (bio, duração mín., preparação, antecedência mín.)
/// - foto de perfil → não vazio
/// - vídeo de apresentação → obrigatório
class CheckEnsembleCompletenessUseCase {
  const CheckEnsembleCompletenessUseCase();

  EnsembleCompletenessEntity call({
    required EnsembleEntity ensemble,
    required List<DocumentsEntity> ownerDocuments,
    BankAccountEntity? ownerBankAccount,
  }) {
    final statuses = <EnsembleInfoStatusEntity>[
      _checkEnsembleName(ensemble),
      _checkTalents(ensemble),
      _checkProfessionalInfo(ensemble),
      _checkProfilePhoto(ensemble),
      _checkPresentations(ensemble),
    ];
    return EnsembleCompletenessEntity(infoStatuses: statuses);
  }

  /// Nome do grupo não vazio.
  EnsembleInfoStatusEntity _checkEnsembleName(EnsembleEntity ensemble) {
    final name = ensemble.ensembleName?.trim() ?? '';
    final isComplete = name.isNotEmpty;
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.ensembleName,
      isComplete: isComplete,
      missingItems: isComplete ? [] : ['Informe o nome do grupo.'],
    );
  }

  /// Tipo do grupo e talentos preenchidos (seção "Sobre o Conjunto" / integrantes).
  /// Incompleto se tipo do conjunto ou lista de talentos estiver vazio.
  EnsembleInfoStatusEntity _checkTalents(EnsembleEntity ensemble) {
    final typeOk = ensemble.ensembleType != null &&
        ensemble.ensembleType!.trim().isNotEmpty;
    final list = ensemble.talents;
    final hasTalents = list != null &&
        list.isNotEmpty &&
        list.any((t) => t.trim().isNotEmpty);
    final isComplete = typeOk && hasTalents;
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.talents,
      isComplete: isComplete,
      missingItems: isComplete ? [] : ['Informe o tipo do grupo e ao menos um talento.'],
    );
  }

  /// Dados profissionais: bio, minimumShowDuration, preparationTime e requestMinimumEarliness preenchidos.
  /// (Especialidade não é obrigatória para conjunto; talentos são verificados em [talents].)
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
    if (info.requestMinimumEarliness == null) missing.add('Antecedência mínima');
    if (info.bio == null || info.bio!.trim().isEmpty) missing.add('Bio');
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.professionalInfo,
      isComplete: missing.isEmpty,
      missingItems: missing.isEmpty ? [] : ['É necessário preencher todos os dados profissionais do conjunto.'],
    );
  }

  /// Foto de perfil não vazio.
  EnsembleInfoStatusEntity _checkProfilePhoto(EnsembleEntity ensemble) {
    final hasPhoto = ensemble.profilePhotoUrl != null &&
        ensemble.profilePhotoUrl!.trim().isNotEmpty;
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.profilePhoto,
      isComplete: hasPhoto,
      missingItems: hasPhoto ? [] : ['É necessário foto de perfil do grupo.'],
    );
  }

  /// Vídeo de apresentação obrigatório.
  EnsembleInfoStatusEntity _checkPresentations(EnsembleEntity ensemble) {
    final hasVideo = ensemble.presentationVideoUrl != null &&
        ensemble.presentationVideoUrl!.trim().isNotEmpty;
    return EnsembleInfoStatusEntity(
      type: EnsembleInfoType.presentations,
      isComplete: hasVideo,
      missingItems: hasVideo ? [] : ['É necessário adicionar o vídeo de apresentação do conjunto (até 1 min).'],
    );
  }
}
