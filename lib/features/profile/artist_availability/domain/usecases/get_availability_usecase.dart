import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Use Case para buscar disponibilidades
class GetAvailabilityUseCase {
  final IAvailabilityRepository repository;
  
  GetAvailabilityUseCase({required this.repository});
  
  Future<Either<Failure, List<AvailabilityDayEntity>>> call(
    String artistId,
    GetAvailabilityDto dto,
  ) {
    if (artistId.isEmpty) {
      return Future.value(Left(ValidationFailure('ID do artista é obrigatório')));
    }
    
    return repository.getAvailability(
      artistId: artistId,
      forceRemote: dto.forceRemote,
    );
  }
}
