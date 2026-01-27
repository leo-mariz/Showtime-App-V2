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

// ==================== RESET EVENT ====================

class ResetFavoritesEvent extends FavoritesEvent {}