import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_member.dart';
import 'package:equatable/equatable.dart';

abstract class EnsembleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET ALL ENSEMBLES ====================

class GetAllEnsemblesByArtistEvent extends EnsembleEvent {
  final bool forceRemote;

  GetAllEnsemblesByArtistEvent({this.forceRemote = false});

  @override
  List<Object?> get props => [forceRemote];
}

// ==================== GET ENSEMBLE BY ID ====================

class GetEnsembleByIdEvent extends EnsembleEvent {
  final String ensembleId;
  /// Quando true, refaz a busca mesmo que [currentEnsemble] já seja este conjunto (ex.: após remover integrante).
  final bool forceRefresh;

  GetEnsembleByIdEvent({required this.ensembleId, this.forceRefresh = false});

  @override
  List<Object?> get props => [ensembleId, forceRefresh];
}

// ==================== CREATE ENSEMBLE ====================

class CreateEnsembleEvent extends EnsembleEvent {
  final List<EnsembleMember> members;

  CreateEnsembleEvent({required this.members});

  @override
  List<Object?> get props => [members];
}

// ==================== UPDATE ENSEMBLE ====================

class UpdateEnsembleEvent extends EnsembleEvent {
  final EnsembleEntity ensemble;

  UpdateEnsembleEvent({required this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

/// Atualiza as informações profissionais do conjunto.
class UpdateEnsembleProfessionalInfoEvent extends EnsembleEvent {
  final String ensembleId;
  final ProfessionalInfoEntity professionalInfo;

  UpdateEnsembleProfessionalInfoEvent({
    required this.ensembleId,
    required this.professionalInfo,
  });

  @override
  List<Object?> get props => [ensembleId, professionalInfo];
}

/// Atualiza a lista de integrantes persistida no conjunto.
class UpdateEnsembleMembersEvent extends EnsembleEvent {
  final String ensembleId;
  final List<EnsembleMember> members;

  UpdateEnsembleMembersEvent({
    required this.ensembleId,
    required this.members,
  });

  @override
  List<Object?> get props => [ensembleId, members];
}

// ==================== UPDATE ENSEMBLE PROFILE PHOTO ====================

class UpdateEnsembleProfilePhotoEvent extends EnsembleEvent {
  final String ensembleId;
  final String localFilePath;

  UpdateEnsembleProfilePhotoEvent({
    required this.ensembleId,
    required this.localFilePath,
  });

  @override
  List<Object?> get props => [ensembleId, localFilePath];
}

// ==================== UPDATE ENSEMBLE PRESENTATION VIDEO ====================

class UpdateEnsemblePresentationVideoEvent extends EnsembleEvent {
  final String ensembleId;
  final String localFilePath;

  UpdateEnsemblePresentationVideoEvent({
    required this.ensembleId,
    required this.localFilePath,
  });

  @override
  List<Object?> get props => [ensembleId, localFilePath];
}

// ==================== UPDATE ENSEMBLE MEMBER TALENTS ====================

class UpdateEnsembleMemberTalentsEvent extends EnsembleEvent {
  final String ensembleId;
  final String memberId;
  final List<String> talents;

  UpdateEnsembleMemberTalentsEvent({required this.ensembleId, required this.memberId, required this.talents});
}

// ==================== UPDATE ENSEMBLE ACTIVE STATUS ====================

class UpdateEnsembleActiveStatusEvent extends EnsembleEvent {
  final String ensembleId;
  final bool isActive;

  UpdateEnsembleActiveStatusEvent({
    required this.ensembleId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [ensembleId, isActive];
}

// ==================== DELETE ENSEMBLE ====================

class DeleteEnsembleEvent extends EnsembleEvent {
  final String ensembleId;

  DeleteEnsembleEvent({required this.ensembleId});

  @override
  List<Object?> get props => [ensembleId];
}

// ==================== RESET ====================

class ResetEnsembleEvent extends EnsembleEvent {}
