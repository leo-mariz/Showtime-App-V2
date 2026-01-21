import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Use Case para obter disponibilidade de um dia específico
/// 
/// Retorna a disponibilidade de um dia específico para um artista.
/// Se o dia não tiver disponibilidade, retorna null.
class GetAvailabilityByDateUseCase {
  final IAvailabilityRepository repository;

  GetAvailabilityByDateUseCase({required this.repository});

  Future<Either<Failure, AvailabilityDayEntity?>> call(
    String artistId,
    GetAvailabilityByDateDto dto,
  ) async {
    if (artistId.isEmpty) {
      return Left(ValidationFailure('ID do artista é obrigatório'));
    }

    // Buscar todas as disponibilidades
    final result = await repository.getAvailabilities(
      artistId: artistId,
      forceRemote: dto.forceRemote,
    );

    return result.fold(
      (failure) => Left(failure),
      (allDays) {
        // Normalizar a data para comparação (sem hora)
        final targetDate = DateTime(dto.date.year, dto.date.month, dto.date.day);
        
        // Buscar o dia específico
        try {
          final dayEntity = allDays.firstWhere(
            (day) {
              final dayDate = DateTime(
                day.date.year,
                day.date.month,
                day.date.day,
              );
              return dayDate.isAtSameMomentAs(targetDate);
            },
          );
          return Right(dayEntity);
        } catch (e) {
          // Dia não encontrado
          return const Right(null);
        }
      },
    );
  }
}
