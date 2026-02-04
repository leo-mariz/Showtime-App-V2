import 'package:app/features/ensemble/members/domain/usecases/create_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/delete_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_all_members_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/update_member_usecase.dart';
import 'package:app/features/ensemble/members/presentation/bloc/events/members_events.dart';
import 'package:app/features/ensemble/members/presentation/bloc/states/members_states.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MembersBloc extends Bloc<MembersEvent, MembersState> {
  final GetAllMembersUseCase getAllMembersUseCase;
  final GetMemberUseCase getMemberUseCase;
  final CreateMemberUseCase createMemberUseCase;
  final UpdateMemberUseCase updateMemberUseCase;
  final DeleteMemberUseCase deleteMemberUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  MembersBloc({
    required this.getAllMembersUseCase,
    required this.getMemberUseCase,
    required this.createMemberUseCase,
    required this.updateMemberUseCase,
    required this.deleteMemberUseCase,
    required this.getUserUidUseCase,
  }) : super(MembersInitial()) {
    on<GetAllMembersEvent>(_onGetAllMembers);
    on<GetMemberByIdEvent>(_onGetMemberById);
    on<CreateMemberEvent>(_onCreateMember);
    on<UpdateMemberEvent>(_onUpdateMember);
    on<DeleteMemberEvent>(_onDeleteMember);
    on<ResetMembersEvent>(_onResetMembers);
  }

  Future<void> _onGetAllMembers(
    GetAllMembersEvent event,
    Emitter<MembersState> emit,
  ) async {
    emit(GetAllMembersLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetAllMembersFailure(error: 'Usuário não autenticado'));
      emit(MembersInitial());
      return;
    }
    final result = await getAllMembersUseCase.call(
      artistId,
      forceRemote: event.forceRemote,
    );
    result.fold(
      (failure) {
        emit(GetAllMembersFailure(error: failure.message));
        emit(MembersInitial());
      },
      (members) => emit(GetAllMembersSuccess(members: members)),
    );
  }

  Future<String?> _getCurrentArtistId() async {
    final result = await getUserUidUseCase.call();
    return result.fold((_) => null, (uid) => uid);
  }


  Future<void> _onGetMemberById(
    GetMemberByIdEvent event,
    Emitter<MembersState> emit,
  ) async {
    emit(GetMemberByIdLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetMemberByIdFailure(error: 'Usuário não autenticado'));
      emit(MembersInitial());
      return;
    }
    final result = await getMemberUseCase.call(
      artistId,
      event.memberId,
    );
    result.fold(
      (failure) {
        emit(GetMemberByIdFailure(error: failure.message));
        emit(MembersInitial());
      },
      (member) {
        emit(GetMemberByIdSuccess(member: member));
        emit(MembersInitial());
      },
    );
  }

  Future<void> _onCreateMember(
    CreateMemberEvent event,
    Emitter<MembersState> emit,
  ) async {
    emit(CreateMemberLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(CreateMemberFailure(error: 'Usuário não autenticado'));
      emit(MembersInitial());
      return;
    }
    final result = await createMemberUseCase.call(
      artistId: artistId,
      member: event.member,
    );
    result.fold(
      (failure) {
        emit(CreateMemberFailure(error: failure.message));
        emit(MembersInitial());
      },
      (member) {
        emit(CreateMemberSuccess(member: member));
        emit(MembersInitial());
      },
    );
  }

  Future<void> _onUpdateMember(
    UpdateMemberEvent event,
    Emitter<MembersState> emit,
  ) async {
    emit(UpdateMemberLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateMemberFailure(error: 'Usuário não autenticado'));
      emit(MembersInitial());
      return;
    }
    final result = await updateMemberUseCase.call(
      artistId: artistId,
      member: event.member,
    );
    result.fold(
      (failure) {
        emit(UpdateMemberFailure(error: failure.message));
        emit(MembersInitial());
      },
      (_) {
        emit(UpdateMemberSuccess(member: event.member));
        emit(MembersInitial());
      },
    );
  }

  Future<void> _onDeleteMember(
    DeleteMemberEvent event,
    Emitter<MembersState> emit,
  ) async {
    emit(DeleteMemberLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(DeleteMemberFailure(error: 'Usuário não autenticado'));
      emit(MembersInitial());
      return;
    }
    final result = await deleteMemberUseCase.call(
      artistId,
      event.memberId,
    );
    result.fold(
      (failure) {
        emit(DeleteMemberFailure(error: failure.message));
        emit(MembersInitial());
      },
      (_) {
        emit(DeleteMemberSuccess(memberId: event.memberId));
        emit(MembersInitial());
      },
    );
  }

  void _onResetMembers(ResetMembersEvent event, Emitter<MembersState> emit) {
    emit(MembersInitial());
  }
}
