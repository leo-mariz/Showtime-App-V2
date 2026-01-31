import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'ensemble_member_entity.mapper.dart';

/// Status do documento (identidade ou antecedentes) do integrante.
enum EnsembleMemberDocumentStatus {
  pending,
  submitted,
  approved,
  rejected,
}

/// Tipo de documento do integrante (identidade ou antecedentes).
/// Usar em vez de strings hardcoded.
abstract class EnsembleMemberDocumentType {
  static const String identity = 'identity';
  static const String antecedents = 'antecedents';
}

/// Chaves de serialização do [EnsembleMemberEntity] (alinhadas ao mapper).
/// Usar em vez de strings hardcoded ao manipular mapas.
abstract class EnsembleMemberEntityKeys {
  static const String id = 'id';
  static const String ensembleId = 'ensembleId';
  static const String isOwner = 'isOwner';
  static const String artistId = 'artistId';
  static const String name = 'name';
  static const String cpf = 'cpf';
  static const String email = 'email';
  static const String identityDocumentUrl = 'identityDocumentUrl';
  static const String antecedentsDocumentUrl = 'antecedentsDocumentUrl';
  static const String identityStatus = 'identityStatus';
  static const String antecedentsStatus = 'antecedentsStatus';
  static const String order = 'order';
}

/// Entidade que representa um integrante do conjunto.
/// O dono (isOwner == true) tem artistId; os demais têm name, cpf, email e documentos.
@MappableClass()
class EnsembleMemberEntity with EnsembleMemberEntityMappable {
  /// ID único do integrante (document ID no Firestore)
  final String? id;

  /// ID do conjunto ao qual pertence
  final String ensembleId;

  /// Indica se é o dono do conjunto (conta principal)
  final bool isOwner;

  /// ID do artista (apenas quando isOwner == true)
  final String? artistId;

  /// Nome do integrante (quando não é o dono)
  final String? name;

  /// CPF do integrante (quando não é o dono)
  final String? cpf;

  /// E-mail do integrante (quando não é o dono)
  final String? email;

  /// Aproved
  final bool isApproved;

  const EnsembleMemberEntity({
    this.id,
    required this.ensembleId,
    this.isOwner = false,
    this.artistId,
    this.name,
    this.cpf,
    this.email,
    this.isApproved = false,
  });
}

extension EnsembleMemberEntityReference on EnsembleMemberEntity {
  /// Referência ao documento do integrante no Firestore.
  /// Caminho: Artists/{artistId}/Ensembles/{ensembleId}/Members/{memberId}
  static DocumentReference firebaseMemberReference(
    FirebaseFirestore firestore,
    String artistId,
    String ensembleId,
    String memberId,
  ) {
    final ensembleRef = firestore
        .collection('EnsembleMembers')
        .doc(artistId)
        .collection('Members')
        .doc(memberId);
    return ensembleRef;
  }

  /// Referência à coleção de integrantes do conjunto.
  static CollectionReference firebaseMembersCollectionReference(
    FirebaseFirestore firestore,
    String artistId,
    String ensembleId,
  ) {
    final ensembleRef = firestore
        .collection('EnsembleMembers')
        .doc(artistId)
        .collection('Members');
    return ensembleRef;
  }

  
}
