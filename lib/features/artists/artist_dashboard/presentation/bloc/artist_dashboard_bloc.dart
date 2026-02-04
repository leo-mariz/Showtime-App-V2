import 'package:app/features/artists/artist_dashboard/domain/usecases/get_artist_dashboard_stats_usecase.dart';
import 'package:app/features/artists/artist_dashboard/presentation/bloc/events/artist_dashboard_events.dart';
import 'package:app/features/artists/artist_dashboard/presentation/bloc/states/artist_dashboard_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado do dashboard do artista
/// 
/// RESPONSABILIDADES:
/// - Gerenciar busca de estatísticas do dashboard
/// - Emitir estados de loading, success e failure
/// - Orquestrar chamadas ao UseCase
class ArtistDashboardBloc extends Bloc<ArtistDashboardEvent, ArtistDashboardState> {
  final GetArtistDashboardStatsUseCase getArtistDashboardStatsUseCase;

  ArtistDashboardBloc({
    required this.getArtistDashboardStatsUseCase,
  }) : super(ArtistDashboardInitial()) {
    on<GetArtistDashboardStatsEvent>(_onGetArtistDashboardStatsEvent);
    on<ResetArtistDashboardEvent>(_onResetArtistDashboardEvent);
  }

  // ==================== GET DASHBOARD STATS ====================

  Future<void> _onGetArtistDashboardStatsEvent(
    GetArtistDashboardStatsEvent event,
    Emitter<ArtistDashboardState> emit,
  ) async {
    emit(GetArtistDashboardStatsLoading());

    final result = await getArtistDashboardStatsUseCase.call(
      forceRefresh: event.forceRefresh ?? false,
    );

    result.fold(
      (failure) {
        emit(GetArtistDashboardStatsFailure(error: failure.message));
        emit(ArtistDashboardInitial());
      },
      (stats) {
        emit(GetArtistDashboardStatsSuccess(stats: stats));
      },
    );
  }

  // ==================== RESET ====================

  Future<void> _onResetArtistDashboardEvent(
    ResetArtistDashboardEvent event,
    Emitter<ArtistDashboardState> emit,
  ) async {
    emit(ArtistDashboardInitial());
  }
}
