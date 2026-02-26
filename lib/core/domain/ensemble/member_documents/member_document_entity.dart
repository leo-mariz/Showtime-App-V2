import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:firebase_storage/firebase_storage.dart';

part 'member_document_entity.mapper.dart';

/// Status do documento (identidade ou antecedentes) do integrante.
enum MemberDocumentStatus {
  pending,
  submitted,
  approved,
  rejected,
}

/// Tipo de documento do integrante (identidade ou antecedentes).
/// Usar em vez de strings hardcoded.
abstract class MemberDocumentType {
  static const String identity = 'identity';
  static const String antecedents = 'antecedents';
}

/// Chaves de serialização do [MemberDocumentEntity] (alinhadas ao mapper).
abstract class MemberDocumentEntityKeys {
  static const String documentType = 'documentType';
  static const String status = 'status';
  static const String url = 'url';
  static const String memberId = 'memberId';
  static const String ensembleId = 'ensembleId';
  static const String artistId = 'artistId';
}

/// Entidade que representa um documento (identidade ou antecedentes) de um integrante.
/// Sub-feature member_documents: domain puro; referências Firestore/Storage ficam na data.
@MappableClass()
class MemberDocumentEntity with MemberDocumentEntityMappable {
  /// ID do artista dono do conjunto
  final String artistId;

  /// ID do conjunto
  final String ensembleId;

  /// ID do integrante
  final String memberId;

  /// Tipo do documento: [MemberDocumentType.identity] ou [MemberDocumentType.antecedents]
  final String documentType;

  /// Status: 0 pending, 1 submitted, 2 approved, 3 rejected
  final int status;

  /// URL do arquivo no Storage (após upload)
  final String? url;

  String? documentOption;

  final String? observation;

  String? idNumber;

  final DateTime? updatedAt;



  MemberDocumentEntity({
    required this.artistId,
    required this.ensembleId,
    required this.memberId,
    required this.documentType,
    this.status = 0,
    this.url,
    this.documentOption,
    this.observation,
    this.idNumber,
    this.updatedAt,
  });
}


extension MemberDocumentEntityReference on MemberDocumentEntity {

  static String remoteKey = 'Documents';

  static String cacheKey = 'CACHED_MEMBER_DOCUMENT_INFO';

  static String cachedKey() {
    return cacheKey;
  }

  static String cacheMemberDocumentsKey(String memberId) {

    return '${cacheKey}_$memberId';
  }

  static Duration cacheValidity = Duration(hours: 2);

  /// Referência ao documento do documento no Firestore.
  /// Caminho: Artists/{artistId}/Ensembles/{ensembleId}/Members/{memberId}/Documents/{documentType}
  static DocumentReference firebaseMemberDocumentReference(
    FirebaseFirestore firestore,
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  ) {
    final ensembleRef = EnsembleMemberEntityReference.firebaseMemberReference(firestore, artistId, ensembleId, memberId);
    return ensembleRef.collection(remoteKey).doc(documentType);
  }

  /// Referência à coleção de documentos do integrante.
  static CollectionReference firebaseMemberDocumentsCollectionReference(
    FirebaseFirestore firestore,
    String artistId,
    String ensembleId,
    String memberId,
  ) {
    final ensembleRef = EnsembleMemberEntityReference.firebaseMemberReference(firestore, artistId, ensembleId, memberId);
    return ensembleRef.collection(remoteKey);
  }

  /// Referência no Firebase Storage para documento do integrante (identidade ou antecedentes).
  /// [documentType] 'identity' ou 'antecedents'
  static Reference firestorageMemberDocumentReference(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  ) {
    return FirebaseStorage.instance
        .ref()
        .child('EnsembleMembers')
        .child(artistId)
        .child('Members')
        .child(memberId)
        .child(documentType);
  }

  static List<String> identityDocumentOptions() {
    return [
      'RG',
      'CNH',
    ];
  }

  static List<String> antecedentsDocumentOptions() {
    return [
      'Certidão de Antecedentes Criminais',
    ];
  }
}