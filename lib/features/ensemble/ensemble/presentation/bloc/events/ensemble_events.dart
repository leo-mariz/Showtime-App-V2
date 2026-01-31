import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/inputs/create_ensemble_input.dart';
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

  GetEnsembleByIdEvent({required this.ensembleId});

  @override
  List<Object?> get props => [ensembleId];
}

// ==================== CREATE ENSEMBLE ====================

class CreateEnsembleEvent extends EnsembleEvent {
  final CreateEnsembleInput input;

  CreateEnsembleEvent({required this.input});

  @override
  List<Object?> get props => [input];
}

// ==================== UPDATE ENSEMBLE ====================

class UpdateEnsembleEvent extends EnsembleEvent {
  final EnsembleEntity ensemble;

  UpdateEnsembleEvent({required this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

// ==================== DELETE ENSEMBLE ====================

class DeleteEnsembleEvent extends EnsembleEvent {
  final String ensembleId;

  DeleteEnsembleEvent({required this.ensembleId});

  @override
  List<Object?> get props => [ensembleId];
}

// ==================== CLEAR CACHE ====================

class ClearEnsembleCacheEvent extends EnsembleEvent {}

// ==================== RESET ====================

class ResetEnsembleEvent extends EnsembleEvent {}
