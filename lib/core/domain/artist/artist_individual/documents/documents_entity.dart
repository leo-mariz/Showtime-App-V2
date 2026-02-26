import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/enums/document_status_enum.dart';
import 'package:app/core/enums/document_type_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:firebase_storage/firebase_storage.dart';
part 'documents_entity.mapper.dart';


@MappableClass()
class DocumentsEntity with DocumentsEntityMappable {
  String? idNumber;
  String documentType; // Armazena como String no Firestore (ex: "Identity", "Residence", etc.)
  String? documentOption;
  String? url;
  int status; // Armazena como int no Firestore (0, 1, 2, 3)
  AddressInfoEntity? address;
  String? observation;
  DateTime? updatedAt;

  DocumentsEntity({
    required this.documentType,
    this.documentOption,
    this.url,
    this.status = 0,
    this.observation,
    this.address,
    this.idNumber,
    this.updatedAt,
  });
}

/// Extension para facilitar conversão entre enums e valores primitivos
extension DocumentsEntityHelpers on DocumentsEntity {
  /// Obtém o DocumentTypeEnum correspondente ao documentType
  DocumentTypeEnum get documentTypeEnum {
    return DocumentTypeEnum.values.firstWhere(
      (type) => type.name == documentType,
      orElse: () => DocumentTypeEnum.identity,
    );
  }

  /// Define o documentType a partir de um DocumentTypeEnum
  DocumentsEntity copyWithDocumentType(DocumentTypeEnum type) {
    return copyWith(documentType: type.name);
  }

  /// Obtém o DocumentStatusEnum correspondente ao status
  DocumentStatusEnum get statusEnum {
    return DocumentStatusEnum.fromValue(status);
  }

  /// Define o status a partir de um DocumentStatusEnum
  DocumentsEntity copyWithStatus(DocumentStatusEnum status) {
    return copyWith(status: status.value);
  }
}

extension DocumentsEntityReference on DocumentsEntity {
  //Firestore References
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid, String documentType) {
    final artistCollectionRef = ArtistEntityReference.firebaseUidReference(firestore, uid);
    return artistCollectionRef.collection('Documents').doc(documentType);
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore, String uid) {
    final artistCollectionRef = ArtistEntityReference.firebaseUidReference(firestore, uid);
    return artistCollectionRef.collection('Documents');
  }

  //Firebase Storage References
  static Reference firestorageReference(String uid, String documentType) {
    final artistCollectionRef = ArtistEntityReference.firestorageReference(uid);
    return artistCollectionRef.child('Documents').child(documentType);
  }

  static String cachedKey() {
    return 'CACHED_ARTIST_DOCUMENTS';
  }
}

extension DocumentsEntityOptions on DocumentsEntity {
  /// Retorna lista de tipos de documento como String (para compatibilidade)
  static List<String> documentTypes() {
    return DocumentTypeEnum.values.map((type) => type.name).toList();
  }

  /// Retorna lista de tipos de documento como Enum
  static List<DocumentTypeEnum> documentTypeEnums() {
    return DocumentTypeEnum.values;
  }

  static List<String> identityDocumentOptions() {
    return [
      'RG',
      'CNH',
    ];
  }

  static List<String> residenceDocumentOptions() {
    return [
      'Conta de Consumo',
      'Conta de Telefone',
      'Extrato Bancário',
      'Outro',
    ];
  }

  static List<String> curriculumDocumentOptions() {
    return [
      'PDF',
    ];
  }

  static List<String> antecedentsDocumentOptions() {
    return [
      'Certidão de Antecedentes Criminais',
    ];
  }

  /// Retorna opções de documento por tipo (usando String para compatibilidade)
  static Map<String, List<String>> documentOptions() {
    return {
      DocumentTypeEnum.identity.name: identityDocumentOptions(),
      DocumentTypeEnum.residence.name: residenceDocumentOptions(),
      DocumentTypeEnum.curriculum.name: curriculumDocumentOptions(),
      DocumentTypeEnum.antecedents.name: antecedentsDocumentOptions(),
    };
  }

  /// Retorna opções de documento por tipo (usando Enum)
  static Map<DocumentTypeEnum, List<String>> documentOptionsByEnum() {
    return {
      DocumentTypeEnum.identity: identityDocumentOptions(),
      DocumentTypeEnum.residence: residenceDocumentOptions(),
      DocumentTypeEnum.curriculum: curriculumDocumentOptions(),
      DocumentTypeEnum.antecedents: antecedentsDocumentOptions(),
    };
  }
}