import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/event/event_type/event_type_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dart_mappable/dart_mappable.dart';
part  'event_entity.mapper.dart';

@MappableClass()
class EventEntity with EventEntityMappable {
  final String? uid;
  final String? refArtist;
  final String? refContractor;
  final String? nameArtist;
  final String? nameContractor;
  final DateTime? date;
  final String time;
  final int duration;
  final AddressInfoEntity? address;
  final String status;
  final String statusPayment;
  final String linkPayment;
  final EventTypeEntity? eventType;
  final double value;
  final String? keyCode;
  final double rating;
  
  EventEntity({
    required this.date,
    required this.time,
    required this.duration,
    required this.address,
    this.uid,
    this.refArtist,
    this.refContractor,
    this.nameArtist,
    this.nameContractor,
    this.status = "PENDING",
    this.eventType,
    this.statusPayment = "PENDING",
    this.linkPayment = "",
    this.value = 0.0,
    this.keyCode,
    this.rating = 0.0,
  });
}

extension EventEntityReference on EventEntity {
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final eventCollectionRef = firestore.collection('Events');
    return eventCollectionRef.doc(uid);
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> firebaseStreamReference(FirebaseFirestore firestore, String uid) {
    final eventCollectionRef = firestore.collection('Events').doc(uid);
    return eventCollectionRef.snapshots();
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('Events');
  }

  static Reference firestorageReference(String uid) {
    return FirebaseStorage.instance.ref().child('Events').child(uid);
  }

  static String cachedKey() {
    return 'CACHED_EVENT_INFO';
  }

  static List<String> eventFields = [
    'uid',
    'date',
    'time',
    'duration',
    'address',
    'type',
    'status',
    'statusPayment',
    'linkPayment',
    'nameArtist',
    'nameContractor',
    'value',
    'rating',
    'keyCode',
  ];
}