import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/repositories/ensemble_availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Use Case para obter todas as disponibilidades de um conjunto
///
/// Retorna uma lista completa de todos os dias com disponibilidade.
/// Útil para exibir o calendário ou gerar relatórios.
class GetAllEnsembleAvailabilitiesUseCase {
  final IEnsembleAvailabilityRepository repository;

  GetAllEnsembleAvailabilitiesUseCase({required this.repository});

  /// Busca todas as disponibilidades
  ///
  /// [ensembleId]: ID do conjunto (obtido no BLoC)
  /// [forceRemote]: Se true, força busca remota ignorando cache
  ///
  /// Retorna lista de dias com disponibilidade ordenada por data.
  Future<Either<Failure, List<AvailabilityDayEntity>>> call(
    String ensembleId,
    bool forceRemote,
  ) async {
    try {
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ID do conjunto é obrigatório'));
      }

      // Buscar do repositório
      final result = await repository.getAvailabilities(
        ensembleId: ensembleId,
        forceRemote: forceRemote,
      );

      // Ordenar por data (mais antigas primeiro)
      return result.fold(
        (failure) => Left(failure),
        (days) {
          final sortedDays = List<AvailabilityDayEntity>.from(days)
            ..sort((a, b) => a.date.compareTo(b.date));
          return Right(sortedDays);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
