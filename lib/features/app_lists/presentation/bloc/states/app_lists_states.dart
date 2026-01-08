import 'package:app/features/app_lists/domain/entities/app_list_item_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AppListsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AppListsInitial extends AppListsState {}

// ==================== GET SPECIALTIES STATES ====================

class GetSpecialtiesLoading extends AppListsState {}

class GetSpecialtiesSuccess extends AppListsState {
  final List<AppListItemEntity> specialties;

  GetSpecialtiesSuccess({
    required this.specialties,
  });

  @override
  List<Object?> get props => [specialties];
}

class GetSpecialtiesFailure extends AppListsState {
  final String error;

  GetSpecialtiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET TALENTS STATES ====================

class GetTalentsLoading extends AppListsState {}

class GetTalentsSuccess extends AppListsState {
  final List<AppListItemEntity> talents;

  GetTalentsSuccess({
    required this.talents,
  });

  @override
  List<Object?> get props => [talents];
}

class GetTalentsFailure extends AppListsState {
  final String error;

  GetTalentsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET EVENT TYPES STATES ====================

class GetEventTypesLoading extends AppListsState {}

class GetEventTypesSuccess extends AppListsState {
  final List<AppListItemEntity> eventTypes;

  GetEventTypesSuccess({
    required this.eventTypes,
  });

  @override
  List<Object?> get props => [eventTypes];
}

class GetEventTypesFailure extends AppListsState {
  final String error;

  GetEventTypesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET SUPPORT SUBJECTS STATES ====================

class GetSupportSubjectsLoading extends AppListsState {}

class GetSupportSubjectsSuccess extends AppListsState {
  final List<AppListItemEntity> supportSubjects;

  GetSupportSubjectsSuccess({
    required this.supportSubjects,
  });

  @override
  List<Object?> get props => [supportSubjects];
}

class GetSupportSubjectsFailure extends AppListsState {
  final String error;

  GetSupportSubjectsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

