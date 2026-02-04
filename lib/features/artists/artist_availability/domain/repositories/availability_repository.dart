import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:app/core/errors/failure.dart';

/// Repository para gerenciar disponibilidade
/// 
/// Interface que define operações de disponibilidade
/// Implementação deve orquestrar remote e local datasources
abstract class IAvailabilityRepository {
  /// Busca todas as disponibilidades de um artista
  /// 
  /// [artistId]: ID do artista
  /// [forceRemote]: Se true, força busca no servidor (ignora cache)
  /// 
  /// Retorna Right(days) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, List<AvailabilityDayEntity>>> getAvailabilities({
    required String artistId,
    bool forceRemote = false,
  });

  /// Busca uma disponibilidade de um artista
  /// 
  /// [artistId]: ID do artista
  /// [dayId]: ID do dia a buscar
  /// 
  /// Retorna Right(day) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, AvailabilityDayEntity>> getAvailability({
    required String artistId,
    required String dayId,
  });
  
  /// Cria uma nova disponibilidade
  /// 
  /// [artistId]: ID do artista
  /// [day]: Dia de disponibilidade a criar
  /// 
  /// Retorna Right(day) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, AvailabilityDayEntity>> createAvailability({
    required String artistId,
    required AvailabilityDayEntity day,
  });
  
  /// Atualiza uma disponibilidade
  /// 
  /// [artistId]: ID do artista
  /// [day]: Dia atualizado
  /// 
  /// Retorna Right(day) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, AvailabilityDayEntity>> updateAvailability({
    required String artistId,
    required AvailabilityDayEntity day,
  });
  
  /// Deleta uma disponibilidade
  /// 
  /// [artistId]: ID do artista
  /// [dayId]: ID do dia a deletar
  /// 
  /// Retorna Right(void) em caso de sucesso
  /// Retorna Left(Failure) em caso de erro
  Future<Either<Failure, void>> deleteAvailability({
    required String artistId,
    required String dayId,
  });
  
  /// Limpa o cache de disponibilidade
  /// 
  /// [artistId]: ID do artista
  Future<Either<Failure, void>> clearCache({required String artistId});
}
