import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
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
  /// Usa cache agressivo (1 hora de validade)
  /// Se cache válido, retorna do cache (0 reads)
  /// Se cache inválido, busca do Firestore e atualiza cache
  /// 
  /// [forceRefresh]: Se true, ignora o cache e busca diretamente do Firestore (útil para testes)
  Future<Either<Failure, List<ArtistEntity>>> getArtistsForExplore({
    bool forceRefresh = false,
  });
  
  /// Busca disponibilidades de um artista específico para explorar
  /// Usa cache agressivo específico de explore (2 horas de validade)
  /// Busca diretamente do Firestore via explore remote datasource
  /// Se cache válido, retorna do cache (0 reads)
  /// Se cache inválido, busca do Firestore e atualiza cache de explore
  /// 
  /// [forceRefresh]: Se true, ignora o cache e busca diretamente do Firestore (útil para testes)
  Future<Either<Failure, List<AvailabilityEntity>>> getArtistAvailabilitiesForExplore(
    String artistId, {
    bool forceRefresh = false,
  });
  
  /// Busca disponibilidades de um artista com filtros otimizados
  /// Usa cache agressivo específico de explore com filtros (2 horas de validade)
  /// Filtra por data e geohash no Firestore para reduzir documentos lidos
  /// Se cache válido, retorna do cache (0 reads)
  /// Se cache inválido, busca do Firestore com filtros e atualiza cache
  /// 
  /// [artistId]: ID do artista
  /// [selectedDate]: Data selecionada para filtrar (opcional)
  /// [userGeohash]: Geohash do endereço do usuário (opcional)
  /// [forceRefresh]: Se true, ignora o cache e busca diretamente do Firestore (útil para testes)
  Future<Either<Failure, List<AvailabilityEntity>>> getArtistAvailabilitiesFilteredForExplore(
    String artistId, {
    DateTime? selectedDate,
    String? userGeohash,
    bool forceRefresh = false,
  });
}

