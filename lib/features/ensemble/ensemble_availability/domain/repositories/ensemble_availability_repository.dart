import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:app/core/errors/failure.dart';

/// Repository para gerenciar disponibilidade do conjunto
///
/// Interface que define operações de disponibilidade
/// Implementação deve orquestrar remote e local datasources
abstract class IEnsembleAvailabilityRepository {
  /// Busca todas as disponibilidades de um conjunto
  ///
  /// [ensembleId]: ID do conjunto
  /// [forceRemote]: Se true, força busca no servidor (ignora cache)
  ///
  /// Retorna Right(days) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, List<AvailabilityDayEntity>>> getAvailabilities({
    required String ensembleId,
    bool forceRemote = false,
  });

  /// Busca uma disponibilidade de um conjunto
  ///
  /// [ensembleId]: ID do conjunto
  /// [dayId]: ID do dia a buscar
  ///
  /// Retorna Right(day) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, AvailabilityDayEntity>> getAvailability({
    required String ensembleId,
    required String dayId,
  });

  /// Cria uma nova disponibilidade
  ///
  /// [ensembleId]: ID do conjunto
  /// [day]: Dia de disponibilidade a criar
  ///
  /// Retorna Right(day) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, AvailabilityDayEntity>> createAvailability({
    required String ensembleId,
    required AvailabilityDayEntity day,
  });

  /// Atualiza uma disponibilidade
  ///
  /// [ensembleId]: ID do conjunto
  /// [day]: Dia atualizado
  ///
  /// Retorna Right(day) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, AvailabilityDayEntity>> updateAvailability({
    required String ensembleId,
    required AvailabilityDayEntity day,
  });

  /// Deleta uma disponibilidade
  ///
  /// [ensembleId]: ID do conjunto
  /// [dayId]: ID do dia a deletar
  ///
  /// Retorna Right(void) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, void>> deleteAvailability({
    required String ensembleId,
    required String dayId,
  });

  /// Limpa o cache de disponibilidade
  ///
  /// [ensembleId]: ID do conjunto
  Future<Either<Failure, void>> clearCache({required String ensembleId});
}
