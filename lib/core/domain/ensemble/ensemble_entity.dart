import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_member.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'ensemble_entity.mapper.dart';

/// Entidade que representa um conjunto (ensemble) do artista.
/// Vinculada apenas à conta principal (owner); não possui CNPJ.
@MappableClass()
class EnsembleEntity with EnsembleEntityMappable {
  /// ID único do conjunto (document ID no Firestore)
  final String? id;

  /// ID do artista dono do conjunto (conta principal)
  final String ownerArtistId;

  /// URL da foto de perfil do conjunto
  final String? profilePhotoUrl;

  /// Informações profissionais do conjunto (igual à estrutura do artista)
  final ProfessionalInfoEntity? professionalInfo;

  /// Integrantes do conjunto (referência + talentos no grupo). Dados completos em members feature.
  final List<EnsembleMember>? members;

  /// URL do vídeo de apresentação (até 60s)
  final String? presentationVideoUrl;

  bool? isActive;

  bool? allMembersApproved;

  bool? hasIncompleteSections;

  Map<String, List<String>>? incompleteSections;


  double? rating;
  int? rateCount;
  List<String>? contractsRatedUids;

  /// Data de criação
  final DateTime? createdAt;

  /// Data de atualização
  final DateTime? updatedAt;

  EnsembleEntity({
    this.id,
    required this.ownerArtistId,
    this.profilePhotoUrl,
    this.professionalInfo,
    this.presentationVideoUrl,
    this.members,
    this.isActive,
    this.allMembersApproved,
    this.hasIncompleteSections,
    this.incompleteSections,
    this.createdAt,
    this.updatedAt,
    this.rating,
    this.rateCount,
    this.contractsRatedUids,
  });
}

/// Chaves de serialização do [EnsembleEntity] (alinhadas ao mapper).
/// Usar em vez de strings hardcoded ao manipular mapas.
abstract class EnsembleEntityKeys {
  static const String id = 'id';
  static const String ownerArtistId = 'ownerArtistId';
  static const String profilePhotoUrl = 'profilePhotoUrl';
  static const String professionalInfo = 'professionalInfo';
  static const String presentationVideoUrl = 'presentationVideoUrl';
  static const String members = 'members';
  static const String isActive = 'isActive';
  static const String allMembersApproved = 'allMembersApproved';
  static const String hasIncompleteSections = 'hasIncompleteSections';
  static const String incompleteSections = 'incompleteSections';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}

extension EnsembleEntityReference on EnsembleEntity {
  /// Referência ao documento do conjunto no Firestore.
  static String remoteKey = 'Ensembles';

  static String cacheKey = 'CACHED_ENSEMBLES_INFO';

  static String cachedKey() {
    return cacheKey;
  }

  static String cacheEnsembleKey(String ensembleId) {
    return '${cacheKey}_$ensembleId';
  }

  /// Caminho: Artists/{artistId}/Ensembles/{ensembleId}
  static DocumentReference firebaseEnsembleReference(
    FirebaseFirestore firestore,
    String ensembleId,
  ) {
    return firestore.collection(remoteKey).doc(ensembleId);

  }

  /// Referência à coleção de conjuntos do artista.
  static CollectionReference firebaseEnsemblesCollectionReference(
    FirebaseFirestore firestore,
  ) {
    return firestore.collection(remoteKey);
  }

  /// Referência no Firebase Storage para a foto de perfil do conjunto.
  static Reference firestorageProfilePictureReference(String ensembleId) {
    return FirebaseStorage.instance
        .ref()
        .child('Ensembles')
        .child(ensembleId)
        .child('profilePicture');
  }

  /// Referência no Firebase Storage para o vídeo de apresentação do conjunto.
  static Reference firestoragePresentationVideoReference(String ensembleId) {
    return FirebaseStorage.instance
        .ref()
        .child('Ensembles')
        .child(ensembleId)
        .child('presentationVideo');
  }
}
