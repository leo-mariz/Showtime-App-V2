import 'package:equatable/equatable.dart';

abstract class ArtistDashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET DASHBOARD STATS EVENTS ====================

class GetArtistDashboardStatsEvent extends ArtistDashboardEvent {
  final bool? forceRefresh;
  /// Ano para os gráficos (12 meses). Se null, usa o ano atual.
  final int? year;

  GetArtistDashboardStatsEvent({this.forceRefresh = false, this.year});

  @override
  List<Object?> get props => [forceRefresh, year];
}

// ==================== RESET EVENT ====================

class ResetArtistDashboardEvent extends ArtistDashboardEvent {}