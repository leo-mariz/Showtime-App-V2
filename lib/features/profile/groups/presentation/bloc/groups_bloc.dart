import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/groups/domain/usecases/get_groups_usecase.dart';
import 'package:app/features/profile/groups/domain/usecases/get_group_usecase.dart';
import 'package:app/features/profile/groups/domain/usecases/add_group_usecase.dart';
import 'package:app/features/profile/groups/domain/usecases/update_group_usecase.dart';
import 'package:app/features/profile/groups/domain/usecases/delete_group_usecase.dart';
import 'package:app/features/profile/groups/presentation/bloc/events/groups_events.dart';
import 'package:app/features/profile/groups/presentation/bloc/states/groups_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GetGroupsUseCase getGroupsUseCase;
  final GetGroupUseCase getGroupUseCase;
  final AddGroupUseCase addGroupUseCase;
  final UpdateGroupUseCase updateGroupUseCase;
  final DeleteGroupUseCase deleteGroupUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  GroupsBloc({
    required this.getGroupsUseCase,
    required this.getGroupUseCase,
    required this.addGroupUseCase,
    required this.updateGroupUseCase,
    required this.deleteGroupUseCase,
    required this.getUserUidUseCase,
  }) : super(GroupsInitial()) {
    on<GetGroupsEvent>(_onGetGroupsEvent);
    on<GetGroupEvent>(_onGetGroupEvent);
    on<AddGroupEvent>(_onAddGroupEvent);
    on<UpdateGroupEvent>(_onUpdateGroupEvent);
    on<DeleteGroupEvent>(_onDeleteGroupEvent);
    on<UpdateGroupNameEvent>(_onUpdateGroupNameEvent);
    on<UpdateGroupProfilePictureEvent>(_onUpdateGroupProfilePictureEvent);
  }

  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET GROUPS ====================

  Future<void> _onGetGroupsEvent(
    GetGroupsEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GetGroupsLoading());

    final result = await getGroupsUseCase.call();

    result.fold(
      (failure) {
        emit(GetGroupsFailure(error: failure.message));
        emit(GroupsInitial());
      },
      (groups) {
        emit(GetGroupsSuccess(groups: groups));
      },
    );
  }

  // ==================== GET GROUP ====================

  Future<void> _onGetGroupEvent(
    GetGroupEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GetGroupLoading());

    final result = await getGroupUseCase.call(event.groupUid);

    result.fold(
      (failure) {
        emit(GetGroupFailure(error: failure.message));
        emit(GroupsInitial());
      },
      (group) {
        emit(GetGroupSuccess(group: group));
      },
    );
  }

  // ==================== ADD GROUP ====================

  Future<void> _onAddGroupEvent(
    AddGroupEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(AddGroupLoading());

    final uid = await _getCurrentUserId();

    if (uid == null) {
      emit(AddGroupFailure(error: 'Usuário não autenticado'));
      emit(GroupsInitial());
      return;
    }

    final result = await addGroupUseCase.call(uid, event.group);

    result.fold(
      (failure) {
        emit(AddGroupFailure(error: failure.message));
        emit(GroupsInitial());
      },
      (_) {
        emit(AddGroupSuccess(group: event.group));
        emit(GroupsInitial());
      },
    );
  }

  // ==================== UPDATE GROUP ====================

  Future<void> _onUpdateGroupEvent(
    UpdateGroupEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(UpdateGroupLoading());

    final result = await updateGroupUseCase.call(event.groupUid, event.group);

    result.fold(
      (failure) {
        emit(UpdateGroupFailure(error: failure.message));
        emit(GroupsInitial());
      },
      (_) {
        emit(UpdateGroupSuccess());
        emit(GroupsInitial());
      },
    );
  }

  // ==================== DELETE GROUP ====================

  Future<void> _onDeleteGroupEvent(
    DeleteGroupEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(DeleteGroupLoading());

    final result = await deleteGroupUseCase.call(event.groupUid);

    result.fold(
      (failure) {
        emit(DeleteGroupFailure(error: failure.message));
        emit(GroupsInitial());
      },
      (_) {
        emit(DeleteGroupSuccess());
        emit(GroupsInitial());
      },
    );
  }

  // ==================== UPDATE GROUP NAME ====================

  Future<void> _onUpdateGroupNameEvent(
    UpdateGroupNameEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(UpdateGroupNameLoading());

    // Primeiro, buscar o grupo atual
    final getGroupResult = await getGroupUseCase.call(event.groupUid);

    final currentGroup = getGroupResult.fold(
      (failure) => null,
      (group) => group,
    );

    if (currentGroup == null) {
      emit(UpdateGroupNameFailure(error: 'Grupo não encontrado'));
      emit(GroupsInitial());
      return;
    }

    // Atualizar apenas o nome
    final updatedGroup = currentGroup;
    updatedGroup.groupName = event.groupName;

    final result = await updateGroupUseCase.call(event.groupUid, updatedGroup);

    result.fold(
      (failure) {
        emit(UpdateGroupNameFailure(error: failure.message));
        emit(GroupsInitial());
      },
      (_) {
        emit(UpdateGroupNameSuccess());
        emit(GroupsInitial());
      },
    );
  }

  // ==================== UPDATE GROUP PROFILE PICTURE ====================

  Future<void> _onUpdateGroupProfilePictureEvent(
    UpdateGroupProfilePictureEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(UpdateGroupProfilePictureLoading());

    // TODO: Implementar upload da imagem e atualização do grupo
    // Por enquanto, apenas emite erro
    emit(UpdateGroupProfilePictureFailure(error: 'Funcionalidade em desenvolvimento'));
    emit(GroupsInitial());
  }
}

