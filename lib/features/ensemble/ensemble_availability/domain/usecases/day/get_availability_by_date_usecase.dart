import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/repositories/ensemble_availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Use Case para obter disponibilidade de um dia específico
///
/// Retorna a disponibilidade de um dia específico para um conjunto.
/// Se o dia não tiver disponibilidade, retorna null.
class GetEnsembleAvailabilityByDateUseCase {
  final IEnsembleAvailabilityRepository repository;

  GetEnsembleAvailabilityByDateUseCase({required this.repository});

  Future<Either<Failure, AvailabilityDayEntity?>> call(
    String ensembleId,
    DateTime date, {
    bool forceRemote = false,
  }) async {
    try {
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ID do conjunto é obrigatório'));
      }

      // Buscar todas as disponibilidades
      final result = await repository.getAvailabilities(
        ensembleId: ensembleId,
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
