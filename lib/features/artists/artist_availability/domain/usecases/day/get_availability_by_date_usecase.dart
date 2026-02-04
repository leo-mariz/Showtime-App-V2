import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artist_availability/domain/repositories/availability_repository.dart';
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
    DateTime date,
    {bool forceRemote = false}
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // Buscar todas as disponibilidades
      final result = await repository.getAvailabilities(
        artistId: artistId,
        forceRemote: forceRemote,
      );

      return result.fold(
        (failure) => Left(failure),
        (allDays) {
          // Normalizar a data para comparação (sem hora)
          final targetDate = DateTime(date.year, date.month, date.day);
          
          // Buscar o dia específico
          final dayEntity = allDays.cast<AvailabilityDayEntity?>().firstWhere(
            (day) {
              if (day == null) return false;
              final dayDate = DateTime(
                day.date.year,
                day.date.month,
                day.date.day,
              );
              return dayDate.isAtSameMomentAs(targetDate);
            },
            orElse: () => null,
          );
          
          return Right(dayEntity);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
