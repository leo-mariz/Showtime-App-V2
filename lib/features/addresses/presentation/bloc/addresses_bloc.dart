import 'package:app/features/addresses/domain/usecases/add_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/delete_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/get_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/get_addresses_usecase.dart';
import 'package:app/features/addresses/domain/usecases/set_primary_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/update_address_usecase.dart';
import 'package:app/features/addresses/presentation/bloc/events/addresses_events.dart';
import 'package:app/features/addresses/presentation/bloc/states/addresses_states.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressesBloc extends Bloc<AddressesEvent, AddressesState> {
  final GetAddressesUseCase getAddressesUseCase;
  final GetAddressUseCase getAddressUseCase;
  final AddAddressUseCase addAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final SetPrimaryAddressUseCase setPrimaryAddressUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  AddressesBloc({
    required this.getAddressesUseCase,
    required this.getAddressUseCase,
    required this.addAddressUseCase,
    required this.updateAddressUseCase,
    required this.deleteAddressUseCase,
    required this.setPrimaryAddressUseCase,
    required this.getUserUidUseCase,
  }) : super(AddressesInitial()) {
    on<GetAddressesEvent>(_onGetAddressesEvent);
    on<GetAddressEvent>(_onGetAddressEvent);
    on<AddAddressEvent>(_onAddAddressEvent);
    on<UpdateAddressEvent>(_onUpdateAddressEvent);
    on<DeleteAddressEvent>(_onDeleteAddressEvent);
    on<SetPrimaryAddressEvent>(_onSetPrimaryAddressEvent);
  }

  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET ADDRESSES ====================

  Future<void> _onGetAddressesEvent(
    GetAddressesEvent event,
    Emitter<AddressesState> emit,
  ) async {
    emit(GetAddressesLoading());

    final uid = await _getCurrentUserId();

    // Busca endereços com IDs
    final result = await getAddressesUseCase.call(uid!);

    result.fold(
      (failure) {
        emit(GetAddressesFailure(error: failure.message));
        emit(AddressesInitial());
      },
      (addresses) {
        emit(GetAddressesSuccess(
          addresses: addresses,
        ));
        emit(AddressesInitial());
      },
    );
  }

  // ==================== GET ADDRESS ====================

  Future<void> _onGetAddressEvent(
    GetAddressEvent event,
    Emitter<AddressesState> emit,
  ) async {
    emit(GetAddressLoading());

    final uid = await _getCurrentUserId();

    final result = await getAddressUseCase.call(uid!, event.addressId);

    result.fold(
      (failure) {
        emit(GetAddressFailure(error: failure.message));
        emit(AddressesInitial());
      },
      (address) {
        emit(GetAddressSuccess(address: address));
        emit(AddressesInitial());
      },
    );
  }

  // ==================== ADD ADDRESS ====================

  Future<void> _onAddAddressEvent(
    AddAddressEvent event,
    Emitter<AddressesState> emit,
  ) async {
    emit(AddAddressLoading());

    final uid = await _getCurrentUserId();

    final result = await addAddressUseCase.call(uid!, event.address);

    result.fold(
      (failure) {
        emit(AddAddressFailure(error: failure.message));
        emit(AddressesInitial());
      },
      (addressId) {
        emit(AddAddressSuccess(
          addressId: addressId,
          address: event.address,
        ));
        emit(AddressesInitial());
      },
    );
  }

  // ==================== UPDATE ADDRESS ====================

  Future<void> _onUpdateAddressEvent(
    UpdateAddressEvent event,
    Emitter<AddressesState> emit,
  ) async {
    emit(UpdateAddressLoading());

    final uid = await _getCurrentUserId();

    final result = await updateAddressUseCase.call(
      uid!,
      event.address,
    );

    result.fold(
      (failure) {
        emit(UpdateAddressFailure(error: failure.message));
        emit(AddressesInitial());
      },
      (_) {
        emit(UpdateAddressSuccess(address: event.address));
        emit(AddressesInitial());
      },
    );
  }

  // ==================== DELETE ADDRESS ====================

  Future<void> _onDeleteAddressEvent(
    DeleteAddressEvent event,
    Emitter<AddressesState> emit,
  ) async {
    emit(DeleteAddressLoading());

    final uid = await _getCurrentUserId();

    final result = await deleteAddressUseCase.call(uid!, event.addressId);

    result.fold(
      (failure) {
        emit(DeleteAddressFailure(error: failure.message));
        emit(AddressesInitial());
      },
      (_) {
        emit(DeleteAddressSuccess(addressId: event.addressId));
        emit(AddressesInitial());
      },
    );
  }

  // ==================== SET PRIMARY ADDRESS ====================

  Future<void> _onSetPrimaryAddressEvent(
    SetPrimaryAddressEvent event,
    Emitter<AddressesState> emit,
  ) async {
    emit(SetPrimaryAddressLoading());

    final uid = await _getCurrentUserId();

    final result = await setPrimaryAddressUseCase.call(uid!, event.addressId);

    result.fold(
      (failure) {
        emit(SetPrimaryAddressFailure(error: failure.message));
        emit(AddressesInitial());
      },
      (_) {
        emit(SetPrimaryAddressSuccess(addressId: event.addressId));
        emit(AddressesInitial());
      },
    );
  }
}

