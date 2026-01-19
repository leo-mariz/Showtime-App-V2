import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Use Case para deletar disponibilidade
class DeleteAvailabilityUseCase {
  final IAvailabilityRepository repository;
  
  DeleteAvailabilityUseCase({required this.repository});
  
  Future<Either<Failure, void>> call(
    String artistId,
    DeleteAvailabilityDto dto,
  ) {
    if (artistId.isEmpty) {
      return Future.value(Left(ValidationFailure('ID do artista é obrigatório')));
    }
    
    if (dto.dayId.isEmpty) {
      return Future.value(Left(ValidationFailure('ID do dia é obrigatório')));
    }
    
    return repository.deleteAvailability(
      artistId: artistId,
      dayId: dto.dayId,
    );
  }
}
