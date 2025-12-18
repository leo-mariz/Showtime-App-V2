import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'address_info_entity.mapper.dart';

@MappableClass()
class AddressInfoEntity with AddressInfoEntityMappable {
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
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    return firestore.collection('Addresses').doc(uid);
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('Addresses');
  }

  static String cachedKey() {
    return 'CACHE_ADDRESSES_INFO';
  }
}

