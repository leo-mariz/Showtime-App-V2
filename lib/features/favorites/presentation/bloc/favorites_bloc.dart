import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/favorites/domain/usecases/add_favorite_usecase.dart';
import 'package:app/features/favorites/domain/usecases/remove_favorite_usecase.dart';
import 'package:app/features/favorites/presentation/bloc/events/favorites_events.dart';
import 'package:app/features/favorites/presentation/bloc/states/favorites_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado da feature Favorites
/// 
/// RESPONSABILIDADES:
/// - Gerenciar operações de adicionar e remover favoritos
/// - Emitir estados de loading, success e failure
/// - Orquestrar chamadas aos UseCases
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetUserUidUseCase getUserUidUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  FavoritesBloc({
    required this.getUserUidUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super(FavoritesInitial()) {
    on<AddFavoriteEvent>(_onAddFavoriteEvent);
    on<RemoveFavoriteEvent>(_onRemoveFavoriteEvent);
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
}

