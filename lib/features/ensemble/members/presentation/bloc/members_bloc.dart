import 'package:app/features/ensemble/members/domain/usecases/create_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/delete_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_all_members_by_artist_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_all_members_by_ensemble_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_member_by_id_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/update_member_usecase.dart';
import 'package:app/features/ensemble/members/presentation/bloc/events/members_events.dart';
import 'package:app/features/ensemble/members/presentation/bloc/states/members_states.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MembersBloc extends Bloc<MembersEvent, MembersState> {
  final GetAllMembersByEnsembleUseCase getAllMembersByEnsembleUseCase;
  final GetAllMembersByArtistUseCase getAllMembersByArtistUseCase;
  final GetMemberByIdUseCase getMemberByIdUseCase;
  final CreateMemberUseCase createMemberUseCase;
  final UpdateMemberUseCase updateMemberUseCase;
  final DeleteMemberUseCase deleteMemberUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  MembersBloc({
    required this.getAllMembersByEnsembleUseCase,
    required this.getAllMembersByArtistUseCase,
    required this.getMemberByIdUseCase,
    required this.createMemberUseCase,
    required this.updateMemberUseCase,
    required this.deleteMemberUseCase,
    required this.getUserUidUseCase,
  }) : super(MembersInitial()) {
    on<GetAllMembersByEnsembleEvent>(_onGetAllMembersByEnsemble);
    on<GetAvailableMembersForNewEnsembleEvent>(_onGetAvailableMembersForNewEnsemble);
    on<GetMemberByIdEvent>(_onGetMemberById);
    on<CreateMemberEvent>(_onCreateMember);
    on<UpdateMemberEvent>(_onUpdateMember);
    on<DeleteMemberEvent>(_onDeleteMember);
    on<ResetMembersEvent>(_onResetMembers);
  }

  Future<String?> _getCurrentArtistId() async {
    final result = await getUserUidUseCase.call();
    return result.fold((_) => null, (uid) => uid);
  }

  Future<void> _onGetAllMembersByEnsemble(
    GetAllMembersByEnsembleEvent event,
    Emitter<MembersState> emit,
  ) async {
    emit(GetAllMembersLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetAllMembersFailure(error: 'Usuário não autenticado'));
      emit(MembersInitial());
      return;
    }
    final result = await getAllMembersByEnsembleUseCase.call(
      artistId,
      event.ensembleId,
      forceRemote: event.forceRemote,
    );
    result.fold(
      (failure) {
        emit(GetAllMembersFailure(error: failure.message));
        emit(MembersInitial());
      },
      (members) {
        emit(GetAllMembersSuccess(members: members));
        emit(MembersInitial());
      },
    );
  }

  Future<void> _onGetAvailableMembersForNewEnsemble(
    GetAvailableMembersForNewEnsembleEvent event,
    Emitter<MembersState> emit,
  ) async {
    emit(GetAvailableMembersLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetAvailableMembersFailure(error: 'Usuário não autenticado'));
      emit(MembersInitial());
      return;
    }
    final result = await getAllMembersByArtistUseCase.call(
      artistId,
      forceRemote: event.forceRemote,
    );
    result.fold(
      (failure) {
        emit(GetAvailableMembersFailure(error: failure.message));
        emit(MembersInitial());
      },
      (members) {
        emit(GetAvailableMembersSuccess(members: members));
        // Mantém o estado com a lista para o modal de seleção exibir
      },
    );
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
    final result = await getMemberByIdUseCase.call(
      artistId,
      event.ensembleId,
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
      artistId,
      event.ensembleId,
      event.member,
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
      artistId,
      event.ensembleId,
      event.member,
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
      event.ensembleId,
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
