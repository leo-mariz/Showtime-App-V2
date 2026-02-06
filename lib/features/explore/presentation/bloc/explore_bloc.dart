import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/explore/domain/entities/artists/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/entities/ensembles/ensemble_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/usecases/artists/get_artist_active_availabilities_usecase.dart';
import 'package:app/features/explore/domain/usecases/artists/get_artists_with_availabilities_filtered_usecase.dart';
import 'package:app/features/explore/domain/usecases/ensembles/get_ensembles_with_availabilities_filtered_usecase.dart';
import 'package:app/features/explore/presentation/bloc/events/explore_events.dart';
import 'package:app/features/explore/presentation/bloc/states/explore_states.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado da feature Explore (artistas e conjuntos).
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetArtistsWithAvailabilitiesFilteredUseCase
      getArtistsWithAvailabilitiesFilteredUseCase;
  final GetEnsemblesWithAvailabilitiesFilteredUseCase
      getEnsemblesWithAvailabilitiesFilteredUseCase;
  final GetArtistActiveAvailabilitiesUseCase getArtistActiveAvailabilitiesUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  ExploreBloc({
    required this.getArtistsWithAvailabilitiesFilteredUseCase,
    required this.getEnsemblesWithAvailabilitiesFilteredUseCase,
    required this.getArtistActiveAvailabilitiesUseCase,
    required this.getUserUidUseCase,
  }) : super(ExploreInitial()) {
    on<GetArtistsWithAvailabilitiesFilteredEvent>(
      _onGetArtistsWithAvailabilitiesFilteredEvent,
    );
    on<GetEnsemblesWithAvailabilitiesFilteredEvent>(
      _onGetEnsemblesWithAvailabilitiesFilteredEvent,
    );
    on<GetArtistAllAvailabilitiesEvent>(_onGetArtistAllAvailabilitiesEvent);
    on<ResetExploreEvent>(_onResetExploreEvent);
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
    if (!event.append) {
      List<EnsembleWithAvailabilitiesEntity>? ensembles;
      int? ensemblesNextIndex;
      bool? ensemblesHasMore;
      if (state is GetArtistsWithAvailabilitiesSuccess) {
        final s = state as GetArtistsWithAvailabilitiesSuccess;
        ensembles = s.ensemblesWithAvailabilities;
        ensemblesNextIndex = s.ensemblesNextIndex;
        ensemblesHasMore = s.ensemblesHasMore;
      } else if (state is GetEnsemblesWithAvailabilitiesSuccess) {
        final s = state as GetEnsemblesWithAvailabilitiesSuccess;
        ensembles = s.ensemblesWithAvailabilities;
        ensemblesNextIndex = s.nextIndex;
        ensemblesHasMore = s.hasMore;
      }
      emit(GetArtistsWithAvailabilitiesLoading(
        ensemblesWithAvailabilities: ensembles,
        ensemblesNextIndex: ensemblesNextIndex,
        ensemblesHasMore: ensemblesHasMore,
      ));
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

        List<EnsembleWithAvailabilitiesEntity>? ensembles;
        int? ensemblesNextIndex;
        bool? ensemblesHasMore;
        if (state is GetArtistsWithAvailabilitiesSuccess) {
          final s = state as GetArtistsWithAvailabilitiesSuccess;
          ensembles = s.ensemblesWithAvailabilities;
          ensemblesNextIndex = s.ensemblesNextIndex;
          ensemblesHasMore = s.ensemblesHasMore;
        } else if (state is GetEnsemblesWithAvailabilitiesSuccess) {
          final s = state as GetEnsemblesWithAvailabilitiesSuccess;
          ensembles = s.ensemblesWithAvailabilities;
          ensemblesNextIndex = s.nextIndex;
          ensemblesHasMore = s.hasMore;
        }

        emit(GetArtistsWithAvailabilitiesSuccess(
          artistsWithAvailabilities: merged,
          nextIndex: paged.nextIndex,
          hasMore: paged.hasMore,
          append: event.append,
          ensemblesWithAvailabilities: ensembles,
          ensemblesNextIndex: ensemblesNextIndex,
          ensemblesHasMore: ensemblesHasMore,
        ));
      },
    );
  }

  // ==================== GET ENSEMBLES WITH AVAILABILITIES FILTERED ====================

  Future<void> _onGetEnsemblesWithAvailabilitiesFilteredEvent(
    GetEnsemblesWithAvailabilitiesFilteredEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (!event.append) {
      List<ArtistWithAvailabilitiesEntity>? artists;
      int? artistsNextIndex;
      bool? artistsHasMore;
      if (state is GetArtistsWithAvailabilitiesSuccess) {
        final s = state as GetArtistsWithAvailabilitiesSuccess;
        artists = s.artistsWithAvailabilities;
        artistsNextIndex = s.nextIndex;
        artistsHasMore = s.hasMore;
      } else if (state is GetEnsemblesWithAvailabilitiesSuccess) {
        final s = state as GetEnsemblesWithAvailabilitiesSuccess;
        artists = s.artistsWithAvailabilities;
        artistsNextIndex = s.artistsNextIndex;
        artistsHasMore = s.artistsHasMore;
      }
      emit(GetEnsemblesWithAvailabilitiesLoading(
        artistsWithAvailabilities: artists,
        artistsNextIndex: artistsNextIndex,
        artistsHasMore: artistsHasMore,
      ));
    }

    final result = await getEnsemblesWithAvailabilitiesFilteredUseCase.call(
      selectedDate: event.selectedDate,
      userAddress: event.userAddress,
      forceRefresh: event.forceRefresh,
      startIndex: event.startIndex,
      pageSize: event.pageSize,
      searchQuery: event.searchQuery,
    );

    result.fold(
      (failure) {
        debugPrint('[ExploreBloc] GetEnsemblesWithAvailabilities falhou: ${failure.message}');
        emit(GetEnsemblesWithAvailabilitiesFailure(error: failure.message));
        emit(ExploreInitial());
      },
      (paged) {
        List<EnsembleWithAvailabilitiesEntity> previous =
            <EnsembleWithAvailabilitiesEntity>[];
        if (state is GetEnsemblesWithAvailabilitiesSuccess) {
          previous =
              (state as GetEnsemblesWithAvailabilitiesSuccess)
                  .ensemblesWithAvailabilities;
        }

        final merged =
            event.append ? [...previous, ...paged.items] : paged.items;

        List<ArtistWithAvailabilitiesEntity>? artists;
        int? artistsNextIndex;
        bool? artistsHasMore;
        if (state is GetArtistsWithAvailabilitiesSuccess) {
          final s = state as GetArtistsWithAvailabilitiesSuccess;
          artists = s.artistsWithAvailabilities;
          artistsNextIndex = s.nextIndex;
          artistsHasMore = s.hasMore;
        } else if (state is GetEnsemblesWithAvailabilitiesSuccess) {
          final s = state as GetEnsemblesWithAvailabilitiesSuccess;
          artists = s.artistsWithAvailabilities;
          artistsNextIndex = s.artistsNextIndex;
          artistsHasMore = s.artistsHasMore;
        }

        emit(GetEnsemblesWithAvailabilitiesSuccess(
          ensemblesWithAvailabilities: merged,
          nextIndex: paged.nextIndex,
          hasMore: paged.hasMore,
          append: event.append,
          artistsWithAvailabilities: artists,
          artistsNextIndex: artistsNextIndex,
          artistsHasMore: artistsHasMore,
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
    List<EnsembleWithAvailabilitiesEntity>? ensembles;
    int? ensemblesNextIndex;
    bool? ensemblesHasMore;
    if (newInstance is GetArtistsWithAvailabilitiesSuccess) {
      artistsWithAvailabilities = newInstance.artistsWithAvailabilities;
      nextIndex = newInstance.nextIndex;
      hasMore = newInstance.hasMore;
      append = newInstance.append;
      ensembles = newInstance.ensemblesWithAvailabilities;
      ensemblesNextIndex = newInstance.ensemblesNextIndex;
      ensemblesHasMore = newInstance.ensemblesHasMore;
    } else if (newInstance is GetEnsemblesWithAvailabilitiesSuccess) {
      ensembles = newInstance.ensemblesWithAvailabilities;
      ensemblesNextIndex = newInstance.nextIndex;
      ensemblesHasMore = newInstance.hasMore;
    }

    // Não emite Loading aqui para não apagar a lista do explore ao abrir RequestScreen
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
          ensemblesWithAvailabilities: ensembles,
          ensemblesNextIndex: ensemblesNextIndex,
          ensemblesHasMore: ensemblesHasMore,
        ));
      },
    );
  }

  // ==================== RESET ====================

  Future<void> _onResetExploreEvent(
    ResetExploreEvent event,
    Emitter<ExploreState> emit,
  ) async {
    emit(ExploreInitial());
  }
}

