import 'package:equatable/equatable.dart';
import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/features/availability/domain/entities/check_overlap_on_day_result.dart';
import 'package:app/features/availability/domain/entities/organized_availabilities_after_verification_result_entity.dart';

abstract class EnsembleAvailabilityState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AvailabilityInitial extends EnsembleAvailabilityState {}

// ==================== GET ALL AVAILABILITIES STATES ====================

/// Estado de carregamento para buscar todas as disponibilidades
class GetAllAvailabilitiesLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para buscar todas as disponibilidades
class GetAllAvailabilitiesSuccess extends EnsembleAvailabilityState {
  final List<AvailabilityDayEntity> availabilities;

  GetAllAvailabilitiesSuccess({required this.availabilities});

  @override
  List<Object?> get props => [availabilities];
}

/// Estado de falha para buscar todas as disponibilidades
class GetAllAvailabilitiesFailure extends EnsembleAvailabilityState {
  final String error;

  GetAllAvailabilitiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== TOGGLE AVAILABILITY STATUS STATES ====================

/// Estado de carregamento para alternar status de disponibilidade
class ToggleAvailabilityStatusLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para alternar status de disponibilidade
class ToggleAvailabilityStatusSuccess extends EnsembleAvailabilityState {
  final AvailabilityDayEntity availability;

  ToggleAvailabilityStatusSuccess({required this.availability});

  @override
  List<Object?> get props => [availability];
}

/// Estado de falha para alternar status de disponibilidade
class ToggleAvailabilityStatusFailure extends EnsembleAvailabilityState {
  final String error;

  ToggleAvailabilityStatusFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CHECK OVERLAP ON DAY STATES ====================

/// Estado de carregamento para verificação de overlaps em um dia
class GetOrganizedDayAfterVerificationLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para verificação de overlaps em um dia
class GetOrganizedDayAfterVerificationSuccess extends EnsembleAvailabilityState {
  final OrganizedDayAfterVerificationResult result;

  GetOrganizedDayAfterVerificationSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Estado de falha para verificação de overlaps em um dia
class GetOrganizedDayAfterVerificationFailure extends EnsembleAvailabilityState {
  final String error;

  GetOrganizedDayAfterVerificationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CHECK OVERLAPS ON PERIOD STATES ====================

/// Estado de carregamento para verificação de overlaps em um período
class GetOrganizedAvailabilitiesAfterVerificationLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para verificação de overlaps em um período
class OpenOrganizedAvailabilitiesSuccess extends EnsembleAvailabilityState {
  final OrganizedAvailabilitiesAfterVerificationResult result;

  OpenOrganizedAvailabilitiesSuccess({required this.result });

  @override
  List<Object?> get props => [result];
}

class CloseOrganizedAvailabilitiesSuccess extends EnsembleAvailabilityState {
  final OrganizedAvailabilitiesAfterVerificationResult result;

  CloseOrganizedAvailabilitiesSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Estado de falha para verificação de overlaps em um período
class GetOrganizedAvailabilitiesAfterVerificationFailure extends EnsembleAvailabilityState {
  final String error;

  GetOrganizedAvailabilitiesAfterVerificationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== OPEN PERIOD STATES ====================

/// Estado de carregamento para abrir período
class OpenPeriodLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para abrir período
class OpenPeriodSuccess extends EnsembleAvailabilityState {
  final List<AvailabilityDayEntity> days;

  OpenPeriodSuccess({required this.days});

  @override
  List<Object?> get props => [days];
}

/// Estado de falha para abrir período
class OpenPeriodFailure extends EnsembleAvailabilityState {
  final String error;

  OpenPeriodFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CLOSE PERIOD STATES ====================

/// Estado de carregamento para fechar período
class ClosePeriodLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para fechar período
class ClosePeriodSuccess extends EnsembleAvailabilityState {
  final List<AvailabilityDayEntity> days;

  ClosePeriodSuccess({required this.days});

  @override
  List<Object?> get props => [days];
}

/// Estado de falha para fechar período
class ClosePeriodFailure extends EnsembleAvailabilityState {
  final String error;

  ClosePeriodFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== DELETE TIME SLOT STATES ====================

/// Estado de carregamento para deletar slot
class DeleteTimeSlotLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para deletar slot
class DeleteTimeSlotSuccess extends EnsembleAvailabilityState {
  final AvailabilityDayEntity availability;

  DeleteTimeSlotSuccess({required this.availability});

  @override
  List<Object?> get props => [availability];
}

/// Estado de falha para deletar slot
class DeleteTimeSlotFailure extends EnsembleAvailabilityState {
  final String error;

  DeleteTimeSlotFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE TIME SLOT STATES ====================

/// Estado de carregamento para atualizar slot
class UpdateTimeSlotLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para atualizar slot
class UpdateTimeSlotSuccess extends EnsembleAvailabilityState {
  final AvailabilityDayEntity availability;

  UpdateTimeSlotSuccess({required this.availability});

  @override
  List<Object?> get props => [availability];
}

/// Estado de falha para atualizar slot
class UpdateTimeSlotFailure extends EnsembleAvailabilityState {
  final String error;

  UpdateTimeSlotFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ADDRESS AND RADIUS STATES ====================

/// Estado de carregamento para atualizar endereço e raio
class UpdateAddressAndRadiusLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para atualizar endereço e raio
class UpdateAddressAndRadiusSuccess extends EnsembleAvailabilityState {
  final AvailabilityDayEntity availability;

  UpdateAddressAndRadiusSuccess({required this.availability});

  @override
  List<Object?> get props => [availability];
}

/// Estado de falha para atualizar endereço e raio
class UpdateAddressAndRadiusFailure extends EnsembleAvailabilityState {
  final String error;

  UpdateAddressAndRadiusFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== ADD TIME SLOT STATES ====================

/// Estado de carregamento para adicionar slot
class AddTimeSlotLoading extends EnsembleAvailabilityState {}

/// Estado de sucesso para adicionar slot
class AddTimeSlotSuccess extends EnsembleAvailabilityState {
  final AvailabilityDayEntity availability;

  AddTimeSlotSuccess({required this.availability});

  @override
  List<Object?> get props => [availability];
}

/// Estado de falha para adicionar slot
class AddTimeSlotFailure extends EnsembleAvailabilityState {
  final String error;

  AddTimeSlotFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
