import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/enums/document_status_enum.dart';
import 'package:app/core/enums/document_type_enum.dart';
import 'package:app/features/profile/artists/domain/entities/artist_completeness_entity.dart';
import 'package:app/features/profile/artists/domain/entities/artist_info_status_entity.dart';
import 'package:app/features/profile/artists/domain/enums/artist_info_category_enum.dart';
import 'package:app/features/profile/artists/domain/enums/artist_info_type_enum.dart';

/// UseCase: Verificar completude do perfil do artista
/// 
/// RESPONSABILIDADES:
/// - Verificar se todos os documentos obrigatórios estão presentes e aprovados
/// - Verificar se há informações bancárias (PIX ou conta bancária)
/// - Verificar se há foto de perfil
/// - Verificar se há pelo menos uma disponibilidade ativa
/// - Verificar se há informações profissionais e apresentações (opcionais)
/// - Calcular score de completude (0-100)
/// - Retornar entidade agregada com status de cada informação
class CheckArtistCompletenessUseCase {
  const CheckArtistCompletenessUseCase();

  /// Verifica a completude do perfil do artista
  /// 
  /// [artist] - Entidade do artista
  /// [documents] - Lista de documentos do artista
  /// [bankAccount] - Conta bancária do artista (opcional)
  /// [availabilities] - Lista de disponibilidades do artista
  /// 
  /// Retorna [ArtistCompletenessEntity] com o status completo de todas as informações
  ArtistCompletenessEntity call({
    required ArtistEntity artist,
    required List<DocumentsEntity> documents,
    BankAccountEntity? bankAccount,
    required List<AvailabilityDayEntity> availabilities,
  }) {
    // Lista de todos os status de informações
    final List<ArtistInfoStatusEntity> infoStatuses = [];

    // 1. Verificar DOCUMENTS (approvalRequired)
    final documentsStatus = _checkDocuments(documents);
    infoStatuses.add(documentsStatus);

    // 2. Verificar BANK_ACCOUNT (approvalRequired)
    final bankAccountStatus = _checkBankAccount(bankAccount);
    infoStatuses.add(bankAccountStatus);

    // 3. Verificar PROFILE_PICTURE (exploreRequired)
    final profilePictureStatus = _checkProfilePicture(artist);
    infoStatuses.add(profilePictureStatus);

    // 4. Verificar AVAILABILITY (exploreRequired)
    final availabilityStatus = _checkAvailability(availabilities);
    infoStatuses.add(availabilityStatus);

    // 5. Verificar PROFESSIONAL_INFO (optional)
    final professionalInfoStatus = _checkProfessionalInfo(artist);
    infoStatuses.add(professionalInfoStatus);

    // 6. Verificar PRESENTATIONS (optional)
    final presentationsStatus = _checkPresentations(artist);
    infoStatuses.add(presentationsStatus);

    // Calcular status por categoria
    final approvalRequiredStatuses = infoStatuses.where(
      (status) => status.category == ArtistInfoCategory.approvalRequired,
    ).toList();
    final exploreRequiredStatuses = infoStatuses.where(
      (status) => status.category == ArtistInfoCategory.exploreRequired,
    ).toList();
    final optionalStatuses = infoStatuses.where(
      (status) => status.category == ArtistInfoCategory.optional,
    ).toList();

    // Verificar se todas as categorias estão completas
    final canBeApproved = approvalRequiredStatuses.every((status) => status.isComplete);
    final canAppearInExplore = exploreRequiredStatuses.every((status) => status.isComplete);

    // Mapa de status por categoria
    final categoryStatus = <ArtistInfoCategory, bool>{
      ArtistInfoCategory.approvalRequired: canBeApproved,
      ArtistInfoCategory.exploreRequired: canAppearInExplore,
      ArtistInfoCategory.optional: optionalStatuses.every((status) => status.isComplete),
    };

    // Calcular score de completude (0-100)
    // - 50 pontos: Informações de aprovação completas
    // - 30 pontos: Informações de explorar completas
    // - 10 pontos: Informações profissionais completas
    // - 10 pontos: Apresentações completas
    int completenessScore = 0;
    if (canBeApproved) completenessScore += 50;
    if (canAppearInExplore) completenessScore += 30;
    if (professionalInfoStatus.isComplete) completenessScore += 10;
    if (presentationsStatus.isComplete) completenessScore += 10;

    return ArtistCompletenessEntity(
      canBeApproved: canBeApproved,
      canAppearInExplore: canAppearInExplore,
      completenessScore: completenessScore,
      infoStatuses: infoStatuses,
      categoryStatus: categoryStatus,
    );
  }

