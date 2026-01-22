import 'package:app/core/domain/artist/availability/availability_day_entity.dart';

/// Estados base para Availability
abstract class AvailabilityState {}

// ════════════════════════════════════════════════════════════════════════════
// Estados Iniciais e de Controle
// ════════════════════════════════════════════════════════════════════════════

class AvailabilityInitialState extends AvailabilityState {}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Consulta (GetAll)
// ════════════════════════════════════════════════════════════════════════════

/// Loading ao buscar todas as disponibilidades
class GetAllAvailabilitiesLoadingState extends AvailabilityState {
  final String? message;
  GetAllAvailabilitiesLoadingState({this.message});
}

/// Sucesso ao buscar todas as disponibilidades
/// ÚNICO estado que retorna dados para renderizar na UI
class AllAvailabilitiesLoadedState extends AvailabilityState {
  final List<AvailabilityDayEntity> days;
  AllAvailabilitiesLoadedState({required this.days});
}

/// Erro ao buscar todas as disponibilidades
class GetAllAvailabilitiesErrorState extends AvailabilityState {
  final String message;
  GetAllAvailabilitiesErrorState({required this.message});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Consulta (GetByDate)
// ════════════════════════════════════════════════════════════════════════════

/// Loading ao buscar disponibilidade de um dia
class GetAvailabilityByDateLoadingState extends AvailabilityState {}

/// Sucesso ao buscar disponibilidade de um dia
class AvailabilityDayLoadedState extends AvailabilityState {
  final AvailabilityDayEntity? day;
  AvailabilityDayLoadedState({this.day});
}

/// Erro ao buscar disponibilidade de um dia
class GetAvailabilityByDateErrorState extends AvailabilityState {
  final String message;
  GetAvailabilityByDateErrorState({required this.message});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Toggle Status
// ════════════════════════════════════════════════════════════════════════════

class ToggleAvailabilityStatusLoadingState extends AvailabilityState {}

class ToggleAvailabilityStatusSuccessState extends AvailabilityState {
  final String message;
  ToggleAvailabilityStatusSuccessState({required this.message});
}

class ToggleAvailabilityStatusErrorState extends AvailabilityState {
  final String message;
  ToggleAvailabilityStatusErrorState({required this.message});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Update Address Radius
// ════════════════════════════════════════════════════════════════════════════

class UpdateAddressRadiusLoadingState extends AvailabilityState {}

class UpdateAddressRadiusSuccessState extends AvailabilityState {
  final String message;
  UpdateAddressRadiusSuccessState({required this.message});
}

class UpdateAddressRadiusErrorState extends AvailabilityState {
  final String message;
  UpdateAddressRadiusErrorState({required this.message});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Add Time Slot
// ════════════════════════════════════════════════════════════════════════════

class AddTimeSlotLoadingState extends AvailabilityState {}

class AddTimeSlotSuccessState extends AvailabilityState {
  final String message;
  AddTimeSlotSuccessState({required this.message});
}

class AddTimeSlotErrorState extends AvailabilityState {
  final String message;
  AddTimeSlotErrorState({required this.message});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Update Time Slot
// ════════════════════════════════════════════════════════════════════════════

class UpdateTimeSlotLoadingState extends AvailabilityState {}

class UpdateTimeSlotSuccessState extends AvailabilityState {
  final String message;
  UpdateTimeSlotSuccessState({required this.message});
}

class UpdateTimeSlotErrorState extends AvailabilityState {
  final String message;
  UpdateTimeSlotErrorState({required this.message});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Delete Time Slot
// ════════════════════════════════════════════════════════════════════════════

class DeleteTimeSlotLoadingState extends AvailabilityState {}

class DeleteTimeSlotSuccessState extends AvailabilityState {
  final String message;
  DeleteTimeSlotSuccessState({required this.message});
}

class DeleteTimeSlotErrorState extends AvailabilityState {
  final String message;
  DeleteTimeSlotErrorState({required this.message});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Open Period
// ════════════════════════════════════════════════════════════════════════════

class OpenPeriodLoadingState extends AvailabilityState {
  final String? message;
  OpenPeriodLoadingState({this.message});
}

class OpenPeriodSuccessState extends AvailabilityState {
  final String message;
  OpenPeriodSuccessState({required this.message});
}

class OpenPeriodErrorState extends AvailabilityState {
  final String message;
  OpenPeriodErrorState({required this.message});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Close Period
// ════════════════════════════════════════════════════════════════════════════

class ClosePeriodLoadingState extends AvailabilityState {
  final String? message;
  ClosePeriodLoadingState({this.message});
}

class ClosePeriodSuccessState extends AvailabilityState {
  final String message;
  ClosePeriodSuccessState({required this.message});
}

class ClosePeriodErrorState extends AvailabilityState {
  final String message;
  ClosePeriodErrorState({required this.message});
}
