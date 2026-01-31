import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MembersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET ALL MEMBERS ====================

class GetAllMembersByEnsembleEvent extends MembersEvent {
  final String ensembleId;
  final bool forceRemote;

  GetAllMembersByEnsembleEvent({
    required this.ensembleId,
    this.forceRemote = false,
  });

  @override
  List<Object?> get props => [ensembleId, forceRemote];
}

/// Carrega o pool de integrantes (todos os conjuntos do artista) para o modal de novo conjunto.
class GetAvailableMembersForNewEnsembleEvent extends MembersEvent {
  final bool forceRemote;

  GetAvailableMembersForNewEnsembleEvent({this.forceRemote = false});

  @override
  List<Object?> get props => [forceRemote];
}

// ==================== GET MEMBER BY ID ====================

class GetMemberByIdEvent extends MembersEvent {
  final String ensembleId;
  final String memberId;

  GetMemberByIdEvent({
    required this.ensembleId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [ensembleId, memberId];
}

// ==================== CREATE MEMBER ====================

class CreateMemberEvent extends MembersEvent {
  final String ensembleId;
  final EnsembleMemberEntity member;

  CreateMemberEvent({
    required this.ensembleId,
    required this.member,
  });

  @override
  List<Object?> get props => [ensembleId, member];
}

// ==================== UPDATE MEMBER ====================

class UpdateMemberEvent extends MembersEvent {
  final String ensembleId;
  final EnsembleMemberEntity member;

  UpdateMemberEvent({
    required this.ensembleId,
    required this.member,
  });

  @override
  List<Object?> get props => [ensembleId, member];
}

// ==================== DELETE MEMBER ====================

class DeleteMemberEvent extends MembersEvent {
  final String ensembleId;
  final String memberId;

  DeleteMemberEvent({
    required this.ensembleId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [ensembleId, memberId];
}

// ==================== CLEAR CACHE ====================

class ClearMembersCacheEvent extends MembersEvent {
  final String ensembleId;

  ClearMembersCacheEvent({required this.ensembleId});

  @override
  List<Object?> get props => [ensembleId];
}

// ==================== RESET ====================

class ResetMembersEvent extends MembersEvent {}
