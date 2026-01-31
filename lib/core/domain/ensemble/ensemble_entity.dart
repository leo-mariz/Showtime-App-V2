import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Integrantes do conjunto
  final List<EnsembleMemberEntity>? members;

  /// URL do vídeo de apresentação (até 60s)
  final String? presentationVideoUrl;

  bool? isActive;

  bool? allMembersApproved;

  bool? hasIncompleteSections;

  Map<String, List<String>>? incompleteSections;

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
  });
}

/// Chaves de serialização do [EnsembleEntity] (alinhadas ao mapper).
/// Usar em vez de strings hardcoded ao manipular mapas.
abstract class EnsembleEntityKeys {
  static const String id = 'id';
  static const String ownerArtistId = 'ownerArtistId';
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
}
