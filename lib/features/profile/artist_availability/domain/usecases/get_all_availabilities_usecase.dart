import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Use Case para obter todas as disponibilidades de um artista
/// 
/// Retorna uma lista completa de todos os dias com disponibilidade.
/// Útil para exibir o calendário ou gerar relatórios.
class GetAllAvailabilitiesUseCase {
  final IAvailabilityRepository repository;

  GetAllAvailabilitiesUseCase({required this.repository});

  /// Busca todas as disponibilidades
  /// 
  /// [artistId]: ID do artista (obtido no BLoC)
  /// [forceRemote]: Se true, força busca remota ignorando cache
  /// 
  /// Retorna lista de dias com disponibilidade ordenada por data.
  Future<Either<Failure, List<AvailabilityDayEntity>>> call(
    String artistId,
    bool forceRemote,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // Buscar do repositório
      final result = await repository.getAvailabilities(
        artistId: artistId,
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
