import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ArtistsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET ARTIST EVENTS ====================

class GetArtistEvent extends ArtistsEvent {}

// ==================== ADD ARTIST EVENTS ====================

class AddArtistEvent extends ArtistsEvent {}

// ==================== UPDATE ARTIST EVENTS ====================

class UpdateArtistEvent extends ArtistsEvent {
  final ArtistEntity artist;

  UpdateArtistEvent({
    required this.artist,
  });

  @override
  List<Object?> get props => [artist];
}

// ==================== UPDATE ARTIST PROFILE PICTURE EVENTS ====================

class UpdateArtistProfilePictureEvent extends ArtistsEvent {
  final String localFilePath;

  UpdateArtistProfilePictureEvent({
    required this.localFilePath,
  });

  @override
  List<Object?> get props => [localFilePath];
}

// ==================== UPDATE ARTIST NAME EVENTS ====================

class UpdateArtistNameEvent extends ArtistsEvent {
  final String artistName;

  UpdateArtistNameEvent({
    required this.artistName,
  });

  @override
  List<Object?> get props => [artistName];
}

// ==================== UPDATE ARTIST PROFESSIONAL INFO EVENTS ====================

class UpdateArtistProfessionalInfoEvent extends ArtistsEvent {
  final ProfessionalInfoEntity professionalInfo;

  UpdateArtistProfessionalInfoEvent({
    required this.professionalInfo,
  });

  @override
  List<Object?> get props => [professionalInfo];
}

// ==================== UPDATE ARTIST AGREEMENT EVENTS ====================

class UpdateArtistAgreementEvent extends ArtistsEvent {
  final bool agreedToTerms;

  UpdateArtistAgreementEvent({
    required this.agreedToTerms,
  });

  @override
  List<Object?> get props => [agreedToTerms];
}

// ==================== UPDATE ARTIST PRESENTATION MEDIAS EVENTS ====================

class UpdateArtistPresentationMediasEvent extends ArtistsEvent {
  final Map<String, String> talentLocalFilePaths; // Map<talent, localFilePath ou URL>

  UpdateArtistPresentationMediasEvent({
    required this.talentLocalFilePaths,
  });

  @override
  List<Object?> get props => [talentLocalFilePaths];
}

// ==================== UPDATE ARTIST BANK ACCOUNT EVENTS ====================

class UpdateArtistBankAccountEvent extends ArtistsEvent {
  final BankAccountEntity bankAccount;

  UpdateArtistBankAccountEvent({
    required this.bankAccount,
  });

  @override
  List<Object?> get props => [bankAccount];
}

// ==================== CHECK ARTIST NAME EXISTS EVENTS ====================

class CheckArtistNameExistsEvent extends ArtistsEvent {
  final String artistName;

  CheckArtistNameExistsEvent({
    required this.artistName,
  });

  @override
  List<Object?> get props => [artistName];
}

// ==================== UPDATE ARTIST ACTIVE STATUS EVENTS ====================

class UpdateArtistActiveStatusEvent extends ArtistsEvent {
  final bool isActive;

  UpdateArtistActiveStatusEvent({
    required this.isActive,
  });

  @override
  List<Object?> get props => [isActive];
}

// ==================== RESET EVENT ====================

class ResetArtistsEvent extends ArtistsEvent {}