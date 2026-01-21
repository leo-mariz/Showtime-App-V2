import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_availability_by_date_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para ativar/desativar disponibilidade de um dia
/// 
/// Permite alternar o status de ativo/inativo de toda a disponibilidade
/// de um dia específico sem deletar os dados.
class ToggleAvailabilityStatusUseCase {
  final IAvailabilityRepository repository;
  final GetAvailabilityByDateUseCase getByDate;

  ToggleAvailabilityStatusUseCase({
    required this.repository,
    required this.getByDate,
  });

  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    ToggleAvailabilityStatusDto dto,
  ) async {
    if (artistId.isEmpty) {
      return Left(ValidationFailure('ID do artista é obrigatório'));
    }

    // Buscar disponibilidade do dia
    final getDayResult = await getByDate(
      artistId,
      GetAvailabilityByDateDto(date: dto.date, forceRemote: true),
    );

    return getDayResult.fold(
      (failure) => Left(failure),
      (dayEntity) {
        if (dayEntity == null) {
          return Left(NotFoundFailure('Disponibilidade não encontrada para este dia'));
        }

        // Atualizar status
        final updatedDay = dayEntity.copyWith(
          isActive: dto.isActive,
        );

        // Atualizar no repositório
        return repository.updateAvailability(
          artistId: artistId,
          day: updatedDay,
        );
      },
    );
  }
}
