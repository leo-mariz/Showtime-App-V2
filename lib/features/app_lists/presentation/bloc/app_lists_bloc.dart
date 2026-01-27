import 'package:app/features/app_lists/domain/usecases/get_event_types_usecase.dart';
import 'package:app/features/app_lists/domain/usecases/get_specialties_usecase.dart';
import 'package:app/features/app_lists/domain/usecases/get_support_subjects_usecase.dart';
import 'package:app/features/app_lists/domain/usecases/get_talents_usecase.dart';
import 'package:app/features/app_lists/presentation/bloc/events/app_lists_events.dart';
import 'package:app/features/app_lists/presentation/bloc/states/app_lists_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppListsBloc extends Bloc<AppListsEvent, AppListsState> {
  final GetSpecialtiesUseCase getSpecialtiesUseCase;
  final GetTalentsUseCase getTalentsUseCase;
  final GetEventTypesUseCase getEventTypesUseCase;
  final GetSupportSubjectsUseCase getSupportSubjectsUseCase;

  AppListsBloc({
    required this.getSpecialtiesUseCase,
    required this.getTalentsUseCase,
    required this.getEventTypesUseCase,
    required this.getSupportSubjectsUseCase,
  }) : super(AppListsInitial()) {
    on<GetSpecialtiesEvent>(_onGetSpecialtiesEvent);
    on<GetTalentsEvent>(_onGetTalentsEvent);
    on<GetEventTypesEvent>(_onGetEventTypesEvent);
    on<GetSupportSubjectsEvent>(_onGetSupportSubjectsEvent);
    on<ResetAppListsEvent>(_onResetAppListsEvent);
  }

  // ==================== GET SPECIALTIES ====================

  Future<void> _onGetSpecialtiesEvent(
    GetSpecialtiesEvent event,
    Emitter<AppListsState> emit,
  ) async {
    emit(GetSpecialtiesLoading());

    final result = await getSpecialtiesUseCase.call();

    result.fold(
      (failure) {
        emit(GetSpecialtiesFailure(error: failure.message));
        emit(AppListsInitial());
      },
      (specialties) {
        emit(GetSpecialtiesSuccess(specialties: specialties));
        emit(AppListsInitial());
      },
    );
  }

  // ==================== GET TALENTS ====================

  Future<void> _onGetTalentsEvent(
    GetTalentsEvent event,
    Emitter<AppListsState> emit,
  ) async {
    emit(GetTalentsLoading());

    final result = await getTalentsUseCase.call();

    result.fold(
      (failure) {
        emit(GetTalentsFailure(error: failure.message));
        emit(AppListsInitial());
      },
      (talents) {
        emit(GetTalentsSuccess(talents: talents));
        emit(AppListsInitial());
      },
    );
  }

  // ==================== GET EVENT TYPES ====================

  Future<void> _onGetEventTypesEvent(
    GetEventTypesEvent event,
    Emitter<AppListsState> emit,
  ) async {
    emit(GetEventTypesLoading());

    final result = await getEventTypesUseCase.call();

    result.fold(
      (failure) {
        emit(GetEventTypesFailure(error: failure.message));
        emit(AppListsInitial());
      },
      (eventTypes) {
        emit(GetEventTypesSuccess(eventTypes: eventTypes));
        emit(AppListsInitial());
      },
    );
  }

  // ==================== GET SUPPORT SUBJECTS ====================

  Future<void> _onGetSupportSubjectsEvent(
    GetSupportSubjectsEvent event,
    Emitter<AppListsState> emit,
  ) async {
    emit(GetSupportSubjectsLoading());

    final result = await getSupportSubjectsUseCase.call();

    result.fold(
      (failure) {
        emit(GetSupportSubjectsFailure(error: failure.message));
        emit(AppListsInitial());
      },
      (supportSubjects) {
        emit(GetSupportSubjectsSuccess(supportSubjects: supportSubjects));
        emit(AppListsInitial());
      },
    );
  }

  // ==================== RESET ====================

  Future<void> _onResetAppListsEvent(
    ResetAppListsEvent event,
    Emitter<AppListsState> emit,
  ) async {
    emit(AppListsInitial());
  }
}

