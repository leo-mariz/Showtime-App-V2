import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'email_entity.mapper.dart';

@MappableClass()
class EmailEntity with EmailEntityMappable {
  String? id;
  String? key;
  String? fullName;
  String? from;
  List<String>? to;
  String subject;
  String body;
  bool isHtml;
  String? attachment;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  EmailEntity({
    this.id,
    this.key,
    this.fullName,
    this.from,
    this.to,
    required this.subject,
    required this.body,
    this.isHtml = false,
    this.attachment,
    this.status,
    this.createdAt,
    this.updatedAt,
  });
}

extension EmailEntityReference on EmailEntity {
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final emailCollectionRef = firestore.collection('Emails');
    return emailCollectionRef.doc(uid);
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('emails');
  }

  static String supportEmailsKey() {
    return 'SUPPORT_EMAILS';
  }

  static String artistEmailsKey() {
    return 'ARTIST_EMAILS';
  }

  static String appSupportEmail() {
    return 'contato@showtime.app.br';
  }
  
  
}
