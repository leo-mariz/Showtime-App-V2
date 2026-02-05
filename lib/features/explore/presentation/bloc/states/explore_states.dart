import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/features/explore/domain/entities/artists/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/entities/ensembles/ensemble_with_availabilities_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ExploreState extends Equatable {
  /// Lista de artistas (quando disponível no estado atual).
  List<ArtistWithAvailabilitiesEntity>? get currentArtists => null;
  /// Lista de conjuntos (quando disponível no estado atual).
  List<EnsembleWithAvailabilitiesEntity>? get currentEnsembles => null;

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ExploreInitial extends ExploreState {}

// ==================== GET ARTISTS WITH AVAILABILITIES STATES ====================

/// Estado de carregamento ao buscar artistas (preserva dados de conjuntos para a outra aba).
class GetArtistsWithAvailabilitiesLoading extends ExploreState {
  final List<EnsembleWithAvailabilitiesEntity>? ensemblesWithAvailabilities;
  final int? ensemblesNextIndex;
  final bool? ensemblesHasMore;

  GetArtistsWithAvailabilitiesLoading({
    this.ensemblesWithAvailabilities,
    this.ensemblesNextIndex,
    this.ensemblesHasMore,
  });

  @override
  List<Object?> get props => [
        ensemblesWithAvailabilities,
        ensemblesNextIndex,
        ensemblesHasMore,
      ];

  @override
  List<EnsembleWithAvailabilitiesEntity>? get currentEnsembles =>
      ensemblesWithAvailabilities;
}

/// Estado de sucesso ao buscar artistas com disponibilidades.
/// Pode carregar também dados de conjuntos para manter a outra aba ao trocar.
class GetArtistsWithAvailabilitiesSuccess extends ExploreState {
  final List<ArtistWithAvailabilitiesEntity> artistsWithAvailabilities;
  final int nextIndex;
  final bool hasMore;
  final bool append;
  final String? selectedArtistId;
  final List<AvailabilityDayEntity>? availabilities;
  final List<EnsembleWithAvailabilitiesEntity>? ensemblesWithAvailabilities;
  final int? ensemblesNextIndex;
  final bool? ensemblesHasMore;

  GetArtistsWithAvailabilitiesSuccess({
    required this.artistsWithAvailabilities,
    this.nextIndex = 0,
    this.hasMore = false,
    this.append = false,
    this.selectedArtistId,
    this.availabilities,
    this.ensemblesWithAvailabilities,
    this.ensemblesNextIndex,
    this.ensemblesHasMore,
  });

  @override
  List<Object?> get props => [
        artistsWithAvailabilities,
        nextIndex,
        hasMore,
        append,
        selectedArtistId,
        availabilities,
        ensemblesWithAvailabilities,
        ensemblesNextIndex,
        ensemblesHasMore,
      ];

  @override
  List<ArtistWithAvailabilitiesEntity>? get currentArtists =>
      artistsWithAvailabilities;
  @override
  List<EnsembleWithAvailabilitiesEntity>? get currentEnsembles =>
      ensemblesWithAvailabilities;

  GetArtistsWithAvailabilitiesSuccess copyWith({
    List<ArtistWithAvailabilitiesEntity>? artistsWithAvailabilities,
    int? nextIndex,
    bool? hasMore,
    bool? append,
    String? selectedArtistId,
    List<AvailabilityDayEntity>? availabilities,
    List<EnsembleWithAvailabilitiesEntity>? ensemblesWithAvailabilities,
    int? ensemblesNextIndex,
    bool? ensemblesHasMore,
  }) {
    return GetArtistsWithAvailabilitiesSuccess(
      artistsWithAvailabilities:
          artistsWithAvailabilities ?? this.artistsWithAvailabilities,
      nextIndex: nextIndex ?? this.nextIndex,
      hasMore: hasMore ?? this.hasMore,
      append: append ?? this.append,
      selectedArtistId: selectedArtistId ?? this.selectedArtistId,
      availabilities: availabilities ?? this.availabilities,
      ensemblesWithAvailabilities:
          ensemblesWithAvailabilities ?? this.ensemblesWithAvailabilities,
      ensemblesNextIndex: ensemblesNextIndex ?? this.ensemblesNextIndex,
      ensemblesHasMore: ensemblesHasMore ?? this.ensemblesHasMore,
    );
  }
}

/// Estado de falha ao buscar artistas com disponibilidades
class GetArtistsWithAvailabilitiesFailure extends ExploreState {
  final String error;

  GetArtistsWithAvailabilitiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET ARTIST ALL AVAILABILITIES STATES ====================

/// Estado de carregamento ao buscar todas as disponibilidades de um artista
class GetArtistAllAvailabilitiesLoading extends ExploreState {}

/// Estado de falha ao buscar todas as disponibilidades de um artista
class GetArtistAllAvailabilitiesFailure extends ExploreState {
  final String error;

  GetArtistAllAvailabilitiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET ENSEMBLES WITH AVAILABILITIES STATES ====================

/// Estado de carregamento ao buscar conjuntos (preserva dados de artistas para a outra aba).
class GetEnsemblesWithAvailabilitiesLoading extends ExploreState {
  final List<ArtistWithAvailabilitiesEntity>? artistsWithAvailabilities;
  final int? artistsNextIndex;
  final bool? artistsHasMore;

  GetEnsemblesWithAvailabilitiesLoading({
    this.artistsWithAvailabilities,
    this.artistsNextIndex,
    this.artistsHasMore,
  });

  @override
  List<Object?> get props => [
        artistsWithAvailabilities,
        artistsNextIndex,
        artistsHasMore,
      ];

  @override
  List<ArtistWithAvailabilitiesEntity>? get currentArtists =>
      artistsWithAvailabilities;
}

/// Estado de sucesso ao buscar conjuntos; pode carregar também dados de artistas.
class GetEnsemblesWithAvailabilitiesSuccess extends ExploreState {
  final List<EnsembleWithAvailabilitiesEntity> ensemblesWithAvailabilities;
  final int nextIndex;
  final bool hasMore;
  final bool append;
  final List<ArtistWithAvailabilitiesEntity>? artistsWithAvailabilities;
  final int? artistsNextIndex;
  final bool? artistsHasMore;

  GetEnsemblesWithAvailabilitiesSuccess({
    required this.ensemblesWithAvailabilities,
    this.nextIndex = 0,
    this.hasMore = false,
    this.append = false,
    this.artistsWithAvailabilities,
    this.artistsNextIndex,
    this.artistsHasMore,
  });

  @override
  List<Object?> get props => [
        ensemblesWithAvailabilities,
        nextIndex,
        hasMore,
        append,
        artistsWithAvailabilities,
        artistsNextIndex,
        artistsHasMore,
      ];

  @override
  List<ArtistWithAvailabilitiesEntity>? get currentArtists =>
      artistsWithAvailabilities;
  @override
  List<EnsembleWithAvailabilitiesEntity>? get currentEnsembles =>
      ensemblesWithAvailabilities;
}

class GetEnsemblesWithAvailabilitiesFailure extends ExploreState {
  final String error;

  GetEnsemblesWithAvailabilitiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Extension para acessar listas e paginação de qualquer estado (para abas Individual/Conjuntos).
extension ExploreStateData on ExploreState {
  List<ArtistWithAvailabilitiesEntity>? get currentArtists {
    if (this is GetArtistsWithAvailabilitiesSuccess) {
      return (this as GetArtistsWithAvailabilitiesSuccess)
          .artistsWithAvailabilities;
    }
    if (this is GetEnsemblesWithAvailabilitiesSuccess) {
      return (this as GetEnsemblesWithAvailabilitiesSuccess)
          .artistsWithAvailabilities;
    }
    if (this is GetEnsemblesWithAvailabilitiesLoading) {
      return (this as GetEnsemblesWithAvailabilitiesLoading)
          .artistsWithAvailabilities;
    }
    return null;
  }

  List<EnsembleWithAvailabilitiesEntity>? get currentEnsembles {
    if (this is GetEnsemblesWithAvailabilitiesSuccess) {
      return (this as GetEnsemblesWithAvailabilitiesSuccess)
          .ensemblesWithAvailabilities;
    }
    if (this is GetArtistsWithAvailabilitiesSuccess) {
      return (this as GetArtistsWithAvailabilitiesSuccess)
          .ensemblesWithAvailabilities;
    }
    if (this is GetArtistsWithAvailabilitiesLoading) {
      return (this as GetArtistsWithAvailabilitiesLoading)
          .ensemblesWithAvailabilities;
    }
    return null;
  }

  int get artistsNextIndex {
    if (this is GetArtistsWithAvailabilitiesSuccess) {
      return (this as GetArtistsWithAvailabilitiesSuccess).nextIndex;
    }
    if (this is GetEnsemblesWithAvailabilitiesSuccess) {
      return (this as GetEnsemblesWithAvailabilitiesSuccess)
              .artistsNextIndex ??
          0;
    }
    if (this is GetEnsemblesWithAvailabilitiesLoading) {
      return (this as GetEnsemblesWithAvailabilitiesLoading)
              .artistsNextIndex ??
          0;
    }
    return 0;
  }

  bool get artistsHasMore {
    if (this is GetArtistsWithAvailabilitiesSuccess) {
      return (this as GetArtistsWithAvailabilitiesSuccess).hasMore;
    }
    if (this is GetEnsemblesWithAvailabilitiesSuccess) {
      return (this as GetEnsemblesWithAvailabilitiesSuccess)
              .artistsHasMore ??
          false;
    }
    if (this is GetEnsemblesWithAvailabilitiesLoading) {
      return (this as GetEnsemblesWithAvailabilitiesLoading)
              .artistsHasMore ??
          false;
    }
    return false;
  }

  int get ensemblesNextIndex {
    if (this is GetEnsemblesWithAvailabilitiesSuccess) {
      return (this as GetEnsemblesWithAvailabilitiesSuccess).nextIndex;
    }
    if (this is GetArtistsWithAvailabilitiesSuccess) {
      return (this as GetArtistsWithAvailabilitiesSuccess)
              .ensemblesNextIndex ??
          0;
    }
    if (this is GetArtistsWithAvailabilitiesLoading) {
      return (this as GetArtistsWithAvailabilitiesLoading)
              .ensemblesNextIndex ??
          0;
    }
    return 0;
  }

  bool get ensemblesHasMore {
    if (this is GetEnsemblesWithAvailabilitiesSuccess) {
      return (this as GetEnsemblesWithAvailabilitiesSuccess).hasMore;
    }
    if (this is GetArtistsWithAvailabilitiesSuccess) {
      return (this as GetArtistsWithAvailabilitiesSuccess)
              .ensemblesHasMore ??
          false;
    }
    if (this is GetArtistsWithAvailabilitiesLoading) {
      return (this as GetArtistsWithAvailabilitiesLoading)
              .ensemblesHasMore ??
          false;
    }
    return false;
  }
}

