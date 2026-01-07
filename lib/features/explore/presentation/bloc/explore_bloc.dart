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

  ExploreBloc({
    required this.getArtistsWithAvailabilitiesUseCase,
    required this.getArtistsWithAvailabilitiesFilteredUseCase,
  }) : super(ExploreInitial()) {
    on<GetArtistsWithAvailabilitiesEvent>(_onGetArtistsWithAvailabilitiesEvent);
    on<GetArtistsWithAvailabilitiesFilteredEvent>(
      _onGetArtistsWithAvailabilitiesFilteredEvent,
    );
  }

  // ==================== GET ARTISTS WITH AVAILABILITIES ====================

  Future<void> _onGetArtistsWithAvailabilitiesEvent(
    GetArtistsWithAvailabilitiesEvent event,
    Emitter<ExploreState> emit,
  ) async {
    emit(GetArtistsWithAvailabilitiesLoading());

    final result = await getArtistsWithAvailabilitiesUseCase.call(
      forceRefresh: event.forceRefresh,
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
    emit(GetArtistsWithAvailabilitiesLoading());

    final result = await getArtistsWithAvailabilitiesFilteredUseCase.call(
      selectedDate: event.selectedDate,
      userAddress: event.userAddress,
      forceRefresh: event.forceRefresh,
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
}

