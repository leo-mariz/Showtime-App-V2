import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Use Case para criar disponibilidade
class CreateAvailabilityUseCase {
  final IAvailabilityRepository repository;
  
  CreateAvailabilityUseCase({required this.repository});
  
  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    CreateAvailabilityDto dto,
  ) {
    if (artistId.isEmpty) {
      return Future.value(Left(ValidationFailure('ID do artista é obrigatório')));
    }
    
    // Validações básicas
    if (dto.day.addresses.isEmpty) {
      return Future.value(Left(ValidationFailure('Pelo menos um endereço é obrigatório')));
    }
    
    for (final address in dto.day.addresses) {
      if (address.slots.isEmpty) {
        return Future.value(Left(ValidationFailure('Pelo menos um slot é obrigatório')));
      }
    }
    
    return repository.createAvailability(
      artistId: artistId,
      day: dto.day,
    );
  }
}
