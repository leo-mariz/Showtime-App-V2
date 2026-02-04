import 'package:app/features/artists/artist_dashboard/domain/entities/next_show_entity.dart';
import 'package:equatable/equatable.dart';

/// Entidade que representa todas as estatísticas do dashboard do artista
class ArtistDashboardStatsEntity extends Equatable {
  // Métricas principais
  final double monthEarnings;
  final double previousMonthEarnings;
  final double growthPercentage;
  final double averageRating;
  final int totalReviews;
  final int pendingRequests;
  final int upcomingEvents;
  final int completedEvents;
  final double acceptanceRate;
  
  // Próximo show
  final NextShowEntity? nextShow;
  
  // Dados mensais para gráficos (últimos 6 meses)
  final List<MonthlyStatsEntity> monthlyStats;

  const ArtistDashboardStatsEntity({
    required this.monthEarnings,
    required this.previousMonthEarnings,
    required this.growthPercentage,
    required this.averageRating,
    required this.totalReviews,
    required this.pendingRequests,
    required this.upcomingEvents,
    required this.completedEvents,
    required this.acceptanceRate,
    this.nextShow,
    required this.monthlyStats,
  });

  @override
  List<Object?> get props => [
    monthEarnings,
    previousMonthEarnings,
    growthPercentage,
    averageRating,
    totalReviews,
    pendingRequests,
    upcomingEvents,
    completedEvents,
    acceptanceRate,
    nextShow,
    monthlyStats,
  ];
}

/// Entidade que representa estatísticas de um mês específico
class MonthlyStatsEntity extends Equatable {
  final String month; // 'Jul', 'Ago', etc.
  final double earnings;
  final int contracts;
  final int requests;
  final double acceptanceRate;

  const MonthlyStatsEntity({
    required this.month,
    required this.earnings,
    required this.contracts,
    required this.requests,
    required this.acceptanceRate,
  });

  @override
  List<Object?> get props => [month, earnings, contracts, requests, acceptanceRate];
}
