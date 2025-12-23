import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AddressesState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AddressesInitial extends AddressesState {}

// ==================== GET ADDRESSES STATES ====================

class GetAddressesLoading extends AddressesState {}

class GetAddressesSuccess extends AddressesState {
  final List<AddressInfoEntity> addresses;

  GetAddressesSuccess({
    required this.addresses,
  });

  @override
  List<Object?> get props => [addresses];
}

class GetAddressesFailure extends AddressesState {
  final String error;

  GetAddressesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET ADDRESS STATES ====================

class GetAddressLoading extends AddressesState {}

class GetAddressSuccess extends AddressesState {
  final AddressInfoEntity address;

  GetAddressSuccess({required this.address});

  @override
  List<Object?> get props => [address];
}

class GetAddressFailure extends AddressesState {
  final String error;

  GetAddressFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== ADD ADDRESS STATES ====================

class AddAddressLoading extends AddressesState {}

class AddAddressSuccess extends AddressesState {
  final String addressId;
  final AddressInfoEntity address;

  AddAddressSuccess({
    required this.addressId,
    required this.address,
  });

  @override
  List<Object?> get props => [addressId, address];
}

class AddAddressFailure extends AddressesState {
  final String error;

  AddAddressFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ADDRESS STATES ====================

class UpdateAddressLoading extends AddressesState {}

class UpdateAddressSuccess extends AddressesState {
  final AddressInfoEntity address;

  UpdateAddressSuccess({required this.address});

  @override
  List<Object?> get props => [address];
}

class UpdateAddressFailure extends AddressesState {
  final String error;

  UpdateAddressFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== DELETE ADDRESS STATES ====================

class DeleteAddressLoading extends AddressesState {}

class DeleteAddressSuccess extends AddressesState {
  final String addressId;

  DeleteAddressSuccess({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

class DeleteAddressFailure extends AddressesState {
  final String error;

  DeleteAddressFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== SET PRIMARY ADDRESS STATES ====================

class SetPrimaryAddressLoading extends AddressesState {}

class SetPrimaryAddressSuccess extends AddressesState {
  final String addressId;

  SetPrimaryAddressSuccess({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

class SetPrimaryAddressFailure extends AddressesState {
  final String error;

  SetPrimaryAddressFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

