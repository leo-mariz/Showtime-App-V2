import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'ensemble_with_availabilities_entity.mapper.dart';

/// Entidade que agrupa um conjunto (ensemble) com suas disponibilidades.
/// Usada na feature explore para representar conjuntos disponíveis para contratação.
@MappableClass()
class EnsembleWithAvailabilitiesEntity
    with EnsembleWithAvailabilitiesEntityMappable {
  final EnsembleEntity ensemble;
  final List<AvailabilityDayEntity> availabilities;
  /// Artista dono do conjunto (resolvido via explore repository).
  final ArtistEntity? ownerArtist;

  EnsembleWithAvailabilitiesEntity({
    required this.ensemble,
    required this.availabilities,
    this.ownerArtist,
  });

  /// Factory para criar uma instância com lista vazia de disponibilidades
  factory EnsembleWithAvailabilitiesEntity.empty(
    EnsembleEntity ensemble, {
    ArtistEntity? ownerArtist,
  }) {
    return EnsembleWithAvailabilitiesEntity(
      ensemble: ensemble,
      availabilities: [],
      ownerArtist: ownerArtist,
    );
  }

  /// Verifica se o conjunto tem disponibilidades
  bool get hasAvailabilities => availabilities.isNotEmpty;
}

/// Extension para cache e referências de conjuntos no explore
extension EnsembleWithAvailabilitiesEntityReference
    on EnsembleWithAvailabilitiesEntity {
  // ==================== CACHE KEYS (Constantes) ====================

  /// Chave de cache para conjuntos no explore
  static const String ensemblesCacheKey = 'explore_ensembles_cache';

  /// Prefixo usado para criar chaves únicas de disponibilidades por conjunto
  static const String availabilitiesCacheKeyPrefix =
      'explore_ensemble_availability_';

  // ==================== CACHE VALIDITY (Constantes) ====================

  /// Validade do cache de conjuntos (2 horas)
  static const Duration ensemblesCacheValidity = Duration(hours: 2);

  /// Validade do cache de disponibilidades (2 horas)
  static const Duration availabilitiesCacheValidity = Duration(hours: 2);
}
