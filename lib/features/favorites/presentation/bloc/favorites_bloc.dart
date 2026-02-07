import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/favorites/domain/usecases/add_favorite_ensemble_usecase.dart';
import 'package:app/features/favorites/domain/usecases/add_favorite_usecase.dart';
import 'package:app/features/favorites/domain/usecases/get_favorite_artists_usecase.dart';
import 'package:app/features/favorites/domain/usecases/get_favorite_ensembles_usecase.dart';
import 'package:app/features/favorites/domain/usecases/remove_favorite_ensemble_usecase.dart';
import 'package:app/features/favorites/domain/usecases/remove_favorite_usecase.dart';
import 'package:app/features/favorites/presentation/bloc/events/favorites_events.dart';
import 'package:app/features/favorites/presentation/bloc/states/favorites_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado da feature Favorites (artistas e conjuntos).
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetUserUidUseCase getUserUidUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  final GetFavoriteArtistsUseCase getFavoriteArtistsUseCase;
  final AddFavoriteEnsembleUseCase addFavoriteEnsembleUseCase;
  final RemoveFavoriteEnsembleUseCase removeFavoriteEnsembleUseCase;
  final GetFavoriteEnsemblesUseCase getFavoriteEnsemblesUseCase;

  FavoritesBloc({
    required this.getUserUidUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.getFavoriteArtistsUseCase,
    required this.addFavoriteEnsembleUseCase,
    required this.removeFavoriteEnsembleUseCase,
    required this.getFavoriteEnsemblesUseCase,
  }) : super(FavoritesInitial()) {
    on<AddFavoriteEvent>(_onAddFavoriteEvent);
    on<RemoveFavoriteEvent>(_onRemoveFavoriteEvent);
    on<GetFavoriteArtistsEvent>(_onGetFavoriteArtistsEvent);
    on<AddFavoriteEnsembleEvent>(_onAddFavoriteEnsembleEvent);
    on<RemoveFavoriteEnsembleEvent>(_onRemoveFavoriteEnsembleEvent);
    on<GetFavoriteEnsemblesEvent>(_onGetFavoriteEnsemblesEvent);
    on<ResetFavoritesEvent>(_onResetFavoritesEvent);
  }

  // ==================== HELPERS ====================

  /// Obtém o UID do cliente atual
  Future<String?> _getCurrentClientId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== ADD FAVORITE ====================

  Future<void> _onAddFavoriteEvent(
    AddFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(AddFavoriteLoading());

    // Obter clientId do usuário atual
    final clientId = await _getCurrentClientId();

    if (clientId == null || clientId.isEmpty) {
      emit(AddFavoriteFailure(
        error: 'Usuário não autenticado',
      ));
      emit(FavoritesInitial());
      return;
    }

    // Adicionar aos favoritos
    final result = await addFavoriteUseCase.call(
      clientId: clientId,
      artistId: event.artistId,
    );

    result.fold(
      (failure) {
        emit(AddFavoriteFailure(error: failure.message));
        emit(FavoritesInitial());
      },
      (_) {
        emit(AddFavoriteSuccess());
        emit(FavoritesInitial());
      },
    );
  }

  // ==================== REMOVE FAVORITE ====================

  Future<void> _onRemoveFavoriteEvent(
    RemoveFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(RemoveFavoriteLoading());

    // Obter clientId do usuário atual
    final clientId = await _getCurrentClientId();

    if (clientId == null || clientId.isEmpty) {
      emit(RemoveFavoriteFailure(
        error: 'Usuário não autenticado',
      ));
      emit(FavoritesInitial());
      return;
    }

    // Remover dos favoritos
    final result = await removeFavoriteUseCase.call(
      clientId: clientId,
      artistId: event.artistId,
    );

    result.fold(
      (failure) {
        emit(RemoveFavoriteFailure(error: failure.message));
        emit(FavoritesInitial());
      },
      (_) {
        emit(RemoveFavoriteSuccess());
        emit(FavoritesInitial());
      },
    );
  }

  // ==================== GET FAVORITE ARTISTS ====================

  Future<void> _onGetFavoriteArtistsEvent(
    GetFavoriteArtistsEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(GetFavoriteArtistsLoading());

    final clientId = await _getCurrentClientId();

    if (clientId == null || clientId.isEmpty) {
      emit(GetFavoriteArtistsFailure(error: 'Usuário não autenticado'));
      emit(FavoritesInitial());
      return;
    }

    final result = await getFavoriteArtistsUseCase.call(clientId, forceRefresh: false);

    result.fold(
      (failure) {
        emit(GetFavoriteArtistsFailure(error: failure.message));
        emit(FavoritesInitial());
      },
      (artists) {
        emit(GetFavoriteArtistsSuccess(artists: artists));
      },
    );
  }

  // ==================== ENSEMBLE FAVORITES ====================

  Future<void> _onAddFavoriteEnsembleEvent(
    AddFavoriteEnsembleEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(AddFavoriteLoading());
    final clientId = await _getCurrentClientId();
    if (clientId == null || clientId.isEmpty) {
      emit(AddFavoriteFailure(error: 'Usuário não autenticado'));
      emit(FavoritesInitial());
      return;
    }
    final result = await addFavoriteEnsembleUseCase.call(
      clientId: clientId,
      ensembleId: event.ensembleId,
    );
    result.fold(
      (failure) {
        emit(AddFavoriteFailure(error: failure.message));
        emit(FavoritesInitial());
      },
      (_) {
        emit(AddFavoriteSuccess());
        emit(FavoritesInitial());
      },
    );
  }

  Future<void> _onRemoveFavoriteEnsembleEvent(
    RemoveFavoriteEnsembleEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(RemoveFavoriteLoading());
    final clientId = await _getCurrentClientId();
    if (clientId == null || clientId.isEmpty) {
      emit(RemoveFavoriteFailure(error: 'Usuário não autenticado'));
      emit(FavoritesInitial());
      return;
    }
    final result = await removeFavoriteEnsembleUseCase.call(
      clientId: clientId,
      ensembleId: event.ensembleId,
    );
    result.fold(
      (failure) {
        emit(RemoveFavoriteFailure(error: failure.message));
        emit(FavoritesInitial());
      },
      (_) {
        emit(RemoveFavoriteEnsembleSuccess());
        emit(FavoritesInitial());
      },
    );
  }

  Future<void> _onGetFavoriteEnsemblesEvent(
    GetFavoriteEnsemblesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(GetFavoriteEnsemblesLoading());
    final clientId = await _getCurrentClientId();
    if (clientId == null || clientId.isEmpty) {
      emit(GetFavoriteEnsemblesFailure(error: 'Usuário não autenticado'));
      emit(FavoritesInitial());
      return;
    }
    final result = await getFavoriteEnsemblesUseCase.call(
      clientId,
      forceRefresh: false,
    );
    result.fold(
      (failure) {
        emit(GetFavoriteEnsemblesFailure(error: failure.message));
        emit(FavoritesInitial());
      },
      (ensembles) {
        emit(GetFavoriteEnsemblesSuccess(ensembles: ensembles));
      },
    );
  }

  // ==================== RESET ====================

  Future<void> _onResetFavoritesEvent(
    ResetFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesInitial());
  }
}

