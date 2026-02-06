import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:equatable/equatable.dart';

abstract class RequestAvailabilitiesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RequestAvailabilitiesInitial extends RequestAvailabilitiesState {}

class RequestAvailabilitiesLoading extends RequestAvailabilitiesState {}

class RequestAvailabilitiesSuccess extends RequestAvailabilitiesState {
  final List<AvailabilityDayEntity> availabilities;

  RequestAvailabilitiesSuccess({required this.availabilities});

  @override
  List<Object?> get props => [availabilities];
}

class RequestAvailabilitiesFailure extends RequestAvailabilitiesState {
  final String error;

  RequestAvailabilitiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
