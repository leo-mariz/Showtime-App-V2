import 'package:equatable/equatable.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/features/profile/artist_availability/domain/entities/check_overlap_on_day_result.dart';
import 'package:app/features/profile/artist_availability/domain/entities/organized_availabilities_after_verification_result_entity.dart.dart';

abstract class AvailabilityState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AvailabilityInitial extends AvailabilityState {}

// ==================== GET ALL AVAILABILITIES STATES ====================

/// Estado de carregamento para buscar todas as disponibilidades
class GetAllAvailabilitiesLoading extends AvailabilityState {}

/// Estado de sucesso para buscar todas as disponibilidades
class GetAllAvailabilitiesSuccess extends AvailabilityState {
  final List<AvailabilityDayEntity> availabilities;

  GetAllAvailabilitiesSuccess({required this.availabilities});

  @override
  List<Object?> get props => [availabilities];
}

/// Estado de falha para buscar todas as disponibilidades
class GetAllAvailabilitiesFailure extends AvailabilityState {
  final String error;

  GetAllAvailabilitiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== TOGGLE AVAILABILITY STATUS STATES ====================

/// Estado de carregamento para alternar status de disponibilidade
class ToggleAvailabilityStatusLoading extends AvailabilityState {}

/// Estado de sucesso para alternar status de disponibilidade
class ToggleAvailabilityStatusSuccess extends AvailabilityState {
  final AvailabilityDayEntity availability;

  ToggleAvailabilityStatusSuccess({required this.availability});

  @override
  List<Object?> get props => [availability];
}

/// Estado de falha para alternar status de disponibilidade
class ToggleAvailabilityStatusFailure extends AvailabilityState {
  final String error;

  ToggleAvailabilityStatusFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CHECK OVERLAP ON DAY STATES ====================

/// Estado de carregamento para verificação de overlaps em um dia
class GetOrganizedDayAfterVerificationLoading extends AvailabilityState {}

/// Estado de sucesso para verificação de overlaps em um dia
class GetOrganizedDayAfterVerificationSuccess extends AvailabilityState {
  final OrganizedDayAfterVerificationResult result;

  GetOrganizedDayAfterVerificationSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Estado de falha para verificação de overlaps em um dia
class GetOrganizedDayAfterVerificationFailure extends AvailabilityState {
  final String error;

  GetOrganizedDayAfterVerificationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CHECK OVERLAPS ON PERIOD STATES ====================

/// Estado de carregamento para verificação de overlaps em um período
class GetOrganizedAvailabilitiesAfterVerificationLoading extends AvailabilityState {}

/// Estado de sucesso para verificação de overlaps em um período
class OpenOrganizedAvailabilitiesSuccess extends AvailabilityState {
  final OrganizedAvailabilitiesAfterVerificationResult result;

  OpenOrganizedAvailabilitiesSuccess({required this.result });

  @override
  List<Object?> get props => [result];
}

class CloseOrganizedAvailabilitiesSuccess extends AvailabilityState {
  final OrganizedAvailabilitiesAfterVerificationResult result;

  CloseOrganizedAvailabilitiesSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Estado de falha para verificação de overlaps em um período
class GetOrganizedAvailabilitiesAfterVerificationFailure extends AvailabilityState {
  final String error;

  GetOrganizedAvailabilitiesAfterVerificationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== OPEN PERIOD STATES ====================

/// Estado de carregamento para abrir período
class OpenPeriodLoading extends AvailabilityState {}

/// Estado de sucesso para abrir período
class OpenPeriodSuccess extends AvailabilityState {
  final List<AvailabilityDayEntity> days;

  OpenPeriodSuccess({required this.days});

  @override
  List<Object?> get props => [days];
}

/// Estado de falha para abrir período
class OpenPeriodFailure extends AvailabilityState {
  final String error;

  OpenPeriodFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CLOSE PERIOD STATES ====================

/// Estado de carregamento para fechar período
class ClosePeriodLoading extends AvailabilityState {}

/// Estado de sucesso para fechar período
class ClosePeriodSuccess extends AvailabilityState {
  final List<AvailabilityDayEntity> days;

  ClosePeriodSuccess({required this.days});

  @override
  List<Object?> get props => [days];
}

/// Estado de falha para fechar período
class ClosePeriodFailure extends AvailabilityState {
  final String error;

  ClosePeriodFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
