import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/features/explore/domain/entities/ensembles/ensemble_with_availabilities_entity.dart';
import 'package:equatable/equatable.dart';

abstract class FavoritesState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class FavoritesInitial extends FavoritesState {}

// ==================== ADD FAVORITE STATES ====================

class AddFavoriteLoading extends FavoritesState {}

class AddFavoriteSuccess extends FavoritesState {}

class AddFavoriteFailure extends FavoritesState {
  final String error;

  AddFavoriteFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== REMOVE FAVORITE STATES ====================

class RemoveFavoriteLoading extends FavoritesState {}

class RemoveFavoriteSuccess extends FavoritesState {}

class RemoveFavoriteFailure extends FavoritesState {
  final String error;

  RemoveFavoriteFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class RemoveFavoriteEnsembleSuccess extends FavoritesState {}

// ==================== GET FAVORITE ARTISTS STATES ====================

class GetFavoriteArtistsLoading extends FavoritesState {}
class GetFavoriteArtistsSuccess extends FavoritesState {
  final List<ArtistEntity> artists;

  GetFavoriteArtistsSuccess({required this.artists});

  @override
  List<Object?> get props => [artists];
}
class GetFavoriteArtistsFailure extends FavoritesState {
  final String error;

  GetFavoriteArtistsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET FAVORITE ENSEMBLES STATES ====================

class GetFavoriteEnsemblesLoading extends FavoritesState {}

class GetFavoriteEnsemblesSuccess extends FavoritesState {
  final List<EnsembleWithAvailabilitiesEntity> ensembles;

  GetFavoriteEnsemblesSuccess({required this.ensembles});

  @override
  List<Object?> get props => [ensembles];
}

class GetFavoriteEnsemblesFailure extends FavoritesState {
  final String error;

  GetFavoriteEnsemblesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

