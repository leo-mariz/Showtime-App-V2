import 'package:app/core/domain/artist/availability/availability_day_entity.dart';

/// Estados base para Availability
abstract class AvailabilityState {}

// ════════════════════════════════════════════════════════════════════════════
// Estados Gerais
// ════════════════════════════════════════════════════════════════════════════

/// Estado inicial
class AvailabilityInitialState extends AvailabilityState {}

/// Estado de loading
class AvailabilityLoadingState extends AvailabilityState {
  final String? message;

  AvailabilityLoadingState({this.message});
}

/// Estado de erro
class AvailabilityErrorState extends AvailabilityState {
  final String message;

  AvailabilityErrorState({required this.message});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Consulta
// ════════════════════════════════════════════════════════════════════════════

/// Estado de todas as disponibilidades carregadas
class AllAvailabilitiesLoadedState extends AvailabilityState {
  final List<AvailabilityDayEntity> days;

  AllAvailabilitiesLoadedState({required this.days});
}

/// Estado de disponibilidade de um dia carregada
class AvailabilityDayLoadedState extends AvailabilityState {
  final AvailabilityDayEntity? day; // null se dia não tem disponibilidade

  AvailabilityDayLoadedState({required this.day});
}

// ════════════════════════════════════════════════════════════════════════════
// Estados de Sucesso em Operações
// ════════════════════════════════════════════════════════════════════════════

/// Estado de disponibilidade do dia atualizada (toggle status, endereço, etc)
class AvailabilityDayUpdatedState extends AvailabilityState {
  final AvailabilityDayEntity day;
  final String message;

  AvailabilityDayUpdatedState({
    required this.day,
    this.message = 'Disponibilidade atualizada com sucesso',
  });
}

/// Estado de slot adicionado
class TimeSlotAddedState extends AvailabilityState {
  final AvailabilityDayEntity day;
  final String message;

  TimeSlotAddedState({
    required this.day,
    this.message = 'Horário adicionado com sucesso',
  });
}

/// Estado de slot atualizado
class TimeSlotUpdatedState extends AvailabilityState {
  final AvailabilityDayEntity day;
  final String message;

  TimeSlotUpdatedState({
    required this.day,
    this.message = 'Horário atualizado com sucesso',
  });
}

/// Estado de slot deletado
class TimeSlotDeletedState extends AvailabilityState {
  final AvailabilityDayEntity day;
  final String message;

  TimeSlotDeletedState({
    required this.day,
    this.message = 'Horário removido com sucesso',
  });
}
