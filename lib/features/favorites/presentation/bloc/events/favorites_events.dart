import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== ADD FAVORITE EVENTS ====================

class AddFavoriteEvent extends FavoritesEvent {
  final String artistId;

  AddFavoriteEvent({
    required this.artistId,
  });

  @override
  List<Object?> get props => [artistId];
}

// ==================== REMOVE FAVORITE EVENTS ====================

class RemoveFavoriteEvent extends FavoritesEvent {
  final String artistId;

  RemoveFavoriteEvent({
    required this.artistId,
  });

  @override
  List<Object?> get props => [artistId];
}

// GET FAVORITE ARTISTS EVENTS ====================

class GetFavoriteArtistsEvent extends FavoritesEvent {}

// ==================== ENSEMBLE FAVORITES ====================

class AddFavoriteEnsembleEvent extends FavoritesEvent {
  final String ensembleId;

  AddFavoriteEnsembleEvent({required this.ensembleId});

  @override
  List<Object?> get props => [ensembleId];
}

class RemoveFavoriteEnsembleEvent extends FavoritesEvent {
  final String ensembleId;

  RemoveFavoriteEnsembleEvent({required this.ensembleId});

  @override
  List<Object?> get props => [ensembleId];
}

class GetFavoriteEnsemblesEvent extends FavoritesEvent {}

// ==================== RESET EVENT ====================

class ResetFavoritesEvent extends FavoritesEvent {}