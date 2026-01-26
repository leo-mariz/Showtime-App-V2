import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/usecases/get_artist_active_availabilities_usecase.dart';
import 'package:app/features/explore/domain/usecases/get_artists_with_availabilities_filtered_usecase.dart';
import 'package:app/features/explore/presentation/bloc/events/explore_events.dart';
import 'package:app/features/explore/presentation/bloc/states/explore_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado da feature Explore
/// 
/// RESPONSABILIDADES:
/// - Gerenciar busca de artistas com disponibilidades filtradas por data e localização
/// - Emitir estados de loading, success e failure
/// - Orquestrar chamadas aos UseCases
/// - Suportar paginação e append de resultados
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetArtistsWithAvailabilitiesFilteredUseCase
      getArtistsWithAvailabilitiesFilteredUseCase;
  final GetArtistActiveAvailabilitiesUseCase getArtistActiveAvailabilitiesUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  ExploreBloc({
    required this.getArtistsWithAvailabilitiesFilteredUseCase,
    required this.getArtistActiveAvailabilitiesUseCase,
    required this.getUserUidUseCase,
  }) : super(ExploreInitial()) {
    on<GetArtistsWithAvailabilitiesFilteredEvent>(
      _onGetArtistsWithAvailabilitiesFilteredEvent,
    );
    on<GetArtistAllAvailabilitiesEvent>(_onGetArtistAllAvailabilitiesEvent);
  }

//   // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
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

  // ==================== GET ARTIST ALL AVAILABILITIES ====================

  Future<void> _onGetArtistAllAvailabilitiesEvent(
    GetArtistAllAvailabilitiesEvent event,
    Emitter<ExploreState> emit,
  ) async {

    var newInstance = state;
    var artistsWithAvailabilities = <ArtistWithAvailabilitiesEntity>[];
    var nextIndex = 0;
    var hasMore = false;
    var append = false;
    if (newInstance is GetArtistsWithAvailabilitiesSuccess) {
      artistsWithAvailabilities = newInstance.artistsWithAvailabilities;
      nextIndex = newInstance.nextIndex;
      hasMore = newInstance.hasMore;
      append = newInstance.append;
    }

    emit(GetArtistAllAvailabilitiesLoading());

    final result = await getArtistActiveAvailabilitiesUseCase.call(
      artistId: event.artistId,
      userAddress: event.userAddress,
      forceRefresh: event.forceRefresh,
    );

    result.fold(
      (failure) {
        emit(GetArtistAllAvailabilitiesFailure(error: failure.message));
        emit(ExploreInitial());
      },
      (availabilities) {
        emit(GetArtistsWithAvailabilitiesSuccess(
          artistsWithAvailabilities: artistsWithAvailabilities,
          nextIndex: nextIndex,
          hasMore: hasMore,
          append: append,
          selectedArtistId: event.artistId,
          availabilities: availabilities,
        ));
      },
    );
  }
}

