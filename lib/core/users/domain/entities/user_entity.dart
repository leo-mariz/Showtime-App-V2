import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:app/core/users/domain/entities/cnpj/cnpj_user_entity.dart';
import 'package:app/core/users/domain/entities/cpf/cpf_user_entity.dart';
part 'user_entity.mapper.dart';


@MappableClass()
class UserEntity with UserEntityMappable{
  String? uid;
  final String email;
  String? password;
  final String? phoneNumber;
  final CpfUserEntity? cpfUser;
  final CnpjUserEntity? cnpjUser;
  // Control Variables
  bool? isCnpj;
  bool? isArtist;
  bool? isEmailVerified;
  bool? isActive;
  bool? agreedToPrivacyPolicy;
  bool? isDeleted = false;
  bool? isDeletedByAdmin = false;
  DateTime? deletedAt;

  UserEntity({
    this.uid,
    required this.email,
    this.password,
    this.phoneNumber,
    this.cpfUser,
    this.cnpjUser,
    this.isCnpj,
    this.isArtist,
    this.isEmailVerified,
    this.isActive,
    this.agreedToPrivacyPolicy,
    this.isDeleted,
    this.isDeletedByAdmin,
    this.deletedAt,
  });

}


extension UserEntityReference on UserEntity {
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    return firestore.collection('Users').doc(uid);
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('Users');
  }

  static String cachedKey() {
    return 'CACHED_USER_INFO';
  }

  static List<String> userFields = [
    'email',
    'password',
    'phoneNumber',
  ];
}

