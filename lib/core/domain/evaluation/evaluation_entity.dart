import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'evaluation_entity.mapper.dart';

@MappableClass()
class EvaluationEntity with EvaluationEntityMappable {
  final String uid;
  final String? comment;
  final int rating;
  final String userId;
  final String artistId;
  final String eventId;

  EvaluationEntity({
    required this.uid,
    this.comment,
    required this.rating,
    required this.userId,
    required this.artistId,
    required this.eventId,
  });
}

extension EvaluationEntityReference on EvaluationEntity {
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final evaluationCollectionRef = firestore.collection('Evaluations');
    return evaluationCollectionRef.doc(uid);
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('Evaluations');
  }

  static String cachedKey() {
    return 'CACHED_EVALUATION_INFO';
  }
  
  static List<String> evaluationFields = [
    'uid',
    'comment',
    'rating',
    'userId',
    'artistId',
    'eventId',
  ];
}