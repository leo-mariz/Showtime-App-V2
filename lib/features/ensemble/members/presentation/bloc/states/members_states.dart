import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MembersState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MembersInitial extends MembersState {}

// ==================== GET ALL MEMBERS ====================

class GetAllMembersLoading extends MembersState {}

class GetAllMembersSuccess extends MembersState {
  final List<EnsembleMemberEntity> members;

  GetAllMembersSuccess({required this.members});

  @override
  List<Object?> get props => [members];
}

class GetAllMembersFailure extends MembersState {
  final String error;

  GetAllMembersFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET MEMBER BY ID ====================

class GetMemberByIdLoading extends MembersState {}

class GetMemberByIdSuccess extends MembersState {
  final EnsembleMemberEntity? member;

  GetMemberByIdSuccess({required this.member});

  @override
  List<Object?> get props => [member];
}

class GetMemberByIdFailure extends MembersState {
  final String error;

  GetMemberByIdFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CREATE MEMBER ====================

class CreateMemberLoading extends MembersState {}

class CreateMemberSuccess extends MembersState {
  final EnsembleMemberEntity member;

  CreateMemberSuccess({required this.member});

  @override
  List<Object?> get props => [member];
}

class CreateMemberFailure extends MembersState {
  final String error;

  CreateMemberFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE MEMBER ====================

class UpdateMemberLoading extends MembersState {}

class UpdateMemberSuccess extends MembersState {
  final EnsembleMemberEntity member;

  UpdateMemberSuccess({required this.member});

  @override
  List<Object?> get props => [member];
}

class UpdateMemberFailure extends MembersState {
  final String error;

  UpdateMemberFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== DELETE MEMBER ====================

class DeleteMemberLoading extends MembersState {}

class DeleteMemberSuccess extends MembersState {
  final String memberId;

  DeleteMemberSuccess({required this.memberId});

  @override
  List<Object?> get props => [memberId];
}

class DeleteMemberFailure extends MembersState {
  final String error;

  DeleteMemberFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
