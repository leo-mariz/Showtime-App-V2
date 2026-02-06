import 'package:app/features/contracts/presentation/bloc/request_availabilities/events/request_availabilities_events.dart';
import 'package:app/features/contracts/presentation/bloc/request_availabilities/states/request_availabilities_states.dart';
import 'package:app/features/explore/domain/usecases/artists/get_artist_active_availabilities_usecase.dart';
import 'package:app/features/explore/domain/usecases/ensembles/get_ensemble_active_availabilities_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc exclusivo da tela de solicitação (RequestScreen).
/// Carrega disponibilidades do artista ou do conjunto usando use cases do Explore,
/// sem alterar o estado do ExploreBloc.
class RequestAvailabilitiesBloc
    extends Bloc<RequestAvailabilitiesEvent, RequestAvailabilitiesState> {
  final GetArtistActiveAvailabilitiesUseCase getArtistActiveAvailabilitiesUseCase;
  final GetEnsembleActiveAvailabilitiesUseCase
      getEnsembleActiveAvailabilitiesUseCase;

  RequestAvailabilitiesBloc({
    required this.getArtistActiveAvailabilitiesUseCase,
    required this.getEnsembleActiveAvailabilitiesUseCase,
  }) : super(RequestAvailabilitiesInitial()) {
    on<LoadArtistAvailabilitiesEvent>(_onLoadArtistAvailabilities);
    on<LoadEnsembleAvailabilitiesEvent>(_onLoadEnsembleAvailabilities);
  }

  Future<void> _onLoadArtistAvailabilities(
    LoadArtistAvailabilitiesEvent event,
    Emitter<RequestAvailabilitiesState> emit,
  ) async {
    emit(RequestAvailabilitiesLoading());

    final result = await getArtistActiveAvailabilitiesUseCase.call(
      artistId: event.artistId,
      userAddress: event.userAddress,
      forceRefresh: event.forceRefresh,
    );

    result.fold(
      (failure) => emit(RequestAvailabilitiesFailure(error: failure.message)),
      (availabilities) =>
          emit(RequestAvailabilitiesSuccess(availabilities: availabilities)),
    );
  }

  Future<void> _onLoadEnsembleAvailabilities(
    LoadEnsembleAvailabilitiesEvent event,
    Emitter<RequestAvailabilitiesState> emit,
  ) async {
    emit(RequestAvailabilitiesLoading());

    final result = await getEnsembleActiveAvailabilitiesUseCase.call(
      ensembleId: event.ensembleId,
      userAddress: event.userAddress,
      forceRefresh: event.forceRefresh,
    );

    result.fold(
      (failure) => emit(RequestAvailabilitiesFailure(error: failure.message)),
      (availabilities) =>
          emit(RequestAvailabilitiesSuccess(availabilities: availabilities)),
    );
  }
}