  /// Verifica se todos os documentos obrigatórios estão presentes e aprovados
  /// 
  /// Documentos obrigatórios:
  /// - Identity (RG ou CNH)
  /// - Residence (Comprovante de Residência)
  /// - Curriculum
  /// - Antecedents (Certidão de Antecedentes Criminais)
  /// 
  /// Um documento é considerado válido se:
  /// - Existe na lista
  /// - Tem URL não vazia
  /// - Tem status aprovado (DocumentStatusEnum.approved)
  ArtistInfoStatusEntity _checkDocuments(List<DocumentsEntity> documents) {
    final requiredDocumentTypes = [
      DocumentTypeEnum.identity,
      DocumentTypeEnum.residence,
      DocumentTypeEnum.curriculum,
      DocumentTypeEnum.antecedents,
    ];

    final missingDocuments = <String>[];

    for (final docType in requiredDocumentTypes) {
      final document = documents.firstWhere(
        (doc) => doc.documentType == docType.name,
        orElse: () => DocumentsEntity(documentType: docType.name),
      );

      // Verificar se documento existe, tem URL e está aprovado
      final isValid = document.url != null &&
          document.url!.isNotEmpty &&
          document.statusEnum == DocumentStatusEnum.approved;

      if (!isValid) {
        missingDocuments.add(_getDocumentTypeName(docType));
      }
    }

    return ArtistInfoStatusEntity(
      type: ArtistInfoType.documents,
      category: ArtistInfoCategory.approvalRequired,
      isComplete: missingDocuments.isEmpty,
      missingItems: missingDocuments,
    );
  }

  /// Verifica se há informações bancárias válidas
  /// 
  /// Pode ser PIX OU Conta Bancária:
  /// - PIX: pixKey != null && pixKey.isNotEmpty && pixType != null
  /// - Conta: agency != null && agency.isNotEmpty && 
  ///          accountNumber != null && accountNumber.isNotEmpty &&
  ///          accountType != null && accountType.isNotEmpty
  ArtistInfoStatusEntity _checkBankAccount(BankAccountEntity? bankAccount) {
    if (bankAccount == null) {
      return const ArtistInfoStatusEntity(
        type: ArtistInfoType.bankAccount,
        category: ArtistInfoCategory.approvalRequired,
        isComplete: false,
        missingItems: ['Informações bancárias ou PIX'],
      );
    }

    // Verificar PIX
    final hasPix = bankAccount.pixKey != null &&
        bankAccount.pixKey!.isNotEmpty &&
        bankAccount.pixType != null &&
        bankAccount.pixType!.isNotEmpty;

    // Verificar Conta Bancária
    final hasBankAccount = bankAccount.agency != null &&
        bankAccount.agency!.isNotEmpty &&
        bankAccount.accountNumber != null &&
        bankAccount.accountNumber!.isNotEmpty &&
        bankAccount.accountType != null &&
        bankAccount.accountType!.isNotEmpty;

    final isValid = hasPix || hasBankAccount;

    return ArtistInfoStatusEntity(
      type: ArtistInfoType.bankAccount,
      category: ArtistInfoCategory.approvalRequired,
      isComplete: isValid,
      missingItems: isValid ? [] : ['PIX ou Conta Bancária'],
    );
  }

  /// Verifica se há foto de perfil
  ArtistInfoStatusEntity _checkProfilePicture(ArtistEntity artist) {
    final hasProfilePicture = artist.profilePicture != null &&
        artist.profilePicture!.isNotEmpty;

    return ArtistInfoStatusEntity(
      type: ArtistInfoType.profilePicture,
      category: ArtistInfoCategory.exploreRequired,
      isComplete: hasProfilePicture,
      missingItems: hasProfilePicture ? [] : ['Foto de perfil'],
    );
  }

  /// Verifica se há pelo menos uma disponibilidade ativa
  /// 
  /// Uma disponibilidade é considerada ativa se:
  /// - dataFim >= hoje (disponibilidade futura)
  ArtistInfoStatusEntity _checkAvailability(List<AvailabilityDayEntity> availabilities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final hasActiveAvailability = availabilities.any((availability) {
      final endDate = DateTime(
        availability.date.year,
        availability.date.month,
        availability.date.day,
      );
      return endDate.isAfter(today) || endDate.isAtSameMomentAs(today);
    });

    return ArtistInfoStatusEntity(
      type: ArtistInfoType.availability,
      category: ArtistInfoCategory.exploreRequired,
      isComplete: hasActiveAvailability,
      missingItems: hasActiveAvailability ? [] : ['Pelo menos uma disponibilidade ativa'],
    );
  }

  /// Verifica se há informações profissionais
  ArtistInfoStatusEntity _checkProfessionalInfo(ArtistEntity artist) {
    final hasProfessionalInfo = artist.professionalInfo != null;

    return ArtistInfoStatusEntity(
      type: ArtistInfoType.professionalInfo,
      category: ArtistInfoCategory.optional,
      isComplete: hasProfessionalInfo,
      missingItems: hasProfessionalInfo ? [] : ['Informações profissionais'],
    );
  }

  /// Verifica se há apresentações
  ArtistInfoStatusEntity _checkPresentations(ArtistEntity artist) {
    final hasPresentations = artist.presentationMedias != null &&
        artist.presentationMedias!.isNotEmpty;

    return ArtistInfoStatusEntity(
      type: ArtistInfoType.presentations,
      category: ArtistInfoCategory.optional,
      isComplete: hasPresentations,
      missingItems: hasPresentations ? [] : ['Apresentações'],
    );
  }

  /// Retorna nome amigável do tipo de documento
  String _getDocumentTypeName(DocumentTypeEnum type) {
    switch (type) {
      case DocumentTypeEnum.identity:
        return 'Identidade';
      case DocumentTypeEnum.residence:
        return 'Comprovante de Residência';
      case DocumentTypeEnum.curriculum:
        return 'Currículo';
      case DocumentTypeEnum.antecedents:
        return 'Certidão de Antecedentes';
    }
  }
}
