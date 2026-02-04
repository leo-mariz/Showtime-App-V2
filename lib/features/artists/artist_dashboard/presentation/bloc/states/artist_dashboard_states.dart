import 'package:app/features/artists/artist_dashboard/domain/entities/artist_dashboard_stats_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ArtistDashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ArtistDashboardInitial extends ArtistDashboardState {}

// ==================== GET DASHBOARD STATS STATES ====================

class GetArtistDashboardStatsLoading extends ArtistDashboardState {}

class GetArtistDashboardStatsSuccess extends ArtistDashboardState {
  final ArtistDashboardStatsEntity stats;

  GetArtistDashboardStatsSuccess({required this.stats});

  @override
  List<Object?> get props => [stats];
}

class GetArtistDashboardStatsFailure extends ArtistDashboardState {
  final String error;

  GetArtistDashboardStatsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
