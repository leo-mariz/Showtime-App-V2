import 'package:equatable/equatable.dart';
import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/features/availability/domain/dtos/check_overlap_on_day_dto.dart';
import 'package:app/features/availability/domain/dtos/check_overlaps_dto.dart';
import 'package:app/features/availability/domain/dtos/open_period_dto.dart';

abstract class EnsembleAvailabilityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AvailabilityInitialEvent extends EnsembleAvailabilityEvent {}

// ==================== GET ALL AVAILABILITIES EVENTS ====================

/// Evento para buscar todas as disponibilidades de um conjunto
class GetAllAvailabilitiesEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final bool forceRemote;

  GetAllAvailabilitiesEvent({
    required this.ensembleId,
    this.forceRemote = false,
  });

  @override
  List<Object?> get props => [ensembleId, forceRemote];
}

// ==================== TOGGLE AVAILABILITY STATUS EVENTS ====================

/// Evento para ativar/desativar disponibilidade de um dia
class ToggleAvailabilityStatusEvent extends EnsembleAvailabilityEvent {
  final DateTime date;
  final bool isActive;

  ToggleAvailabilityStatusEvent({
    required this.date,
    required this.isActive,
  });

  @override
  List<Object?> get props => [date, isActive];
}

// ==================== CHECK OVERLAP ON DAY EVENTS ====================

/// Evento para verificar overlaps em um único dia
class GetOrganizedDayAfterVerificationEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final DateTime date;
  final CheckOverlapOnDayDto dto;

  GetOrganizedDayAfterVerificationEvent({
    required this.ensembleId,
    required this.date,
    required this.dto,
  });

  @override
  List<Object?> get props => [ensembleId, date, dto];
}

// ==================== CHECK OVERLAPS ON PERIOD EVENTS ====================

/// Evento para verificar overlaps em um período (múltiplos dias)
class GetOrganizedAvailabilitiesAfterVerificationEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final CheckOverlapsDto dto;
  final bool isClose;

  GetOrganizedAvailabilitiesAfterVerificationEvent({
    required this.ensembleId,
    required this.dto,
    required this.isClose,
  });

  @override
  List<Object?> get props => [ensembleId, dto, isClose];
}

// ==================== OPEN PERIOD EVENTS ====================

/// Evento para abrir um período de disponibilidade
class OpenPeriodEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final OpenPeriodDto dto;

  OpenPeriodEvent({
    required this.ensembleId,
    required this.dto,
  });

  @override
  List<Object?> get props => [ensembleId, dto];
}

// ==================== CLOSE PERIOD EVENTS ====================

/// Evento para fechar um período de disponibilidade
class ClosePeriodEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final OpenPeriodDto dto;

  ClosePeriodEvent({
    required this.ensembleId,
    required this.dto,
  });

  @override
  List<Object?> get props => [ensembleId, dto];
}

// ==================== UPDATE AVAILABILITY DAY EVENTS ====================

/// Evento para atualizar disponibilidade de um dia (toggle isActive)
class ToggleAvailabilityDayEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final AvailabilityDayEntity dayEntity;

  ToggleAvailabilityDayEvent({
    required this.ensembleId,
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [ensembleId, dayEntity];
}

/// Evento para adicionar um slot a um dia
class AddTimeSlotEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final AvailabilityDayEntity dayEntity;

  AddTimeSlotEvent({
    required this.ensembleId,
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [ensembleId, dayEntity];
}

/// Evento para atualizar um slot existente
class UpdateTimeSlotEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final AvailabilityDayEntity dayEntity;

  UpdateTimeSlotEvent({
    required this.ensembleId,
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [ensembleId, dayEntity];
}

/// Evento para deletar um slot
class DeleteTimeSlotEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final AvailabilityDayEntity dayEntity;

  DeleteTimeSlotEvent({
    required this.ensembleId,
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [ensembleId, dayEntity];
}

/// Evento para atualizar endereço e raio de atuação
class UpdateAddressAndRadiusEvent extends EnsembleAvailabilityEvent {
  final String ensembleId;
  final AvailabilityDayEntity dayEntity;

  UpdateAddressAndRadiusEvent({
    required this.ensembleId,
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [ensembleId, dayEntity];
}


// ==================== RESET EVENT ====================

class ResetEnsembleAvailabilityEvent extends EnsembleAvailabilityEvent {}