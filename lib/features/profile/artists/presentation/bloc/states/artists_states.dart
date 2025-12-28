import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ArtistsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ArtistsInitial extends ArtistsState {}

// ==================== GET ARTIST STATES ====================

class GetArtistLoading extends ArtistsState {}

class GetArtistSuccess extends ArtistsState {
  final ArtistEntity artist;

  GetArtistSuccess({required this.artist});

  @override
  List<Object?> get props => [artist];
}

class GetArtistFailure extends ArtistsState {
  final String error;

  GetArtistFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ARTIST STATES ====================

class UpdateArtistLoading extends ArtistsState {}

class UpdateArtistSuccess extends ArtistsState {}

class UpdateArtistFailure extends ArtistsState {
  final String error;

  UpdateArtistFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ARTIST PROFILE PICTURE STATES ====================

class UpdateArtistProfilePictureLoading extends ArtistsState {}

class UpdateArtistProfilePictureSuccess extends ArtistsState {}

class UpdateArtistProfilePictureFailure extends ArtistsState {
  final String error;

  UpdateArtistProfilePictureFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ARTIST NAME STATES ====================

class UpdateArtistNameLoading extends ArtistsState {}

class UpdateArtistNameSuccess extends ArtistsState {}

class UpdateArtistNameFailure extends ArtistsState {
  final String error;

  UpdateArtistNameFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ARTIST PROFESSIONAL INFO STATES ====================

class UpdateArtistProfessionalInfoLoading extends ArtistsState {}

class UpdateArtistProfessionalInfoSuccess extends ArtistsState {}

class UpdateArtistProfessionalInfoFailure extends ArtistsState {
  final String error;

  UpdateArtistProfessionalInfoFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ARTIST AGREEMENT STATES ====================

class UpdateArtistAgreementLoading extends ArtistsState {}

class UpdateArtistAgreementSuccess extends ArtistsState {}

class UpdateArtistAgreementFailure extends ArtistsState {
  final String error;

  UpdateArtistAgreementFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CHECK ARTIST NAME EXISTS STATES ====================

class CheckArtistNameExistsLoading extends ArtistsState {
  final String artistName;

  CheckArtistNameExistsLoading({required this.artistName});

  @override
  List<Object?> get props => [artistName];
}

class CheckArtistNameExistsSuccess extends ArtistsState {
  final String artistName;
  final bool exists; // true se já existe, false se está disponível

  CheckArtistNameExistsSuccess({
    required this.artistName,
    required this.exists,
  });

  @override
  List<Object?> get props => [artistName, exists];
}

class CheckArtistNameExistsFailure extends ArtistsState {
  final String artistName;
  final String error;

  CheckArtistNameExistsFailure({
    required this.artistName,
    required this.error,
  });

  @override
  List<Object?> get props => [artistName, error];
}

