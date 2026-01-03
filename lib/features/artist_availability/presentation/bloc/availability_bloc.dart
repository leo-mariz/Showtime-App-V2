import 'package:app/features/artist_availability/domain/usecases/add_availability_usecase.dart';
import 'package:app/features/artist_availability/domain/usecases/close_availability_usecase.dart';
import 'package:app/features/artist_availability/domain/usecases/get_availabilities_usecase.dart';
import 'package:app/features/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetAvailabilitiesUseCase getAvailabilitiesUseCase;
  final AddAvailabilityUseCase addAvailabilityUseCase;
  final CloseAvailabilityUseCase closeAvailabilityUseCase;

  AvailabilityBloc({
    required this.getAvailabilitiesUseCase,
    required this.addAvailabilityUseCase,
    required this.closeAvailabilityUseCase,
  }) : super(AvailabilityInitial()) {
    on<GetAvailabilitiesEvent>(_onGetAvailabilitiesEvent);
    on<AddAvailabilityEvent>(_onAddAvailabilityEvent);
    on<CloseAvailabilityEvent>(_onCloseAvailabilityEvent);
  }

  // ==================== GET AVAILABILITIES ====================

  Future<void> _onGetAvailabilitiesEvent(
    GetAvailabilitiesEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(GetAvailabilitiesLoading());

    final result = await getAvailabilitiesUseCase.call();

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

    final result = await addAvailabilityUseCase.call(event.availability);

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

  // ==================== CLOSE AVAILABILITY ====================

  Future<void> _onCloseAvailabilityEvent(
    CloseAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(CloseAvailabilityLoading());

    final result = await closeAvailabilityUseCase.call(event.closeAppointment);

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

