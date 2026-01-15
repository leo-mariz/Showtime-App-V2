import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/usecases/get_artists_with_availabilities_filtered_usecase.dart';
import 'package:app/features/explore/domain/usecases/get_artists_with_availabilities_usecase.dart';
import 'package:app/features/explore/presentation/bloc/events/explore_events.dart';
import 'package:app/features/explore/presentation/bloc/states/explore_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado da feature Explore
/// 
/// RESPONSABILIDADES:
/// - Gerenciar busca de artistas com disponibilidades
/// - Gerenciar busca de artistas com disponibilidades filtradas
/// - Emitir estados de loading, success e failure
/// - Orquestrar chamadas aos UseCases
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetArtistsWithAvailabilitiesUseCase getArtistsWithAvailabilitiesUseCase;
  final GetArtistsWithAvailabilitiesFilteredUseCase
      getArtistsWithAvailabilitiesFilteredUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  ExploreBloc({
    required this.getArtistsWithAvailabilitiesUseCase,
    required this.getArtistsWithAvailabilitiesFilteredUseCase,
    required this.getUserUidUseCase,
  }) : super(ExploreInitial()) {
    on<GetArtistsWithAvailabilitiesEvent>(_onGetArtistsWithAvailabilitiesEvent);
    on<GetArtistsWithAvailabilitiesFilteredEvent>(
      _onGetArtistsWithAvailabilitiesFilteredEvent,
    );
    on<UpdateArtistFavoriteStatusEvent>(_onUpdateArtistFavoriteStatusEvent);
  }


  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET ARTISTS WITH AVAILABILITIES ====================

  Future<void> _onGetArtistsWithAvailabilitiesEvent(
    GetArtistsWithAvailabilitiesEvent event,
    Emitter<ExploreState> emit,
  ) async {
    emit(GetArtistsWithAvailabilitiesLoading());

    final userId = await _getCurrentUserId();

    final result = await getArtistsWithAvailabilitiesUseCase.call(
      forceRefresh: event.forceRefresh,
      userId: userId,
    );

    result.fold(
      (failure) {
        emit(GetArtistsWithAvailabilitiesFailure(error: failure.message));
        emit(ExploreInitial());
      },
      (artistsWithAvailabilities) {
        emit(GetArtistsWithAvailabilitiesSuccess(
          artistsWithAvailabilities: artistsWithAvailabilities,
        ));
      },
    );
  }

  // ==================== GET ARTISTS WITH AVAILABILITIES FILTERED ====================

  Future<void> _onGetArtistsWithAvailabilitiesFilteredEvent(
    GetArtistsWithAvailabilitiesFilteredEvent event,
    Emitter<ExploreState> emit,
  ) async {
    // Mostrar loading apenas se não for append; em append mantemos lista atual
    if (!event.append) {
      emit(GetArtistsWithAvailabilitiesLoading());
    }

    final userId = await _getCurrentUserId();

    final result = await getArtistsWithAvailabilitiesFilteredUseCase.call(
      selectedDate: event.selectedDate,
      userAddress: event.userAddress,
      forceRefresh: event.forceRefresh,
      startIndex: event.startIndex,
      pageSize: event.pageSize,
      userId: userId,
      searchQuery: event.searchQuery,
    );

    result.fold(
      (failure) {
        emit(GetArtistsWithAvailabilitiesFailure(error: failure.message));
        emit(ExploreInitial());
      },
      (paged) {
        final previous = state is GetArtistsWithAvailabilitiesSuccess
            ? (state as GetArtistsWithAvailabilitiesSuccess)
                .artistsWithAvailabilities
            : <ArtistWithAvailabilitiesEntity>[];

        final merged = event.append
            ? [...previous, ...paged.items]
            : paged.items;

        emit(GetArtistsWithAvailabilitiesSuccess(
          artistsWithAvailabilities: merged,
          nextIndex: paged.nextIndex,
          hasMore: paged.hasMore,
          append: event.append,
        ));
      },
    );
  }

  // ==================== UPDATE ARTIST FAVORITE STATUS ====================

  Future<void> _onUpdateArtistFavoriteStatusEvent(
    UpdateArtistFavoriteStatusEvent event,
    Emitter<ExploreState> emit,
  ) async {
    // Só atualizar se já tiver dados carregados
    if (state is GetArtistsWithAvailabilitiesSuccess) {
      final currentState = state as GetArtistsWithAvailabilitiesSuccess;

      // Atualizar apenas o isFavorite do artista específico
      final updatedArtists = currentState.artistsWithAvailabilities.map((artist) {
        if (artist.artist.uid == event.artistId) {
          // Criar nova instância com isFavorite atualizado
          return ArtistWithAvailabilitiesEntity(
            artist: artist.artist,
            availabilities: artist.availabilities,
            isFavorite: event.isFavorite,
          );
        }
        return artist;
      }).toList();

      // Emitir novo estado com lista atualizada
      emit(currentState.copyWith(
        artistsWithAvailabilities: updatedArtists,
      ));
    }
  }
}

