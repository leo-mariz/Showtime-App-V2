import 'package:app/core/domain/artist/artist_groups/group_member_entity.dart';
import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
// import 'package:app/core/domain/entities/artist/social_media_links_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'group_entity.mapper.dart';

@MappableClass()
class GroupEntity with GroupEntityMappable {
  String? uid;
  String? profilePicture;
  String? groupName;
  ProfessionalInfoEntity? professionalInfo;
  Map<String, String>? presentationMedias;
  List<GroupMemberEntity>? members;
  List<String>? invitationEmails;
  DateTime? dateRegistered;
  bool? isActive;
  bool? hasIncompleteSections;
  Map<String, List<String>>? incompleteSections;
  // SocialMediaLinksEntity? socialMediaLinks;

  GroupEntity({
    this.uid,
    this.profilePicture,
    this.groupName,
    this.professionalInfo,
    this.presentationMedias,
    this.dateRegistered,
    this.isActive,
    this.hasIncompleteSections,
    this.incompleteSections,
    this.members,
    this.invitationEmails,
    // this.socialMediaLinks,
  });

  // Método de fábrica para criar uma entidade padrão
  factory GroupEntity.defaultEntity() {
    return GroupEntity(
      dateRegistered: DateTime.now(),
      isActive: false,
    );
  }
}
  
extension GroupEntityReference on GroupEntity {

  static String collectionName = 'Groups';
  
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final groupCollectionRef = firestore.collection(collectionName);
    return groupCollectionRef.doc(uid);
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection(collectionName);
  }

  static Reference firestorageReference(String uid) {
    return FirebaseStorage.instance.ref().child(collectionName).child(uid);
  }

  static Reference firestorageProfilePictureReference(String uid) {
    return firestorageReference(uid).child('profilePicture');
  }

  static Reference firestoragePresentationMediasReference(String uid) {
    return firestorageReference(uid).child('presentationMedias');
  }

  static String listCachedKey() {
    return 'CACHED_GROUPS_INFO_LIST';
  }

  static String singleCachedKey(String uid) {
    return 'CACHED_GROUP_INFO_$uid';
  }
}




  
