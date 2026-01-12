// app/lib/core/domain/contract/confirmation_entity.dart
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'key_code_entity.mapper.dart';

@MappableClass()
class ConfirmationEntity with ConfirmationEntityMappable {
  final String keyCode;
  final DateTime createdAt;

  ConfirmationEntity({
    required this.keyCode,
    required this.createdAt,
  });
}

extension ConfirmationEntityReference on ConfirmationEntity {
  static DocumentReference firebaseReference(
    FirebaseFirestore firestore,
    String contractId,
  ) {
    final contractDocRef = ContractEntityReference.firebaseUidReference(firestore, contractId);
    return contractDocRef.collection('Confirmation').doc('keyCode');
  }
}