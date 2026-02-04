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
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_active_status_usecase.dart';
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
    on<DeleteEnsembleEvent>(_onDeleteEnsemble);
    on<ResetEnsembleEvent>(_onResetEnsemble);
  }

  Future<String?> _getCurrentArtistId() async {
    final result = await getUserUidUseCase.call();
    return result.fold((_) => null, (uid) => uid);
  }

  Future<void> _onGetAllEnsemblesByArtist(
    GetAllEnsemblesByArtistEvent event,
    Emitter<EnsembleState> emit,
  ) async {
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
        emit(GetAllEnsemblesFailure(error: failure.message));
        emit(EnsembleInitial());
      },
      (ensembles) {
        emit(GetAllEnsemblesSuccess(ensembles: ensembles, currentEnsemble: null));
      },
    );
  }

  Future<void> _onGetEnsembleById(
    GetEnsembleByIdEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    final success = state is GetAllEnsemblesSuccess ? state as GetAllEnsemblesSuccess : null;
    if (!event.forceRefresh &&
        success != null &&
        success.currentEnsemble?.id == event.ensembleId) {
      return;
    }
    final list = success?.ensembles ?? <EnsembleEntity>[];
    emit(GetAllEnsemblesSuccess(ensembles: list, currentEnsemble: null));
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetEnsembleByIdFailure(error: 'Usuário não autenticado'));
      return;
    }
    final result = await getEnsembleUseCase.call(artistId, event.ensembleId);
    result.fold(
      (failure) {
        emit(GetEnsembleByIdFailure(error: failure.message));
      },
      (ensemble) {
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
      if (previousList.isNotEmpty) {
        emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
      } else {
        emit(EnsembleInitial());
      }
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
          if (previousList.isNotEmpty) {
            emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
          } else {
            emit(EnsembleInitial());
          }
        },
        (updatedEnsemble) {
          emit(UpdateEnsembleSuccess(ensemble: updatedEnsemble));
          if (previousList.isNotEmpty) {
            final updatedList = previousList.map((e) => e.id == updatedEnsemble.id ? updatedEnsemble : e).toList();
            final isCurrentEnsemble = previousSuccess?.currentEnsemble?.id == updatedEnsemble.id;
            emit(GetAllEnsemblesSuccess(
              ensembles: updatedList,
              currentEnsemble: isCurrentEnsemble ? updatedEnsemble : previousSuccess?.currentEnsemble,
            ));
          } else {
            emit(EnsembleInitial());
          }
        },
      );
    } else {
      final result = await updateEnsembleUseCase.call(artistId, event.ensemble);
      result.fold(
        (failure) {
          emit(UpdateEnsembleFailure(error: failure.message));
          if (previousList.isNotEmpty) {
            emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
          } else {
            emit(EnsembleInitial());
          }
        },
        (_) {
          emit(UpdateEnsembleSuccess(ensemble: event.ensemble));
          if (previousList.isNotEmpty) {
            final updatedList = previousList
                .map((e) => e.id == event.ensemble.id ? event.ensemble : e)
                .toList();
            final isCurrentEnsemble = previousSuccess?.currentEnsemble?.id == event.ensemble.id;
            emit(GetAllEnsemblesSuccess(
              ensembles: updatedList,
              currentEnsemble: isCurrentEnsemble ? event.ensemble : previousSuccess?.currentEnsemble,
            ));
          } else {
            emit(EnsembleInitial());
          }
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
      if (previousList.isNotEmpty) {
        emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
      } else {
        emit(EnsembleInitial());
      }
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
        if (previousList.isNotEmpty) {
          emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
        } else {
          emit(EnsembleInitial());
        }
      },
      (updatedEnsemble) {
        emit(UpdateEnsembleProfessionalInfoSuccess(ensemble: updatedEnsemble));
        if (previousList.isNotEmpty) {
          final updatedList = previousList.map((e) => e.id == updatedEnsemble.id ? updatedEnsemble : e).toList();
          final newCurrent = previousSuccess?.currentEnsemble?.id == updatedEnsemble.id
              ? updatedEnsemble
              : previousSuccess?.currentEnsemble;
          emit(GetAllEnsemblesSuccess(ensembles: updatedList, currentEnsemble: newCurrent));
        } else {
          emit(EnsembleInitial());
        }
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
      if (previousList.isNotEmpty) {
        emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
      } else {
        emit(EnsembleInitial());
      }
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
        if (previousList.isNotEmpty) {
          emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
        } else {
          emit(EnsembleInitial());
        }
      },
      (updatedEnsemble) {
        if (previousList.isNotEmpty) {
          final updatedList = previousList.map((e) => e.id == updatedEnsemble.id ? updatedEnsemble : e).toList();
          final newCurrent = previousSuccess?.currentEnsemble?.id == updatedEnsemble.id
              ? updatedEnsemble
              : previousSuccess?.currentEnsemble;
          emit(UpdateEnsembleMembersSuccess(
            ensembles: updatedList,
            currentEnsemble: newCurrent,
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
      if (previousList.isNotEmpty) {
        emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
      } else {
        emit(EnsembleInitial());
      }
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
        if (previousList.isNotEmpty) {
          emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
        } else {
          emit(EnsembleInitial());
        }
      },
      (updatedEnsemble) {
        emit(UpdateEnsembleProfilePhotoSuccess(ensemble: updatedEnsemble));
        if (previousList.isNotEmpty) {
          final updatedList = previousList.map((e) => e.id == updatedEnsemble.id ? updatedEnsemble : e).toList();
          final newCurrent = previousSuccess?.currentEnsemble?.id == updatedEnsemble.id
              ? updatedEnsemble
              : previousSuccess?.currentEnsemble;
          emit(GetAllEnsemblesSuccess(ensembles: updatedList, currentEnsemble: newCurrent));
        } else {
          emit(EnsembleInitial());
        }
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
      if (previousList.isNotEmpty) {
        emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
      } else {
        emit(EnsembleInitial());
      }
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
        if (previousList.isNotEmpty) {
          emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
        } else {
          emit(EnsembleInitial());
        }
      },
      (updatedEnsemble) {
        emit(UpdateEnsemblePresentationVideoSuccess(ensemble: updatedEnsemble));
        if (previousList.isNotEmpty) {
          final updatedList = previousList.map((e) => e.id == updatedEnsemble.id ? updatedEnsemble : e).toList();
          final newCurrent = previousSuccess?.currentEnsemble?.id == updatedEnsemble.id
              ? updatedEnsemble
              : previousSuccess?.currentEnsemble;
          emit(GetAllEnsemblesSuccess(ensembles: updatedList, currentEnsemble: newCurrent));
        } else {
          emit(EnsembleInitial());
        }
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
      if (previousList.isNotEmpty) {
        emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
      } else {
        emit(EnsembleInitial());
      }
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
        if (previousList.isNotEmpty) {
          emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
        } else {
          emit(EnsembleInitial());
        }
      },
      (updatedEnsemble) {
        emit(UpdateEnsembleMemberTalentsSuccess(ensemble: updatedEnsemble));
        if (previousList.isNotEmpty) {
          final updatedList = previousList.map((e) => e.id == updatedEnsemble.id ? updatedEnsemble : e).toList();
          final newCurrent = previousSuccess?.currentEnsemble?.id == updatedEnsemble.id
              ? updatedEnsemble
              : previousSuccess?.currentEnsemble;
          emit(GetAllEnsemblesSuccess(ensembles: updatedList, currentEnsemble: newCurrent));
        } else {
          emit(EnsembleInitial());
        }
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
      if (previousList.isNotEmpty) {
        emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
      } else {
        emit(EnsembleInitial());
      }
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
        if (previousList.isNotEmpty) {
          emit(GetAllEnsemblesSuccess(ensembles: previousList, currentEnsemble: previousSuccess?.currentEnsemble));
        } else {
          emit(EnsembleInitial());
        }
      },
      (updated) {
        emit(UpdateEnsembleActiveStatusSuccess(ensemble: updated));
        if (previousList.isNotEmpty) {
          final updatedList = previousList
              .map((e) => e.id == event.ensembleId ? updated : e)
              .toList();
          final isCurrent = previousSuccess?.currentEnsemble?.id == event.ensembleId;
          emit(GetAllEnsemblesSuccess(
            ensembles: updatedList,
            currentEnsemble: isCurrent ? updated : previousSuccess?.currentEnsemble,
          ));
        } else {
          emit(EnsembleInitial());
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
