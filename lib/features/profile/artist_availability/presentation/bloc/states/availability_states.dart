import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AvailabilityState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AvailabilityInitial extends AvailabilityState {}

// ==================== GET AVAILABILITIES STATES ====================

class GetAvailabilitiesLoading extends AvailabilityState {}

class GetAvailabilitiesSuccess extends AvailabilityState {
  final List<AvailabilityEntity> availabilities;

  GetAvailabilitiesSuccess({required this.availabilities});

  @override
  List<Object?> get props => [availabilities];
}

class GetAvailabilitiesFailure extends AvailabilityState {
  final String error;

  GetAvailabilitiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== ADD AVAILABILITY STATES ====================

class AddAvailabilityLoading extends AvailabilityState {}

class AddAvailabilitySuccess extends AvailabilityState {}

class AddAvailabilityFailure extends AvailabilityState {
  final String error;

  AddAvailabilityFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE AVAILABILITY STATES ====================

class UpdateAvailabilityLoading extends AvailabilityState {}

class UpdateAvailabilitySuccess extends AvailabilityState {}

class UpdateAvailabilityFailure extends AvailabilityState {
  final String error;

  UpdateAvailabilityFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== DELETE AVAILABILITY STATES ====================

class DeleteAvailabilityLoading extends AvailabilityState {}

class DeleteAvailabilitySuccess extends AvailabilityState {}

class DeleteAvailabilityFailure extends AvailabilityState {
  final String error;

  DeleteAvailabilityFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CLOSE AVAILABILITY STATES ====================

class CloseAvailabilityLoading extends AvailabilityState {}

class CloseAvailabilitySuccess extends AvailabilityState {}

class CloseAvailabilityFailure extends AvailabilityState {
  final String error;

  CloseAvailabilityFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CHECK AVAILABILITY OVERLAP STATES ====================

class CheckAvailabilityOverlapLoading extends AvailabilityState {}

class CheckAvailabilityOverlapSuccess extends AvailabilityState {
  final bool hasOverlap;
  final String priorityReason;

  CheckAvailabilityOverlapSuccess({
    required this.hasOverlap,
    required this.priorityReason,
  });

  @override
  List<Object?> get props => [hasOverlap, priorityReason];
}

class CheckAvailabilityOverlapWarning extends AvailabilityState {
  final String priorityReason;
  final String overlappingAddressTitle;

  CheckAvailabilityOverlapWarning({
    required this.priorityReason,
    required this.overlappingAddressTitle,
  });

  @override
  List<Object?> get props => [priorityReason, overlappingAddressTitle];
}

class CheckAvailabilityOverlapFailure extends AvailabilityState {
  final String error;

  CheckAvailabilityOverlapFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

