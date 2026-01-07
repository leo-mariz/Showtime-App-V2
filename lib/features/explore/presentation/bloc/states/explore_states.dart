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

  GetArtistsWithAvailabilitiesSuccess({
    required this.artistsWithAvailabilities,
  });

  @override
  List<Object?> get props => [artistsWithAvailabilities];
}

/// Estado de falha ao buscar artistas com disponibilidades
class GetArtistsWithAvailabilitiesFailure extends ExploreState {
  final String error;

  GetArtistsWithAvailabilitiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

