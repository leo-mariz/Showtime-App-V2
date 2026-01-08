import 'package:dart_mappable/dart_mappable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
part 'event_type_entity.mapper.dart';

@MappableClass()
class EventTypeEntity with EventTypeEntityMappable {    
  final String uid;
  final String name;
  final String active;

  EventTypeEntity({
    required this.uid,
    required this.name,
    required this.active,
  });
}

extension EventTypeEntityReference on EventTypeEntity {
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final eventTypeCollectionRef = firestore.collection('EventTypes');
    return eventTypeCollectionRef.doc(uid);
  }

  static Query<Map<String, dynamic>> firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('EventTypes').where('active', isEqualTo: true);
  }

  static Reference firestorageReference(String uid) {
    return FirebaseStorage.instance.ref().child('EventTypes').child(uid);
  }

  static String cachedKey() {
    return 'CACHED_EVENT_TYPE_INFO';
  }

  static List<String> eventTypeFields = [
    'name',
  ];
}