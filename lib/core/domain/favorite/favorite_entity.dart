import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'favorite_entity.mapper.dart';

@MappableClass()
class FavoriteEntity with FavoriteEntityMappable {
  final String uid;
  final String artistId;
  final String userId;

  FavoriteEntity({required this.uid, required this.artistId, required this.userId});
}

extension FavoriteEntityReference on FavoriteEntity {
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final favoriteCollectionRef = firestore.collection('Favorites');
    return favoriteCollectionRef.doc(uid);
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('Favorites');
  }

  static String cachedKey() {
    return 'CACHED_FAVORITE_INFO';
  }

  static List<String> favoriteFields = [
    'uid',
    'artistId',
    'userId',
  ];
}