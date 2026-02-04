import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/ensemble/ensemble_availability/presentation/bloc/events/ensemble_availability_events.dart';
import 'package:app/features/ensemble/ensemble_availability/presentation/bloc/states/ensemble_availability_states.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/get_all_availabilities_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/validation/get_organized_day_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/validation/get_organized_availabilities_after_verification_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/period/open_period_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/period/close_period_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/day/update_availability_day_usecase.dart';

/// Bloc para gerenciar estado da feature de disponibilidade do conjunto
///
/// Gerencia usecases de validação, consulta e manipulação de disponibilidades
class EnsembleAvailabilityBloc
    extends Bloc<EnsembleAvailabilityEvent, EnsembleAvailabilityState> {
  final GetAllEnsembleAvailabilitiesUseCase getAllAvailabilitiesUseCase;
  final GetOrganizedEnsembleDayAfterVerificationUseCase getOrganizedDayAfterVerificationUseCase;
  final GetOrganizedEnsembleAvailabilitesAfterVerificationUseCase getOrganizedAvailabilitiesAfterVerificationUseCase;
  final OpenEnsemblePeriodUseCase openPeriodUseCase;
  final CloseEnsemblePeriodUseCase closePeriodUseCase;
  final UpdateEnsembleAvailabilityDayUseCase updateAvailabilityDayUseCase;

  EnsembleAvailabilityBloc({
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
    on<ResetEnsembleAvailabilityEvent>(_onResetAvailabilityEvent);
  }

  // ==================== INITIAL ====================

  void _onAvailabilityInitialEvent(
    AvailabilityInitialEvent event,
    Emitter<EnsembleAvailabilityState> emit,
  ) {
    emit(AvailabilityInitial());
  }

  // ==================== GET ALL AVAILABILITIES ====================

  Future<void> _onGetAllAvailabilitiesEvent(
    GetAllAvailabilitiesEvent event,
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(GetAllAvailabilitiesLoading());

    final result = await getAllAvailabilitiesUseCase(
      event.ensembleId,
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
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(GetOrganizedDayAfterVerificationLoading());

    final result = await getOrganizedDayAfterVerificationUseCase(
      event.ensembleId,
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
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(GetOrganizedAvailabilitiesAfterVerificationLoading());

    final result = await getOrganizedAvailabilitiesAfterVerificationUseCase(
      event.ensembleId,
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
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(OpenPeriodLoading());

    final result = await openPeriodUseCase(
      event.ensembleId,
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
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(ClosePeriodLoading());

    final result = await closePeriodUseCase(
      event.ensembleId,
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
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(ToggleAvailabilityStatusLoading());

    if (event.ensembleId.isEmpty) {
      emit(ToggleAvailabilityStatusFailure(error: 'ID do conjunto é obrigatório'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(event.ensembleId, event.dayEntity);

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
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(AddTimeSlotLoading());

    if (event.ensembleId.isEmpty) {
      emit(AddTimeSlotFailure(error: 'ID do conjunto é obrigatório'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(event.ensembleId, event.dayEntity);

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
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(UpdateTimeSlotLoading());

    if (event.ensembleId.isEmpty) {
      emit(UpdateTimeSlotFailure(error: 'ID do conjunto é obrigatório'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(event.ensembleId, event.dayEntity);

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
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(DeleteTimeSlotLoading());

    if (event.ensembleId.isEmpty) {
      emit(DeleteTimeSlotFailure(error: 'ID do conjunto é obrigatório'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(event.ensembleId, event.dayEntity);

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
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(UpdateAddressAndRadiusLoading());

    if (event.ensembleId.isEmpty) {
      emit(UpdateAddressAndRadiusFailure(error: 'ID do conjunto é obrigatório'));
      emit(AvailabilityInitial());
      return;
    }

    final result = await updateAvailabilityDayUseCase(event.ensembleId, event.dayEntity);

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
    ResetEnsembleAvailabilityEvent event,
    Emitter<EnsembleAvailabilityState> emit,
  ) async {
    emit(AvailabilityInitial());
  }
}
