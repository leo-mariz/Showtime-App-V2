import 'package:app/features/artist_availability/domain/usecases/add_availability_usecase.dart';
import 'package:app/features/artist_availability/domain/usecases/close_availability_usecase.dart';
import 'package:app/features/artist_availability/domain/usecases/delete_availability_usecase.dart';
import 'package:app/features/artist_availability/domain/usecases/get_availabilities_usecase.dart';
import 'package:app/features/artist_availability/domain/usecases/update_availability_usecase.dart';
import 'package:app/features/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetAvailabilitiesUseCase getAvailabilitiesUseCase;
  final AddAvailabilityUseCase addAvailabilityUseCase;
  final UpdateAvailabilityUseCase updateAvailabilityUseCase;
  final DeleteAvailabilityUseCase deleteAvailabilityUseCase;
  final CloseAvailabilityUseCase closeAvailabilityUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  AvailabilityBloc({
    required this.getAvailabilitiesUseCase,
    required this.addAvailabilityUseCase,
    required this.updateAvailabilityUseCase,
    required this.deleteAvailabilityUseCase,
    required this.closeAvailabilityUseCase,
    required this.getUserUidUseCase,
  }) : super(AvailabilityInitial()) {
    on<GetAvailabilitiesEvent>(_onGetAvailabilitiesEvent);
    on<AddAvailabilityEvent>(_onAddAvailabilityEvent);
    on<UpdateAvailabilityEvent>(_onUpdateAvailabilityEvent);
    on<DeleteAvailabilityEvent>(_onDeleteAvailabilityEvent);
    on<CloseAvailabilityEvent>(_onCloseAvailabilityEvent);
  }

  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET AVAILABILITIES ====================

  Future<void> _onGetAvailabilitiesEvent(
    GetAvailabilitiesEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(GetAvailabilitiesLoading());

    final uid = await _getCurrentUserId();

    final result = await getAvailabilitiesUseCase.call(uid!);

    result.fold(
      (failure) {
        emit(GetAvailabilitiesFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (availabilities) {
        emit(GetAvailabilitiesSuccess(availabilities: availabilities));
      },
    );
  }

  // ==================== ADD AVAILABILITY ====================

  Future<void> _onAddAvailabilityEvent(
    AddAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AddAvailabilityLoading());

    final uid = await _getCurrentUserId();

    final result = await addAvailabilityUseCase.call(uid!, event.availability);

    result.fold(
      (failure) {
        emit(AddAvailabilityFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (_) {
        emit(AddAvailabilitySuccess());
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== UPDATE AVAILABILITY ====================

  Future<void> _onUpdateAvailabilityEvent(
    UpdateAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(UpdateAvailabilityLoading());

    final uid = await _getCurrentUserId();

    final result = await updateAvailabilityUseCase.call(
      artistId: uid!,
      availabilityId: event.availabilityId,
      raioAtuacao: event.raioAtuacao,
      valorShow: event.valorShow,
      blockedSlots: event.blockedSlots,
    );

    result.fold(
      (failure) {
        emit(UpdateAvailabilityFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (_) {
        emit(UpdateAvailabilitySuccess());
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== DELETE AVAILABILITY ====================

  Future<void> _onDeleteAvailabilityEvent(
    DeleteAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(DeleteAvailabilityLoading());

    final uid = await _getCurrentUserId();

    final result = await deleteAvailabilityUseCase.call(
      artistId: uid!,
      availabilityId: event.availabilityId,
    );

    result.fold(
      (failure) {
        emit(DeleteAvailabilityFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (_) {
        emit(DeleteAvailabilitySuccess());
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== CLOSE AVAILABILITY ====================

  Future<void> _onCloseAvailabilityEvent(
    CloseAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(CloseAvailabilityLoading());

    final uid = await _getCurrentUserId();

    final result = await closeAvailabilityUseCase.call(uid!, event.closeAppointment);

    result.fold(
      (failure) {
        emit(CloseAvailabilityFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (_) {
        emit(CloseAvailabilitySuccess());
        emit(AvailabilityInitial());
      },
    );
  }
}

