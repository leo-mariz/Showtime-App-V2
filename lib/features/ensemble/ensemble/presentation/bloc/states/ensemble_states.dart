import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:equatable/equatable.dart';

abstract class EnsembleState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class EnsembleInitial extends EnsembleState {}

// ==================== GET ALL ENSEMBLES ====================

class GetAllEnsemblesLoading extends EnsembleState {}

class GetAllEnsemblesSuccess extends EnsembleState {
  final List<EnsembleEntity> ensembles;

  GetAllEnsemblesSuccess({required this.ensembles});

  @override
  List<Object?> get props => [ensembles];
}

class GetAllEnsemblesFailure extends EnsembleState {
  final String error;

  GetAllEnsemblesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET ENSEMBLE BY ID ====================

class GetEnsembleByIdLoading extends EnsembleState {}

class GetEnsembleByIdSuccess extends EnsembleState {
  final EnsembleEntity? ensemble;

  GetEnsembleByIdSuccess({required this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

class GetEnsembleByIdFailure extends EnsembleState {
  final String error;

  GetEnsembleByIdFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CREATE ENSEMBLE ====================

class CreateEnsembleLoading extends EnsembleState {}

class CreateEnsembleSuccess extends EnsembleState {
  final EnsembleEntity ensemble;

  CreateEnsembleSuccess({required this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

class CreateEnsembleFailure extends EnsembleState {
  final String error;

  CreateEnsembleFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ENSEMBLE ====================

class UpdateEnsembleLoading extends EnsembleState {}

class UpdateEnsembleSuccess extends EnsembleState {
  final EnsembleEntity ensemble;

  UpdateEnsembleSuccess({required this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

class UpdateEnsembleFailure extends EnsembleState {
  final String error;

  UpdateEnsembleFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== DELETE ENSEMBLE ====================

class DeleteEnsembleLoading extends EnsembleState {}

class DeleteEnsembleSuccess extends EnsembleState {
  final String ensembleId;

  DeleteEnsembleSuccess({required this.ensembleId});

  @override
  List<Object?> get props => [ensembleId];
}

class DeleteEnsembleFailure extends EnsembleState {
  final String error;

  DeleteEnsembleFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CLEAR CACHE ====================

class ClearEnsembleCacheSuccess extends EnsembleState {}

class ClearEnsembleCacheFailure extends EnsembleState {
  final String error;

  ClearEnsembleCacheFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
