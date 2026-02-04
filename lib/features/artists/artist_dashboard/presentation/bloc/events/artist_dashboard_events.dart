import 'package:equatable/equatable.dart';

abstract class ArtistDashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET DASHBOARD STATS EVENTS ====================

class GetArtistDashboardStatsEvent extends ArtistDashboardEvent {
  final bool? forceRefresh;

  GetArtistDashboardStatsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

// ==================== RESET EVENT ====================

class ResetArtistDashboardEvent extends ArtistDashboardEvent {}