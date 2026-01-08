import 'package:equatable/equatable.dart';

abstract class AppListsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET SPECIALTIES EVENTS ====================

class GetSpecialtiesEvent extends AppListsEvent {}

// ==================== GET TALENTS EVENTS ====================

class GetTalentsEvent extends AppListsEvent {}

// ==================== GET EVENT TYPES EVENTS ====================

class GetEventTypesEvent extends AppListsEvent {}

// ==================== GET SUPPORT SUBJECTS EVENTS ====================

class GetSupportSubjectsEvent extends AppListsEvent {}

