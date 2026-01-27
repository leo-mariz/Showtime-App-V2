import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AddressesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET ADDRESSES EVENTS ====================

class GetAddressesEvent extends AddressesEvent {}

// ==================== GET ADDRESS EVENT ====================

class GetAddressEvent extends AddressesEvent {
  final String addressId;

  GetAddressEvent({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

// ==================== ADD ADDRESS EVENTS ====================

class AddAddressEvent extends AddressesEvent {
  final AddressInfoEntity address;

  AddAddressEvent({
    required this.address,
  });

  @override
  List<Object?> get props => [address];
}

// ==================== UPDATE ADDRESS EVENTS ====================

class UpdateAddressEvent extends AddressesEvent {
  final String addressId;
  final AddressInfoEntity address;

  UpdateAddressEvent({
    required this.addressId,
    required this.address,
  });

  @override
  List<Object?> get props => [addressId, address];
}

// ==================== DELETE ADDRESS EVENTS ====================

class DeleteAddressEvent extends AddressesEvent {
  final String addressId;

  DeleteAddressEvent({
    required this.addressId,
  });

  @override
  List<Object?> get props => [addressId];
}

// ==================== SET PRIMARY ADDRESS EVENTS ====================

class SetPrimaryAddressEvent extends AddressesEvent {
  final String addressId;

  SetPrimaryAddressEvent({
    required this.addressId,
  });

  @override
  List<Object?> get props => [addressId];
}

// ==================== RESET EVENT ====================

class ResetAddressesEvent extends AddressesEvent {}
