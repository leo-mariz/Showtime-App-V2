import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_all_availabilities_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/toggle_availability_status_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/validation/get_organized_day_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/validation/get_organized_availabilities_after_verification_usecase.dart.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/period/open_period_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/period/close_period_usecase.dart';

/// Bloc para gerenciar estado da feature de disponibilidade do artista
/// 
/// Gerencia usecases de validação, consulta e manipulação de disponibilidades
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetUserUidUseCase getUserUidUseCase;
  final GetAllAvailabilitiesUseCase getAllAvailabilitiesUseCase;
  final ToggleAvailabilityStatusUseCase toggleAvailabilityStatusUseCase;
  final GetOrganizedDayAfterVerificationUseCase getOrganizedDayAfterVerificationUseCase;
  final GetOrganizedAvailabilitesAfterVerificationUseCase getOrganizedAvailabilitiesAfterVerificationUseCase;
  final OpenPeriodUseCase openPeriodUseCase;
  final ClosePeriodUseCase closePeriodUseCase;

  AvailabilityBloc({
    required this.getUserUidUseCase,
    required this.getAllAvailabilitiesUseCase,
    required this.toggleAvailabilityStatusUseCase,
    required this.getOrganizedDayAfterVerificationUseCase,
    required this.getOrganizedAvailabilitiesAfterVerificationUseCase,
    required this.openPeriodUseCase,
    required this.closePeriodUseCase,
  }) : super(AvailabilityInitial()) {
    on<AvailabilityInitialEvent>(_onAvailabilityInitialEvent);
    on<GetAllAvailabilitiesEvent>(_onGetAllAvailabilitiesEvent);
    on<ToggleAvailabilityStatusEvent>(_onToggleAvailabilityStatusEvent);
    on<GetOrganizedDayAfterVerificationEvent>(_onGetOrganizedDayAfterVerificationEvent);
    on<GetOrganizedAvailabilitiesAfterVerificationEvent>(_onGetOrganizedAvailabilitiesAfterVerificationEvent);
    on<OpenPeriodEvent>(_onOpenPeriodEvent);
    on<ClosePeriodEvent>(_onClosePeriodEvent);
  }

  // ==================== INITIAL ====================

  void _onAvailabilityInitialEvent(
    AvailabilityInitialEvent event,
    Emitter<AvailabilityState> emit,
  ) {
    emit(AvailabilityInitial());
  }

  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET ALL AVAILABILITIES ====================

  Future<void> _onGetAllAvailabilitiesEvent(
    GetAllAvailabilitiesEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(GetAllAvailabilitiesLoading());
    final uid = await _getCurrentUserId();

    final result = await getAllAvailabilitiesUseCase(
      uid!,
      event.forceRemote,
    );

    result.fold(
      (failure) {
        emit(GetAllAvailabilitiesFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (availabilities) {
        emit(GetAllAvailabilitiesSuccess(availabilities: availabilities));
      },
    );
  }

  // ==================== TOGGLE AVAILABILITY STATUS ====================

  Future<void> _onToggleAvailabilityStatusEvent(
    ToggleAvailabilityStatusEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(ToggleAvailabilityStatusLoading());

    final uid = await _getCurrentUserId();

    final result = await toggleAvailabilityStatusUseCase(
      uid!,
      event.date,
      event.isActive,
    );

    result.fold(
      (failure) {
        emit(ToggleAvailabilityStatusFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (availability) {
        emit(ToggleAvailabilityStatusSuccess(availability: availability));
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== CHECK OVERLAP ON DAY ====================

  Future<void> _onGetOrganizedDayAfterVerificationEvent(
    GetOrganizedDayAfterVerificationEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(GetOrganizedDayAfterVerificationLoading());

    final uid = await _getCurrentUserId();

    final result = await getOrganizedDayAfterVerificationUseCase(
      uid!,
      event.date,
      event.dto,
      false,
    );

    result.fold(
      (failure) {
        emit(GetOrganizedDayAfterVerificationFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (dayResult) {
        emit(GetOrganizedDayAfterVerificationSuccess(result: dayResult));
      },
    );
  }

  // ==================== CHECK OVERLAPS ON PERIOD ====================

  Future<void> _onGetOrganizedAvailabilitiesAfterVerificationEvent(
    GetOrganizedAvailabilitiesAfterVerificationEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(GetOrganizedAvailabilitiesAfterVerificationLoading());

    final uid = await _getCurrentUserId();

    final result = await getOrganizedAvailabilitiesAfterVerificationUseCase(
      uid!,
      event.dto,
      event.isClose,
    );

    result.fold(
      (failure) {
        emit(GetOrganizedAvailabilitiesAfterVerificationFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (periodResult) {
        if (event.isClose) {
          emit(CloseOrganizedAvailabilitiesSuccess(result: periodResult));
        } else {
          emit(OpenOrganizedAvailabilitiesSuccess(result: periodResult));
        }
      },
    );
  }

  // ==================== OPEN PERIOD ====================

  Future<void> _onOpenPeriodEvent(
    OpenPeriodEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(OpenPeriodLoading());

    final uid = await _getCurrentUserId();

    final result = await openPeriodUseCase(
      uid!,
      event.dto,
    );

    result.fold(
      (failure) {
        emit(OpenPeriodFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (days) {
        emit(OpenPeriodSuccess(days: days));
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== CLOSE PERIOD ====================

  Future<void> _onClosePeriodEvent(
    ClosePeriodEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(ClosePeriodLoading());

    final uid = await _getCurrentUserId();

    final result = await closePeriodUseCase(
      uid!,
      event.dto,
    );

    result.fold(
      (failure) {
        emit(ClosePeriodFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (days) {
        emit(ClosePeriodSuccess(days: days));
        emit(AvailabilityInitial());
      },
    );
  }
}
