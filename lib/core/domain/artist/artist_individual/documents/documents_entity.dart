import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:firebase_storage/firebase_storage.dart';
part 'documents_entity.mapper.dart';





@MappableClass()
class DocumentsEntity with DocumentsEntityMappable {
  String documentType;
  String? documentOption;
  String? url;
  int status; // 0 - pending, 1 - analysis, 2 - approved, 3 - rejected
  AddressInfoEntity? address;
  String? idNumber;
  String? observation;

  DocumentsEntity({
    required this.documentType,
    this.documentOption,
    this.url,
    this.status = 0,
    this.observation,
    this.address,
    this.idNumber,
  });
}

extension DocumentsEntityReference on DocumentsEntity {
  //Firestore References
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid, String documentType) {
    final artistCollectionRef = ArtistEntityReference.firebaseUidReference(firestore, uid);
    return artistCollectionRef.collection('Documents').doc(documentType);
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
  static List<String> documentTypes() {
    return [
      'Identity',
      'Residence',
      'Curriculum',
      'Antecedents',
    ];
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
  
  

  static Map<String, List<String>> documentOptions() {
    return {
      'Identity': identityDocumentOptions(),
      'Residence': residenceDocumentOptions(),
      'Curriculum': curriculumDocumentOptions(),
      'Antecedents': antecedentsDocumentOptions(),
    };
  }
  
}