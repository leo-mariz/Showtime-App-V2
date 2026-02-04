import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ExploreState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ExploreInitial extends ExploreState {}

// ==================== GET ARTISTS WITH AVAILABILITIES STATES ====================

/// Estado de carregamento ao buscar artistas com disponibilidades
class GetArtistsWithAvailabilitiesLoading extends ExploreState {}

/// Estado de sucesso ao buscar artistas com disponibilidades
class GetArtistsWithAvailabilitiesSuccess extends ExploreState {
  final List<ArtistWithAvailabilitiesEntity> artistsWithAvailabilities;
  final int nextIndex;
  final bool hasMore;
  final bool append;
  final String? selectedArtistId;
  final List<AvailabilityDayEntity>? availabilities;

  GetArtistsWithAvailabilitiesSuccess({
    required this.artistsWithAvailabilities,
    this.nextIndex = 0,
    this.hasMore = false,
    this.append = false,
    this.selectedArtistId,
    this.availabilities,
  });

  @override
  List<Object?> get props => [artistsWithAvailabilities, nextIndex, hasMore, append, selectedArtistId, availabilities];

  GetArtistsWithAvailabilitiesSuccess copyWith({
    List<ArtistWithAvailabilitiesEntity>? artistsWithAvailabilities,
    int? nextIndex,
    bool? hasMore,
    bool? append,
    String? selectedArtistId,
    List<AvailabilityDayEntity>? availabilities,
  }) {
    return GetArtistsWithAvailabilitiesSuccess(
      artistsWithAvailabilities: artistsWithAvailabilities ?? this.artistsWithAvailabilities,
      nextIndex: nextIndex ?? this.nextIndex,
      hasMore: hasMore ?? this.hasMore,
      append: append ?? this.append,
      selectedArtistId: selectedArtistId ?? this.selectedArtistId,
      availabilities: availabilities ?? this.availabilities,
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

