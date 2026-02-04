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

/// Lista de conjuntos carregada. [currentEnsemble] indica o conjunto em foco
/// (ex.: quando estamos na tela da área do conjunto).
class GetAllEnsemblesSuccess extends EnsembleState {
  final List<EnsembleEntity> ensembles;
  final EnsembleEntity? currentEnsemble;

  GetAllEnsemblesSuccess({required this.ensembles, this.currentEnsemble});

  @override
  List<Object?> get props => [ensembles, currentEnsemble];
}

class GetAllEnsemblesFailure extends EnsembleState {
  final String error;

  GetAllEnsemblesFailure({required this.error});

  @override
  List<Object?> get props => [error];
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

// ==================== UPDATE ENSEMBLE ACTIVE STATUS ====================

class UpdateEnsembleActiveStatusLoading extends EnsembleState {}

class UpdateEnsembleActiveStatusSuccess extends EnsembleState {
  final EnsembleEntity ensemble;

  UpdateEnsembleActiveStatusSuccess({required this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

class UpdateEnsembleActiveStatusFailure extends EnsembleState {
  final String error;

  UpdateEnsembleActiveStatusFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ENSEMBLE PROFESSIONAL INFO ====================

class UpdateEnsembleProfessionalInfoLoading extends EnsembleState {}

class UpdateEnsembleProfessionalInfoSuccess extends EnsembleState {
  final EnsembleEntity? ensemble;

  UpdateEnsembleProfessionalInfoSuccess({this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

class UpdateEnsembleProfessionalInfoFailure extends EnsembleState {
  final String error;

  UpdateEnsembleProfessionalInfoFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ENSEMBLE MEMBERS ====================

class UpdateEnsembleMembersLoading extends EnsembleState {}

class UpdateEnsembleMembersSuccess extends EnsembleState {
  final List<EnsembleEntity> ensembles;
  final EnsembleEntity? currentEnsemble;

  UpdateEnsembleMembersSuccess({
    required this.ensembles,
    this.currentEnsemble,
  });

  @override
  List<Object?> get props => [ensembles, currentEnsemble];
}

class UpdateEnsembleMembersFailure extends EnsembleState {
  final String error;

  UpdateEnsembleMembersFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ENSEMBLE PROFILE PHOTO ====================

class UpdateEnsembleProfilePhotoLoading extends EnsembleState {}

class UpdateEnsembleProfilePhotoSuccess extends EnsembleState {
  final EnsembleEntity? ensemble;

  UpdateEnsembleProfilePhotoSuccess({this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

class UpdateEnsembleProfilePhotoFailure extends EnsembleState {
  final String error;

  UpdateEnsembleProfilePhotoFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ENSEMBLE PRESENTATION VIDEO ====================

class UpdateEnsemblePresentationVideoLoading extends EnsembleState {}

class UpdateEnsemblePresentationVideoSuccess extends EnsembleState {
  final EnsembleEntity? ensemble;

  UpdateEnsemblePresentationVideoSuccess({this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

class UpdateEnsemblePresentationVideoFailure extends EnsembleState {
  final String error;

  UpdateEnsemblePresentationVideoFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE ENSEMBLE MEMBER TALENTS ====================

class UpdateEnsembleMemberTalentsLoading extends EnsembleState {}

class UpdateEnsembleMemberTalentsSuccess extends EnsembleState {
  final EnsembleEntity? ensemble;

  UpdateEnsembleMemberTalentsSuccess({this.ensemble});

  @override
  List<Object?> get props => [ensemble];
}

class UpdateEnsembleMemberTalentsFailure extends EnsembleState {
  final String error;

  UpdateEnsembleMemberTalentsFailure({required this.error});

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
