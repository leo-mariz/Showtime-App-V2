import 'package:app/core/domain/user/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'address_info_entity.mapper.dart';

@MappableClass()
class AddressInfoEntity with AddressInfoEntityMappable {
  String? uid;
  String title;
  @MappableField(key: 'cep')
  final String zipCode;
  @MappableField(key: 'logradouro')
  final String? street;
  final String? number;
  @MappableField(key: 'bairro')
  final String? district;
  @MappableField(key: 'localidade')
  final String? city;
  @MappableField(key: 'uf')
  final String? state;
  bool isPrimary;
  double? latitude;
  double? longitude;
  double? coverageRadius;
  String? complement;


  AddressInfoEntity({
    this.uid,
    this.title = '',
    required this.zipCode,
    this.street,
    this.number,
    this.district,
    this.city,
    this.state,
    this.isPrimary = false,
    this.latitude,
    this.longitude,
    this.coverageRadius,
    this.complement,
  });
}

extension AddressInfoEntityReference on AddressInfoEntity {
  /// Referência à subcoleção de endereços do usuário
  /// users/{uid}/Addresses
  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore, String uid) {
    final usersDocRef = UserEntityReference.firebaseUidReference(firestore, uid);
    return usersDocRef.collection('Addresses');
  }

  /// Referência a um documento específico na subcoleção de endereços
  /// users/{uid}/Addresses/{addressId}
  static DocumentReference firebaseDocumentReference(
    FirebaseFirestore firestore,
    String uid,
    String addressId,
  ) {
    return firebaseCollectionReference(firestore, uid).doc(addressId);
  }

  static String cachedKey() {
    return 'CACHE_ADDRESSES_INFO';
  }
}

