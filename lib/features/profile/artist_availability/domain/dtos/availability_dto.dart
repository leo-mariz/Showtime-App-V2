import 'package:app/core/domain/artist/availability/availability_day_entity.dart';

/// DTO para buscar disponibilidades
class GetAvailabilityDto {
  final bool forceRemote;
  
  const GetAvailabilityDto({
    this.forceRemote = false,
  });
}

/// DTO para criar disponibilidade
class CreateAvailabilityDto {
  final AvailabilityDayEntity day;
  
  const CreateAvailabilityDto({
    required this.day,
  });
}

/// DTO para atualizar disponibilidade
class UpdateAvailabilityDto {
  final AvailabilityDayEntity day;
  
  const UpdateAvailabilityDto({
    required this.day,
  });
}

/// DTO para deletar disponibilidade
class DeleteAvailabilityDto {
  final String dayId;
  
  const DeleteAvailabilityDto({
    required this.dayId,
  });
}
