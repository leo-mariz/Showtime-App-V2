import 'package:app/core/domain/artist/availability/availability_day_entity.dart';

/// Estados base para Availability
abstract class AvailabilityState {}

/// Estado inicial
class AvailabilityInitialState extends AvailabilityState {}

/// Estado de loading
class AvailabilityLoadingState extends AvailabilityState {
  final String? message;
  
  AvailabilityLoadingState({this.message});
}

/// Estado de disponibilidades carregadas
class AvailabilityLoadedState extends AvailabilityState {
  final List<AvailabilityDayEntity> days;
  
  AvailabilityLoadedState({required this.days});
}

/// Estado de disponibilidade criada
class AvailabilityCreatedState extends AvailabilityState {
  final AvailabilityDayEntity day;
  final String message;
  
  AvailabilityCreatedState({
    required this.day,
    this.message = 'Disponibilidade criada com sucesso',
  });
}

/// Estado de disponibilidade atualizada
class AvailabilityUpdatedState extends AvailabilityState {
  final AvailabilityDayEntity day;
  final String message;
  
  AvailabilityUpdatedState({
    required this.day,
    this.message = 'Disponibilidade atualizada com sucesso',
  });
}

/// Estado de disponibilidade deletada
class AvailabilityDeletedState extends AvailabilityState {
  final String message;
  
  AvailabilityDeletedState({
    this.message = 'Disponibilidade removida com sucesso',
  });
}

/// Estado de erro
class AvailabilityErrorState extends AvailabilityState {
  final String message;
  
  AvailabilityErrorState({required this.message});
}
