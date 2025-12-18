import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'client_entity.mapper.dart';

@MappableClass()
class ClientEntity with ClientEntityMappable {
  String? uid;
  String? profilePicture;
  final DateTime? dateRegistered;
  List<String>? preferences;
  bool? agreedToClientTermsOfUse;

  ClientEntity({
    this.uid,
    this.profilePicture,
    this.dateRegistered,
    this.preferences,
    this.agreedToClientTermsOfUse,
  });

  factory ClientEntity.defaultClientEntity() {
    return ClientEntity(
      dateRegistered: DateTime.now(),
    );
  }
}

extension ClientEntityReference on ClientEntity {
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final clientCollectionRef = firestore.collection('Clients');
    return clientCollectionRef.doc(uid);
  }


  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('Clients');
  }

  static Reference firestorageProfilePictureReference(String uid) {
    return FirebaseStorage.instance.ref().child('Clients').child(uid).child('profilePicture');
  }

  static String cachedKey() {
    return 'CACHED_CLIENT_INFO';
  }
}
