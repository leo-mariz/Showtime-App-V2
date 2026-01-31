import 'package:app/features/ensemble/ensemble/domain/usecases/create_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/delete_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_all_ensembles_by_artist_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_by_id_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnsembleBloc extends Bloc<EnsembleEvent, EnsembleState> {
  final GetAllEnsemblesByArtistUseCase getAllEnsemblesByArtistUseCase;
  final GetEnsembleByIdUseCase getEnsembleByIdUseCase;
  final CreateEnsembleUseCase createEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;
  final DeleteEnsembleUseCase deleteEnsembleUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  EnsembleBloc({
    required this.getAllEnsemblesByArtistUseCase,
    required this.getEnsembleByIdUseCase,
    required this.createEnsembleUseCase,
    required this.updateEnsembleUseCase,
    required this.deleteEnsembleUseCase,
    required this.getUserUidUseCase,
  }) : super(EnsembleInitial()) {
    on<GetAllEnsemblesByArtistEvent>(_onGetAllEnsemblesByArtist);
    on<GetEnsembleByIdEvent>(_onGetEnsembleById);
    on<CreateEnsembleEvent>(_onCreateEnsemble);
    on<UpdateEnsembleEvent>(_onUpdateEnsemble);
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
    final result = await getAllEnsemblesByArtistUseCase.call(
      artistId,
      forceRemote: event.forceRemote,
    );
    result.fold(
      (failure) {
        emit(GetAllEnsemblesFailure(error: failure.message));
        emit(EnsembleInitial());
      },
      (ensembles) {
        emit(GetAllEnsemblesSuccess(ensembles: ensembles));
        // Mantém o estado com a lista para a UI exibir sem precisar de estado local
      },
    );
  }

  Future<void> _onGetEnsembleById(
    GetEnsembleByIdEvent event,
    Emitter<EnsembleState> emit,
  ) async {
    emit(GetEnsembleByIdLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetEnsembleByIdFailure(error: 'Usuário não autenticado'));
      emit(EnsembleInitial());
      return;
    }
    final result = await getEnsembleByIdUseCase.call(artistId, event.ensembleId);
    result.fold(
      (failure) {
        emit(GetEnsembleByIdFailure(error: failure.message));
        emit(EnsembleInitial());
      },
      (ensemble) {
        emit(GetEnsembleByIdSuccess(ensemble: ensemble));
        emit(EnsembleInitial());
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
    final result = await createEnsembleUseCase.call(artistId, event.input);
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
    emit(UpdateEnsembleLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(UpdateEnsembleFailure(error: 'Usuário não autenticado'));
      emit(EnsembleInitial());
      return;
    }
    final result = await updateEnsembleUseCase.call(artistId, event.ensemble);
    result.fold(
      (failure) {
        emit(UpdateEnsembleFailure(error: failure.message));
        emit(EnsembleInitial());
      },
      (_) {
        emit(UpdateEnsembleSuccess(ensemble: event.ensemble));
        emit(EnsembleInitial());
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
