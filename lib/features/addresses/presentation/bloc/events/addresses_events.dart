import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AddressesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET ADDRESSES EVENTS ====================

class GetAddressesEvent extends AddressesEvent {
  final String uid;

  GetAddressesEvent({required this.uid});

  @override
  List<Object?> get props => [uid];
}

// ==================== ADD ADDRESS EVENTS ====================

class AddAddressEvent extends AddressesEvent {
  final String uid;
  final AddressInfoEntity address;

  AddAddressEvent({
    required this.uid,
    required this.address,
  });

  @override
  List<Object?> get props => [uid, address];
}

// ==================== UPDATE ADDRESS EVENTS ====================

class UpdateAddressEvent extends AddressesEvent {
  final String uid;
  final String addressId;
  final AddressInfoEntity address;

  UpdateAddressEvent({
    required this.uid,
    required this.addressId,
    required this.address,
  });

  @override
  List<Object?> get props => [uid, addressId, address];
}

// ==================== DELETE ADDRESS EVENTS ====================

class DeleteAddressEvent extends AddressesEvent {
  final String uid;
  final String addressId;

  DeleteAddressEvent({
    required this.uid,
    required this.addressId,
  });

  @override
  List<Object?> get props => [uid, addressId];
}

// ==================== SET PRIMARY ADDRESS EVENTS ====================

class SetPrimaryAddressEvent extends AddressesEvent {
  final String uid;
  final String addressId;

  SetPrimaryAddressEvent({
    required this.uid,
    required this.addressId,
  });

  @override
  List<Object?> get props => [uid, addressId];
}

