import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:equatable/equatable.dart';

abstract class GroupsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class GroupsInitial extends GroupsState {}

// ==================== GET GROUPS STATES ====================

class GetGroupsLoading extends GroupsState {}

class GetGroupsSuccess extends GroupsState {
  final List<GroupEntity> groups;

  GetGroupsSuccess({required this.groups});

  @override
  List<Object?> get props => [groups];
}

class GetGroupsFailure extends GroupsState {
  final String error;

  GetGroupsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET GROUP STATES ====================

class GetGroupLoading extends GroupsState {}

class GetGroupSuccess extends GroupsState {
  final GroupEntity group;

  GetGroupSuccess({required this.group});

  @override
  List<Object?> get props => [group];
}

class GetGroupFailure extends GroupsState {
  final String error;

  GetGroupFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== ADD GROUP STATES ====================

class AddGroupLoading extends GroupsState {}

class AddGroupSuccess extends GroupsState {
  final GroupEntity group;

  AddGroupSuccess({required this.group});

  @override
  List<Object?> get props => [group];
}

class AddGroupFailure extends GroupsState {
  final String error;

  AddGroupFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE GROUP STATES ====================

class UpdateGroupLoading extends GroupsState {}

class UpdateGroupSuccess extends GroupsState {}

class UpdateGroupFailure extends GroupsState {
  final String error;

  UpdateGroupFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== DELETE GROUP STATES ====================

class DeleteGroupLoading extends GroupsState {}

class DeleteGroupSuccess extends GroupsState {}

class DeleteGroupFailure extends GroupsState {
  final String error;

  DeleteGroupFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE GROUP NAME STATES ====================

class UpdateGroupNameLoading extends GroupsState {}

class UpdateGroupNameSuccess extends GroupsState {}

class UpdateGroupNameFailure extends GroupsState {
  final String error;

  UpdateGroupNameFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE GROUP PROFILE PICTURE STATES ====================

class UpdateGroupProfilePictureLoading extends GroupsState {}

class UpdateGroupProfilePictureSuccess extends GroupsState {}

class UpdateGroupProfilePictureFailure extends GroupsState {
  final String error;

  UpdateGroupProfilePictureFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

