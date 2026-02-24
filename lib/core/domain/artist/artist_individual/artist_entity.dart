import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'artist_entity.mapper.dart';

@MappableClass()
class ArtistEntity with ArtistEntityMappable {
  String? uid;
  String? profilePicture;
  String? artistName;
  ProfessionalInfoEntity? professionalInfo;
  Map<String, String>? presentationMedias;
  final AddressInfoEntity? residenceAddress;
  List<String>? groupsUids;
  /// Seções incompletas: chave = tipo (camelCase), valor = itens faltando (hoje [chave]).
  /// Chaves: documents, bankAccount, profilePicture, availability, professionalInfo, presentations.
  /// Use [ArtistIncompleteInfoType.fromString(key)] para label e categoria no admin.
  Map<String, List<String>>? incompleteSections;
  bool? approved;
  bool? isActive;
  bool? hasIncompleteSections;
  bool? agreedToArtistTermsOfUse;
  bool? isOnAnyGroup;
  double? rating;
  int? rateCount;
  List<String>? contractsRatedUids;
  DateTime? dateRegistered;

  ArtistEntity({
    this.uid,
    this.profilePicture,
    this.artistName,
    this.dateRegistered,
    this.professionalInfo,
    this.presentationMedias,
    this.residenceAddress,
    this.approved,
    this.isActive,
    this.hasIncompleteSections,
    this.incompleteSections,
    this.agreedToArtistTermsOfUse,
    this.isOnAnyGroup,
    this.groupsUids,
    this.rating,
    this.rateCount,
    this.contractsRatedUids,
  });

  // Método de fábrica para criar uma entidade padrão
  factory ArtistEntity.defaultEntity() {
    return ArtistEntity(
      agreedToArtistTermsOfUse: true,
      dateRegistered: DateTime.now(),
      approved: false,
      isActive: false,
    );
  }
}
  
extension ArtistEntityReference on ArtistEntity {
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final artistCollectionRef = firestore.collection('Artists');
    return artistCollectionRef.doc(uid);
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('Artists');
  }

  static Reference firestorageReference(String uid) {
    return FirebaseStorage.instance.ref().child('Artists').child(uid);
  }

  static Reference firestorageProfilePictureReference(String uid) {
    return firestorageReference(uid).child('profilePicture');
  }

  static Reference firestoragePresentationMediasReference(String uid) {
    return firestorageReference(uid).child('presentationMedias');
  }

  static String cachedKey() {
    return 'CACHED_ARTIST_INFO';
  }
}




  
