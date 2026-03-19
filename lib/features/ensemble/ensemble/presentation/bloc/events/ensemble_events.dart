import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/create_ensemble_dto.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/update_ensemble_integrants_dto.dart';
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
  final CreateEnsembleDto dto;

  CreateEnsembleEvent({required this.dto});

  @override
  List<Object?> get props => [dto];
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

/// Atualiza número de integrantes, talentos e tipo de conjunto.
class UpdateEnsembleMembersEvent extends EnsembleEvent {
  final String ensembleId;
  final UpdateEnsembleIntegrantsDto dto;

  UpdateEnsembleMembersEvent({
    required this.ensembleId,
    required this.dto,
  });

  @override
  List<Object?> get props => [ensembleId, dto];
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

// ==================== UPDATE ENSEMBLE TALENTS ====================

class UpdateEnsembleMemberTalentsEvent extends EnsembleEvent {
  final String ensembleId;
  final List<String> talents;

  UpdateEnsembleMemberTalentsEvent({
    required this.ensembleId,
    required this.talents,
  });

  @override
  List<Object?> get props => [ensembleId, talents];
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

// ==================== CHECK ENSEMBLE NAME EXISTS ====================

class CheckEnsembleNameExistsEvent extends EnsembleEvent {
  final String ensembleName;
  /// Ao editar, excluir este conjunto da verificação.
  final String? excludeEnsembleId;

  CheckEnsembleNameExistsEvent({
    required this.ensembleName,
    this.excludeEnsembleId,
  });

  @override
  List<Object?> get props => [ensembleName, excludeEnsembleId];
}

// ==================== UPDATE ENSEMBLE NAME ====================

class UpdateEnsembleNameEvent extends EnsembleEvent {
  final String ensembleId;
  final String ensembleName;

  UpdateEnsembleNameEvent({
    required this.ensembleId,
    required this.ensembleName,
  });

  @override
  List<Object?> get props => [ensembleId, ensembleName];
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
