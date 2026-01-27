import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:equatable/equatable.dart';

abstract class GroupsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET GROUPS EVENTS ====================

class GetGroupsEvent extends GroupsEvent {}

// ==================== GET GROUP EVENTS ====================

class GetGroupEvent extends GroupsEvent {
  final String groupUid;

  GetGroupEvent({
    required this.groupUid,
  });

  @override
  List<Object?> get props => [groupUid];
}

// ==================== ADD GROUP EVENTS ====================

class AddGroupEvent extends GroupsEvent {
  final GroupEntity group;

  AddGroupEvent({
    required this.group,
  });

  @override
  List<Object?> get props => [group];
}

// ==================== UPDATE GROUP EVENTS ====================

class UpdateGroupEvent extends GroupsEvent {
  final String groupUid;
  final GroupEntity group;

  UpdateGroupEvent({
    required this.groupUid,
    required this.group,
  });

  @override
  List<Object?> get props => [groupUid, group];
}

// ==================== DELETE GROUP EVENTS ====================

class DeleteGroupEvent extends GroupsEvent {
  final String groupUid;

  DeleteGroupEvent({
    required this.groupUid,
  });

  @override
  List<Object?> get props => [groupUid];
}

// ==================== UPDATE GROUP NAME EVENTS ====================

class UpdateGroupNameEvent extends GroupsEvent {
  final String groupUid;
  final String groupName;

  UpdateGroupNameEvent({
    required this.groupUid,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupUid, groupName];
}

// ==================== UPDATE GROUP PROFILE PICTURE EVENTS ====================

class UpdateGroupProfilePictureEvent extends GroupsEvent {
  final String groupUid;
  final String localFilePath;

  UpdateGroupProfilePictureEvent({
    required this.groupUid,
    required this.localFilePath,
  });

  @override
  List<Object?> get props => [groupUid, localFilePath];
}

// ==================== RESET EVENT ====================

class ResetGroupsEvent extends GroupsEvent {}
