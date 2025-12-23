import 'package:app/features/addresses/domain/usecases/add_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/delete_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/get_addresses_usecase.dart';
import 'package:app/features/addresses/domain/usecases/set_primary_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/update_address_usecase.dart';
import 'package:app/features/addresses/presentation/bloc/events/addresses_events.dart';
import 'package:app/features/addresses/presentation/bloc/states/addresses_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressesBloc extends Bloc<AddressesEvent, AddressesState> {
  final GetAddressesUseCase getAddressesUseCase;
  final AddAddressUseCase addAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final SetPrimaryAddressUseCase setPrimaryAddressUseCase;

  AddressesBloc({
    required this.getAddressesUseCase,
    required this.addAddressUseCase,
    required this.updateAddressUseCase,
    required this.deleteAddressUseCase,
    required this.setPrimaryAddressUseCase,
  }) : super(AddressesInitial()) {
    on<GetAddressesEvent>(_onGetAddressesEvent);
    on<AddAddressEvent>(_onAddAddressEvent);
    on<UpdateAddressEvent>(_onUpdateAddressEvent);
    on<DeleteAddressEvent>(_onDeleteAddressEvent);
    on<SetPrimaryAddressEvent>(_onSetPrimaryAddressEvent);
  }

  // ==================== GET ADDRESSES ====================

  Future<void> _onGetAddressesEvent(
    GetAddressesEvent event,
    Emitter<AddressesState> emit,
  ) async {
    emit(GetAddressesLoading());

    final result = await getAddressesUseCase.call(event.uid);

    result.fold(
      (failure) {
        emit(GetAddressesFailure(error: failure.message));
        emit(AddressesInitial());
      },
      (addresses) {
        emit(GetAddressesSuccess(addresses: addresses));
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

    final result = await addAddressUseCase.call(event.uid, event.address);

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

    final result = await updateAddressUseCase.call(
      event.uid,
      event.addressId,
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

    final result = await deleteAddressUseCase.call(event.uid, event.addressId);

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

    final result = await setPrimaryAddressUseCase.call(event.uid, event.addressId);

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

