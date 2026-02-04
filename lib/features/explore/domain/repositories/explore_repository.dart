import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Explore
/// 
/// Define operações de busca para explorar artistas sem lógica de negócio.
/// A lógica de negócio (buscar artistas + disponibilidades) fica nos UseCases.
/// 
/// Feature completamente independente (não reutiliza outras features).
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados (com cache agressivo)
abstract class IExploreRepository {
  // ==================== GET OPERATIONS ====================

  /// Busca todos os artistas aprovados e ativos para explorar
  /// Usa cache agressivo (2 horas de validade)
  /// Se cache válido, retorna do cache (0 reads)
  /// Se cache inválido, busca do Firestore e atualiza cache
  /// 
  /// [forceRefresh]: Se true, ignora o cache e busca diretamente do Firestore (útil para testes)
  Future<Either<Failure, List<ArtistEntity>>> getArtistsForExplore({
    bool forceRefresh = false,
  });
  
  /// Busca disponibilidade de um dia específico de um artista
  /// Usa cache agressivo específico de explore (2 horas de validade)
  /// Busca diretamente do Firestore via explore remote datasource
  /// Se cache válido, retorna do cache (0 reads)
  /// Se cache inválido, busca do Firestore e atualiza cache de explore
  /// 
  /// [artistId]: ID do artista
  /// [date]: Data específica para buscar (formato: YYYY-MM-DD)
  /// [forceRefresh]: Se true, ignora o cache e busca diretamente do Firestore (útil para testes)
  Future<Either<Failure, AvailabilityDayEntity?>> getArtistAvailabilityDayForExplore(
    String artistId,
    DateTime date, {
    bool forceRefresh = false,
  });
  
  /// Busca todas as disponibilidades de um artista
  /// Usa cache agressivo específico de explore (2 horas de validade)
  /// Busca todas as disponibilidades do Firestore
  /// Se cache válido, retorna do cache (0 reads)
  /// Se cache inválido, busca do Firestore e atualiza cache de explore
  /// 
  /// [artistId]: ID do artista
  /// [forceRefresh]: Se true, ignora o cache e busca diretamente do Firestore (útil para testes)
  /// 
  /// Retorna todas as disponibilidades do artista (sem filtros)
  /// O filtro de isActive e slots available será feito no UseCase
  Future<Either<Failure, List<AvailabilityDayEntity>>> getArtistAllAvailabilitiesForExplore(
    String artistId, {
    bool forceRefresh = false,
  });
}

