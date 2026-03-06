import 'dart:developer' as dev;

import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/create_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/delete_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_all_ensembles_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_member_talents_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_members_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_presentation_video_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_professional_info_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_profile_photo_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/check_ensemble_name_exists_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_active_status_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_name_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnsembleBloc extends Bloc<EnsembleEvent, EnsembleState> {
  final GetAllEnsemblesUseCase getAllEnsemblesUseCase;
  final GetEnsembleUseCase getEnsembleUseCase;
  final CreateEnsembleUseCase createEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;
  final UpdateEnsembleProfilePhotoUseCase updateEnsembleProfilePhotoUseCase;
  final UpdateEnsemblePresentationVideoUseCase
      updateEnsemblePresentationVideoUseCase;
  final UpdateEnsembleProfessionalInfoUseCase
      updateEnsembleProfessionalInfoUseCase;
  final UpdateEnsembleMembersUseCase updateEnsembleMembersUseCase;
  final UpdateEnsembleMemberTalentsUseCase updateEnsembleMemberTalentsUseCase;
  final UpdateEnsembleActiveStatusUseCase updateEnsembleActiveStatusUseCase;
  final UpdateEnsembleNameUseCase updateEnsembleNameUseCase;
  final CheckEnsembleNameExistsUseCase checkEnsembleNameExistsUseCase;
  final DeleteEnsembleUseCase deleteEnsembleUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  EnsembleBloc({
    required this.getAllEnsemblesUseCase,
    required this.getEnsembleUseCase,
    required this.createEnsembleUseCase,
    required this.updateEnsembleUseCase,
    required this.updateEnsembleProfilePhotoUseCase,
    required this.updateEnsemblePresentationVideoUseCase,
    required this.updateEnsembleProfessionalInfoUseCase,
    required this.updateEnsembleMembersUseCase,
    required this.updateEnsembleMemberTalentsUseCase,
    required this.updateEnsembleActiveStatusUseCase,
    required this.updateEnsembleNameUseCase,
    required this.checkEnsembleNameExistsUseCase,
    required this.deleteEnsembleUseCase,
    required this.getUserUidUseCase,
  }) : super(EnsembleInitial()) {
    on<GetAllEnsemblesByArtistEvent>(_onGetAllEnsemblesByArtist);
    on<GetEnsembleByIdEvent>(_onGetEnsembleById);
    on<CreateEnsembleEvent>(_onCreateEnsemble);
    on<UpdateEnsembleEvent>(_onUpdateEnsemble);
    on<UpdateEnsembleProfessionalInfoEvent>(_onUpdateEnsembleProfessionalInfo);
    on<UpdateEnsembleMembersEvent>(_onUpdateEnsembleMembers);
    on<UpdateEnsembleProfilePhotoEvent>(_onUpdateEnsembleProfilePhoto);
    on<UpdateEnsemblePresentationVideoEvent>(
        _onUpdateEnsemblePresentationVideo);
    on<UpdateEnsembleMemberTalentsEvent>(_onUpdateEnsembleMemberTalents);
    on<UpdateEnsembleActiveStatusEvent>(_onUpdateEnsembleActiveStatus);
    on<CheckEnsembleNameExistsEvent>(_onCheckEnsembleNameExists);
    on<UpdateEnsembleNameEvent>(_onUpdateEnsembleName);
    on<DeleteEnsembleEvent>(_onDeleteEnsemble);
    on<ResetEnsembleEvent>(_onResetEnsemble);
  }

  Future<String?> _getCurrentArtistId() async {
    final result = await getUserUidUseCase.call();
    return result.fold((_) => null, (uid) => uid);
  }

  /// Restaura o estado da lista de conjuntos (ex.: após falha ou artistId nulo).
  void _restoreEnsemblesState(
    Emitter<EnsembleState> emit,
    GetAllEnsemblesSuccess? previousSuccess,
    List<EnsembleEntity> previousList,
  ) {
    if (previousList.isNotEmpty) {
      emit(GetAllEnsemblesSuccess(
        ensembles: previousList,
        currentEnsemble: previousSuccess?.currentEnsemble,
      ));
    } else {
      emit(EnsembleInitial());
    }
  }

  /// Retorna lista e currentEnsemble atualizados após substituir um item por [updatedEnsemble], ou null se [previousList] for vazio.
  (List<EnsembleEntity> updatedList, EnsembleEntity? newCurrent)? _computeEnsemblesWithUpdated(
    GetAllEnsemblesSuccess? previousSuccess,
    List<EnsembleEntity> previousList,
    EnsembleEntity updatedEnsemble,
  ) {
    if (previousList.isEmpty) return null;
    final updatedList = previousList
        .map((e) => e.id == updatedEnsemble.id ? updatedEnsemble : e)
        .toList();
    final newCurrent = previousSuccess?.currentEnsemble?.id == updatedEnsemble.id
        ? updatedEnsemble
        : previousSuccess?.currentEnsemble;
    return (updatedList, newCurrent);
  }

  /// Emite estado com a lista de conjuntos atualizada (um item substituído pelo [updatedEnsemble]).
  /// Se [previousList] for vazio mas o [currentEnsemble] era o que foi atualizado, emite estado
  /// mantendo apenas [currentEnsemble] atualizado (ensembles vazio) para a área mostrar o novo nome;
  /// a tela de lista ao voltar verá ensembles vazio e fará refetch.
  void _emitEnsemblesWithUpdated(
    Emitter<EnsembleState> emit,
    GetAllEnsemblesSuccess? previousSuccess,
    List<EnsembleEntity> previousList,
    EnsembleEntity updatedEnsemble,
  ) {
    dev.log(
      '_emitEnsemblesWithUpdated: previousList.length=${previousList.length}, '
      'updatedId=${updatedEnsemble.id}, currentId=${previousSuccess?.currentEnsemble?.id}',
      name: 'EnsembleBloc',
    );
    final applied = _computeEnsemblesWithUpdated(previousSuccess, previousList, updatedEnsemble);
    if (applied != null) {
      dev.log(
        'emit GetAllEnsemblesSuccess(ensembles: ${applied.$1.length}, currentEnsemble: ${applied.$2?.id})',
        name: 'EnsembleBloc',
      );
      emit(GetAllEnsemblesSuccess(ensembles: applied.$1, currentEnsemble: applied.$2));
    } else if (previousSuccess?.currentEnsemble?.id == updatedEnsemble.id) {
      dev.log('emit GetAllEnsemblesSuccess(ensembles: 0, currentEnsemble: ${updatedEnsemble.id}) [branch vazio]', name: 'EnsembleBloc');
      emit(GetAllEnsemblesSuccess(ensembles: [], currentEnsemble: updatedEnsemble));
    } else {
      dev.log('emit EnsembleInitial()', name: 'EnsembleBloc');
      emit(EnsembleInitial());
    }
  }

  Future<void> _onGetAllEnsemblesByArtist(
    GetAllEnsemblesByArtistEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    dev.log('GetAllEnsemblesByArtistEvent(forceRemote: ${event.forceRemote}) -> emit Loading', name: 'EnsembleBloc');
    emit(GetAllEnsemblesLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetAllEnsemblesFailure(error: 'Usuário não autenticado'));
      emit(EnsembleInitial());
      return;
    }
    final result = await getAllEnsemblesUseCase.call(
      artistId,
      forceRemote: event.forceRemote,
    );
    result.fold(
      (failure) {
        dev.log('GetAllEnsemblesByArtist FAIL: ${failure.message}', name: 'EnsembleBloc');
        emit(GetAllEnsemblesFailure(error: failure.message));
        emit(EnsembleInitial());
      },
      (ensembles) {
        dev.log('GetAllEnsemblesByArtist SUCCESS: ensembles.length=${ensembles.length}', name: 'EnsembleBloc');
        emit(GetAllEnsemblesSuccess(ensembles: ensembles, currentEnsemble: null));
      },
    );
  }

  Future<void> _onGetEnsembleById(
    GetEnsembleByIdEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final success = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    final list = success?.ensembles ?? <EnsembleEntity>[];
    dev.log(
      'GetEnsembleByIdEvent(ensembleId=${event.ensembleId}, forceRefresh=${event.forceRefresh}) '
      'state=${state.runtimeType} success.ensembles.length=${list.length} currentId=${success?.currentEnsemble?.id}',
      name: 'EnsembleBloc',
    );
    if (!event.forceRefresh &&
        success != null &&
        success.currentEnsemble?.id == event.ensembleId) {
      dev.log('GetEnsembleById early return (já tem current)', name: 'EnsembleBloc');
      return;
    }
    dev.log('GetEnsembleById emit(ensembles: ${list.length}, currentEnsemble: null) e depois fetch', name: 'EnsembleBloc');
    emit(GetAllEnsemblesSuccess(ensembles: list, currentEnsemble: null));
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetEnsembleByIdFailure(error: 'Usuário não autenticado'));
      return;
    }
    final result = await getEnsembleUseCase.call(artistId, event.ensembleId);
    result.fold(
      (failure) {
        dev.log('GetEnsembleById fetch FAIL: ${failure.message}', name: 'EnsembleBloc');
        emit(GetEnsembleByIdFailure(error: failure.message));
      },
      (ensemble) {
        dev.log('GetEnsembleById fetch SUCCESS: emit(ensembles: ${list.length}, currentEnsemble: ${ensemble?.id})', name: 'EnsembleBloc');
        emit(GetAllEnsemblesSuccess(ensembles: list, currentEnsemble: ensemble));
      },
    );
  }

  Future<void> _onCreateEnsemble(
    CreateEnsembleEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    emit(CreateEnsembleLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(CreateEnsembleFailure(error: 'Usuário não autenticado'));
      emit(EnsembleInitial());
      return;
    }
    final result = await createEnsembleUseCase.call(artistId, event.members);
    result.fold(
      (failure) {
        emit(CreateEnsembleFailure(error: failure.message));
        emit(EnsembleInitial());
      },
      (ensemble) {
        emit(CreateEnsembleSuccess(ensemble: ensemble));
        emit(EnsembleInitial());
      },
    );
  }

  Future<void> _onUpdateEnsemble(
    UpdateEnsembleEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final previousSuccess = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    final previousList = previousSuccess?.ensembles ?? <EnsembleEntity>[];

    emit(UpdateEnsembleLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateEnsembleFailure(error: 'Usuário não autenticado'));
      _restoreEnsemblesState(emit, previousSuccess, previousList);
      return;
    }
    final ensembleId = event.ensemble.id;
    final useMembersUseCase = ensembleId != null && ensembleId.isNotEmpty && event.ensemble.members != null;
    if (useMembersUseCase) {
      final result = await updateEnsembleMembersUseCase.call(
        artistId,
        ensembleId,
        event.ensemble.members!,
      );
      result.fold(
        (failure) {
          emit(UpdateEnsembleFailure(error: failure.message));
          _restoreEnsemblesState(emit, previousSuccess, previousList);
        },
        (updatedEnsemble) {
          emit(UpdateEnsembleSuccess(ensemble: updatedEnsemble));
          _emitEnsemblesWithUpdated(emit, previousSuccess, previousList, updatedEnsemble);
        },
      );
    } else {
      final result = await updateEnsembleUseCase.call(artistId, event.ensemble);
      result.fold(
        (failure) {
          emit(UpdateEnsembleFailure(error: failure.message));
          _restoreEnsemblesState(emit, previousSuccess, previousList);
        },
        (_) {
          emit(UpdateEnsembleSuccess(ensemble: event.ensemble));
          _emitEnsemblesWithUpdated(emit, previousSuccess, previousList, event.ensemble);
        },
      );
    }
  }

  Future<void> _onUpdateEnsembleProfessionalInfo(
    UpdateEnsembleProfessionalInfoEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final previousSuccess = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    final previousList = previousSuccess?.ensembles ?? <EnsembleEntity>[];

    emit(UpdateEnsembleProfessionalInfoLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateEnsembleProfessionalInfoFailure(error: 'Usuário não autenticado'));
      _restoreEnsemblesState(emit, previousSuccess, previousList);
      return;
    }

    final result = await updateEnsembleProfessionalInfoUseCase.call(
      artistId,
      event.ensembleId,
      event.professionalInfo,
    );

    result.fold(
      (failure) {
        emit(UpdateEnsembleProfessionalInfoFailure(error: failure.message));
        _restoreEnsemblesState(emit, previousSuccess, previousList);
      },
      (updatedEnsemble) {
        emit(UpdateEnsembleProfessionalInfoSuccess(ensemble: updatedEnsemble));
        _emitEnsemblesWithUpdated(emit, previousSuccess, previousList, updatedEnsemble);
      },
    );
  }

  Future<void> _onUpdateEnsembleMembers(
    UpdateEnsembleMembersEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final previousSuccess = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    final previousList = previousSuccess?.ensembles ?? <EnsembleEntity>[];

    emit(UpdateEnsembleMembersLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateEnsembleMembersFailure(error: 'Usuário não autenticado'));
      _restoreEnsemblesState(emit, previousSuccess, previousList);
      return;
    }

    final result = await updateEnsembleMembersUseCase.call(
      artistId,
      event.ensembleId,
      event.members,
    );

    result.fold(
      (failure) {
        emit(UpdateEnsembleMembersFailure(error: failure.message));
        _restoreEnsemblesState(emit, previousSuccess, previousList);
      },
      (updatedEnsemble) {
        final applied = _computeEnsemblesWithUpdated(previousSuccess, previousList, updatedEnsemble);
        if (applied != null) {
          emit(UpdateEnsembleMembersSuccess(
            ensembles: applied.$1,
            currentEnsemble: applied.$2,
          ));
        } else {
          emit(EnsembleInitial());
        }
      },
    );
  }

  Future<void> _onUpdateEnsembleProfilePhoto(
    UpdateEnsembleProfilePhotoEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final previousSuccess = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    final previousList = previousSuccess?.ensembles ?? <EnsembleEntity>[];

    emit(UpdateEnsembleProfilePhotoLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateEnsembleProfilePhotoFailure(error: 'Usuário não autenticado'));
      _restoreEnsemblesState(emit, previousSuccess, previousList);
      return;
    }
    final result = await updateEnsembleProfilePhotoUseCase.call(
      artistId,
      event.ensembleId,
      event.localFilePath,
    );
    result.fold(
      (failure) {
        emit(UpdateEnsembleProfilePhotoFailure(error: failure.message));
        _restoreEnsemblesState(emit, previousSuccess, previousList);
      },
      (updatedEnsemble) {
        emit(UpdateEnsembleProfilePhotoSuccess(ensemble: updatedEnsemble));
        _emitEnsemblesWithUpdated(emit, previousSuccess, previousList, updatedEnsemble);
      },
    );
  }

  Future<void> _onUpdateEnsemblePresentationVideo(
    UpdateEnsemblePresentationVideoEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final previousSuccess = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    final previousList = previousSuccess?.ensembles ?? <EnsembleEntity>[];

    emit(UpdateEnsemblePresentationVideoLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateEnsemblePresentationVideoFailure(
          error: 'Usuário não autenticado'));
      _restoreEnsemblesState(emit, previousSuccess, previousList);
      return;
    }
    final result = await updateEnsemblePresentationVideoUseCase.call(
      artistId,
      event.ensembleId,
      event.localFilePath,
    );
    result.fold(
      (failure) {
        emit(UpdateEnsemblePresentationVideoFailure(error: failure.message));
        _restoreEnsemblesState(emit, previousSuccess, previousList);
      },
      (updatedEnsemble) {
        emit(UpdateEnsemblePresentationVideoSuccess(ensemble: updatedEnsemble));
        _emitEnsemblesWithUpdated(emit, previousSuccess, previousList, updatedEnsemble);
      },
    );
  }

  Future<void> _onUpdateEnsembleMemberTalents(
    UpdateEnsembleMemberTalentsEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final previousSuccess = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    final previousList = previousSuccess?.ensembles ?? <EnsembleEntity>[];

    emit(UpdateEnsembleMemberTalentsLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateEnsembleMemberTalentsFailure(
          error: 'Usuário não autenticado'));
      _restoreEnsemblesState(emit, previousSuccess, previousList);
      return;
    }
    final result = await updateEnsembleMemberTalentsUseCase.call(
      artistId,
      event.ensembleId,
      event.memberId,
      event.talents,
    );
    result.fold(
      (failure) {
        emit(UpdateEnsembleMemberTalentsFailure(error: failure.message));
        _restoreEnsemblesState(emit, previousSuccess, previousList);
      },
      (updatedEnsemble) {
        emit(UpdateEnsembleMemberTalentsSuccess(ensemble: updatedEnsemble));
        _emitEnsemblesWithUpdated(emit, previousSuccess, previousList, updatedEnsemble);
      },
    );
  }

  Future<void> _onUpdateEnsembleActiveStatus(
    UpdateEnsembleActiveStatusEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final previousSuccess = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    final previousList = previousSuccess?.ensembles ?? <EnsembleEntity>[];

    emit(UpdateEnsembleActiveStatusLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateEnsembleActiveStatusFailure(error: 'Usuário não autenticado'));
      _restoreEnsemblesState(emit, previousSuccess, previousList);
      return;
    }

    final result = await updateEnsembleActiveStatusUseCase.call(
      artistId,
      event.ensembleId,
      event.isActive,
    );

    result.fold(
      (failure) {
        emit(UpdateEnsembleActiveStatusFailure(error: failure.message));
        _restoreEnsemblesState(emit, previousSuccess, previousList);
      },
      (updated) {
        emit(UpdateEnsembleActiveStatusSuccess(ensemble: updated));
        _emitEnsemblesWithUpdated(emit, previousSuccess, previousList, updated);
      },
    );
  }

  Future<void> _onCheckEnsembleNameExists(
    CheckEnsembleNameExistsEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    emit(CheckEnsembleNameExistsLoading(ensembleName: event.ensembleName));

    final result = await checkEnsembleNameExistsUseCase.call(
      event.ensembleName,
      excludeEnsembleId: event.excludeEnsembleId,
    );

    result.fold(
      (failure) {
        emit(CheckEnsembleNameExistsFailure(
          ensembleName: event.ensembleName,
          error: failure.message,
        ));
        emit(EnsembleInitial());
      },
      (exists) {
        emit(CheckEnsembleNameExistsSuccess(
          ensembleName: event.ensembleName,
          exists: exists,
        ));
        emit(EnsembleInitial());
      },
    );
  }

  Future<void> _onUpdateEnsembleName(
    UpdateEnsembleNameEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final previousSuccess = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    final previousList = previousSuccess?.ensembles ?? <EnsembleEntity>[];
    dev.log(
      'UpdateEnsembleNameEvent(ensembleId=${event.ensembleId}) state=${state.runtimeType} previousList.length=${previousList.length}',
      name: 'EnsembleBloc',
    );

    emit(UpdateEnsembleNameLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateEnsembleNameFailure(error: 'Usuário não autenticado'));
      _restoreEnsemblesState(emit, previousSuccess, previousList);
      return;
    }

    final result = await updateEnsembleNameUseCase.call(
      artistId,
      event.ensembleId,
      event.ensembleName,
    );

    await result.fold(
      (failure) async {
        emit(UpdateEnsembleNameFailure(error: failure.message));
        _restoreEnsemblesState(emit, previousSuccess, previousList);
      },
      (updatedEnsemble) async {
        dev.log('UpdateEnsembleName SUCCESS: nome=${updatedEnsemble.ensembleName}', name: 'EnsembleBloc');
        emit(UpdateEnsembleNameSuccess(ensemble: updatedEnsemble));
        if (previousList.isEmpty) {
          dev.log('UpdateEnsembleName: previousList vazia (estado perdido) -> refetch e emit com atualizado', name: 'EnsembleBloc');
          final refetchArtistId = await _getCurrentArtistId();
          if (refetchArtistId == null) {
            emit(GetAllEnsemblesSuccess(ensembles: [updatedEnsemble], currentEnsemble: updatedEnsemble));
            return;
          }
          final fetchResult = await getAllEnsemblesUseCase.call(refetchArtistId, forceRemote: false);
          fetchResult.fold(
            (_) {
              dev.log('UpdateEnsembleName: refetch falhou -> emit [updatedEnsemble] apenas', name: 'EnsembleBloc');
              emit(GetAllEnsemblesSuccess(ensembles: [updatedEnsemble], currentEnsemble: updatedEnsemble));
            },
            (list) {
              final merged = list
                  .map((e) => e.id == updatedEnsemble.id ? updatedEnsemble : e)
                  .toList();
              dev.log('UpdateEnsembleName: refetch ok -> emit(ensembles: ${merged.length}, current: ${updatedEnsemble.id})', name: 'EnsembleBloc');
              emit(GetAllEnsemblesSuccess(ensembles: merged, currentEnsemble: updatedEnsemble));
            },
          );
        } else {
          _emitEnsemblesWithUpdated(emit, previousSuccess, previousList, updatedEnsemble);
        }
      },
    );
  }

  Future<void> _onDeleteEnsemble(
    DeleteEnsembleEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    emit(DeleteEnsembleLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(DeleteEnsembleFailure(error: 'Usuário não autenticado'));
      emit(EnsembleInitial());
      return;
    }
    final result = await deleteEnsembleUseCase.call(artistId, event.ensembleId);
    result.fold(
      (failure) {
        emit(DeleteEnsembleFailure(error: failure.message));
        emit(EnsembleInitial());
      },
      (_) {
        emit(DeleteEnsembleSuccess(ensembleId: event.ensembleId));
        emit(EnsembleInitial());
      },
    );
  }

  void _onResetEnsemble(ResetEnsembleEvent event, Emitter<EnsembleState> emit) {
    emit(EnsembleInitial());
  }
}
