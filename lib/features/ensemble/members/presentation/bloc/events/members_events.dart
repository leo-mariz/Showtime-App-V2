import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MembersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET ALL MEMBERS ====================

class GetAllMembersEvent extends MembersEvent {
  final bool forceRemote;

  GetAllMembersEvent({this.forceRemote = false});

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

// ==================== RESET ====================

class ResetMembersEvent extends MembersEvent {}
