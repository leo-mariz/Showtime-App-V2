import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_all_availabilities_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/validation/get_organized_day_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/validation/get_organized_availabilities_after_verification_usecase.dart.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/period/open_period_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/period/close_period_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/update_availability_day_usecase.dart';

/// Bloc para gerenciar estado da feature de disponibilidade do artista
/// 
/// Gerencia usecases de validação, consulta e manipulação de disponibilidades
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetUserUidUseCase getUserUidUseCase;
  final GetAllAvailabilitiesUseCase getAllAvailabilitiesUseCase;
  final GetOrganizedDayAfterVerificationUseCase getOrganizedDayAfterVerificationUseCase;
  final GetOrganizedAvailabilitesAfterVerificationUseCase getOrganizedAvailabilitiesAfterVerificationUseCase;
  final OpenPeriodUseCase openPeriodUseCase;
  final ClosePeriodUseCase closePeriodUseCase;
  final UpdateAvailabilityDayUseCase updateAvailabilityDayUseCase;

  AvailabilityBloc({
    required this.getUserUidUseCase,
    required this.getAllAvailabilitiesUseCase,
    required this.getOrganizedDayAfterVerificationUseCase,
    required this.getOrganizedAvailabilitiesAfterVerificationUseCase,
    required this.openPeriodUseCase,
    required this.closePeriodUseCase,
    required this.updateAvailabilityDayUseCase,
  }) : super(AvailabilityInitial()) {
    on<AvailabilityInitialEvent>(_onAvailabilityInitialEvent);
    on<GetAllAvailabilitiesEvent>(_onGetAllAvailabilitiesEvent);
    on<GetOrganizedDayAfterVerificationEvent>(_onGetOrganizedDayAfterVerificationEvent);
    on<GetOrganizedAvailabilitiesAfterVerificationEvent>(_onGetOrganizedAvailabilitiesAfterVerificationEvent);
    on<OpenPeriodEvent>(_onOpenPeriodEvent);
    on<ClosePeriodEvent>(_onClosePeriodEvent);
    on<ToggleAvailabilityDayEvent>(_onToggleAvailabilityDayEvent);
    on<AddTimeSlotEvent>(_onAddTimeSlotEvent);
    on<UpdateTimeSlotEvent>(_onUpdateTimeSlotEvent);
    on<DeleteTimeSlotEvent>(_onDeleteTimeSlotEvent);
    on<UpdateAddressAndRadiusEvent>(_onUpdateAddressAndRadiusEvent);
    on<ResetAvailabilityEvent>(_onResetAvailabilityEvent);
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

  // ==================== TOGGLE AVAILABILITY DAY ====================

  Future<void> _onToggleAvailabilityDayEvent(
    ToggleAvailabilityDayEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(ToggleAvailabilityStatusLoading());

    final uid = await _getCurrentUserId();
    if (uid == null) {
      emit(ToggleAvailabilityStatusFailure(error: 'Usuário não autenticado'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(uid, event.dayEntity);

    result.fold(
      (failure) {
        emit(ToggleAvailabilityStatusFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (updatedAvailability) {
        emit(ToggleAvailabilityStatusSuccess(availability: updatedAvailability));
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== ADD TIME SLOT ====================

  Future<void> _onAddTimeSlotEvent(
    AddTimeSlotEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AddTimeSlotLoading());

    final uid = await _getCurrentUserId();
    if (uid == null) {
      emit(AddTimeSlotFailure(error: 'Usuário não autenticado'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(uid, event.dayEntity);

    result.fold(
      (failure) {
        emit(AddTimeSlotFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (updatedAvailability) {
        emit(AddTimeSlotSuccess(availability: updatedAvailability));
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== UPDATE TIME SLOT ====================

  Future<void> _onUpdateTimeSlotEvent(
    UpdateTimeSlotEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(UpdateTimeSlotLoading());

    final uid = await _getCurrentUserId();
    if (uid == null) {
      emit(UpdateTimeSlotFailure(error: 'Usuário não autenticado'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(uid, event.dayEntity);

    result.fold(
      (failure) {
        emit(UpdateTimeSlotFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (updatedAvailability) {
        emit(UpdateTimeSlotSuccess(availability: updatedAvailability));
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== DELETE TIME SLOT ====================

  Future<void> _onDeleteTimeSlotEvent(
    DeleteTimeSlotEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(DeleteTimeSlotLoading());

    final uid = await _getCurrentUserId();
    if (uid == null) {
      emit(DeleteTimeSlotFailure(error: 'Usuário não autenticado'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(uid, event.dayEntity);

    result.fold(
      (failure) {
        emit(DeleteTimeSlotFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (updatedAvailability) {
        emit(DeleteTimeSlotSuccess(availability: updatedAvailability));
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== UPDATE ADDRESS AND RADIUS ====================

  Future<void> _onUpdateAddressAndRadiusEvent(
    UpdateAddressAndRadiusEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(UpdateAddressAndRadiusLoading());

    final uid = await _getCurrentUserId();
    if (uid == null) {
      emit(UpdateAddressAndRadiusFailure(error: 'Usuário não autenticado'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(uid, event.dayEntity);

    result.fold(
      (failure) {
        emit(UpdateAddressAndRadiusFailure(error: failure.message));
        emit(AvailabilityInitial());
      },
      (updatedAvailability) {
        emit(UpdateAddressAndRadiusSuccess(availability: updatedAvailability));
        emit(AvailabilityInitial());
      },
    );
  }

  // ==================== RESET ====================

  Future<void> _onResetAvailabilityEvent(
    ResetAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityInitial());
  }
}
