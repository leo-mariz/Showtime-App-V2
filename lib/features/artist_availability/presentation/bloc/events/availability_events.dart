import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

abstract class AvailabilityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET AVAILABILITIES EVENTS ====================

class GetAvailabilitiesEvent extends AvailabilityEvent {}

// ==================== ADD AVAILABILITY EVENTS ====================

class AddAvailabilityEvent extends AvailabilityEvent {
  final AvailabilityEntity availability;

  AddAvailabilityEvent({
    required this.availability,
  });

  @override
  List<Object?> get props => [availability];
}

// ==================== UPDATE AVAILABILITY EVENTS ====================

class UpdateAvailabilityEvent extends AvailabilityEvent {
  final AvailabilityEntity availability;

  UpdateAvailabilityEvent({
    required this.availability,
  });

  @override
  List<Object?> get props => [availability];
}

// ==================== DELETE AVAILABILITY EVENTS ====================

class DeleteAvailabilityEvent extends AvailabilityEvent {
  final String availabilityId;

  DeleteAvailabilityEvent({
    required this.availabilityId,
  });

  @override
  List<Object?> get props => [availabilityId];
}

// ==================== CLOSE AVAILABILITY EVENTS ====================

class CloseAvailabilityEvent extends AvailabilityEvent {
  final Appointment closeAppointment;

  CloseAvailabilityEvent({
    required this.closeAppointment,
  });

  @override
  List<Object?> get props => [closeAppointment];
}

// ==================== CHECK AVAILABILITY OVERLAP EVENTS ====================

class CheckAvailabilityOverlapEvent extends AvailabilityEvent {
  final AvailabilityEntity availability;
  final String? excludeAvailabilityId; // ID da disponibilidade a ser excluída da verificação (para updates)

  CheckAvailabilityOverlapEvent({
    required this.availability,
    this.excludeAvailabilityId,
  });

  @override
  List<Object?> get props => [availability, excludeAvailabilityId];
}

