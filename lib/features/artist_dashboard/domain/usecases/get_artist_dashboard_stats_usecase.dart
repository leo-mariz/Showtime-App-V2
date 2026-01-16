import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artist_dashboard/domain/entities/artist_dashboard_stats_entity.dart';
import 'package:app/features/artist_dashboard/domain/usecases/calculate_acceptance_rate_usecase.dart';
import 'package:app/features/artist_dashboard/domain/usecases/calculate_completed_events_usecase.dart';
import 'package:app/features/artist_dashboard/domain/usecases/calculate_monthly_earnings_usecase.dart';
import 'package:app/features/artist_dashboard/domain/usecases/calculate_monthly_stats_usecase.dart';
import 'package:app/features/artist_dashboard/domain/usecases/calculate_next_show_usecase.dart';
import 'package:app/features/artist_dashboard/domain/usecases/calculate_pending_requests_usecase.dart';
import 'package:app/features/artist_dashboard/domain/usecases/calculate_upcoming_events_usecase.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar estatísticas completas do dashboard do artista
/// 
/// RESPONSABILIDADES:
/// - Buscar dados do artista
/// - Buscar contratos do artista
/// - Calcular todas as métricas usando usecases específicos
/// - Retornar estatísticas agregadas
class GetArtistDashboardStatsUseCase {
  final GetUserUidUseCase getUserUidUseCase;
  final GetArtistUseCase getArtistUseCase;
  final GetContractsByArtistUseCase getContractsByArtistUseCase;
  final CalculateMonthlyEarningsUseCase calculateMonthlyEarningsUseCase;
  final CalculatePendingRequestsUseCase calculatePendingRequestsUseCase;
  final CalculateUpcomingEventsUseCase calculateUpcomingEventsUseCase;
  final CalculateCompletedEventsUseCase calculateCompletedEventsUseCase;
  final CalculateAcceptanceRateUseCase calculateAcceptanceRateUseCase;
  final CalculateMonthlyStatsUseCase calculateMonthlyStatsUseCase;
  final CalculateNextShowUseCase calculateNextShowUseCase;

  GetArtistDashboardStatsUseCase({
    required this.getUserUidUseCase,
    required this.getArtistUseCase,
    required this.getContractsByArtistUseCase,
    required this.calculateMonthlyEarningsUseCase,
    required this.calculatePendingRequestsUseCase,
    required this.calculateUpcomingEventsUseCase,
    required this.calculateCompletedEventsUseCase,
    required this.calculateAcceptanceRateUseCase,
    required this.calculateMonthlyStatsUseCase,
    required this.calculateNextShowUseCase,
  });

  Future<Either<Failure, ArtistDashboardStatsEntity>> call({bool forceRefresh = false}) async {
    try {
      // 1. Obter UID do usuário
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (_) => null,
        (uid) => uid,
      );

      if (uid == null) {
        return const Left(ValidationFailure('Usuário não autenticado'));
      }

      // 2. Buscar dados do artista e contratos em paralelo
      final artistResult = await getArtistUseCase.call(uid);
      final contractsResult = await getContractsByArtistUseCase.call(uid, forceRefresh: forceRefresh);

      // 3. Verificar se ambas as operações foram bem-sucedidas
      return artistResult.fold(
        (failure) => Left(failure),
        (artist) {
          return contractsResult.fold(
            (failure) => Left(failure),
            (contracts) {
              // 4. Calcular todas as métricas usando os usecases específicos
              final earnings = calculateMonthlyEarningsUseCase.call(contracts);
              final pendingRequests = calculatePendingRequestsUseCase.call(contracts);
              final upcomingEvents = calculateUpcomingEventsUseCase.call(contracts);
              final completedEvents = calculateCompletedEventsUseCase.call(contracts);
              final acceptanceRate = calculateAcceptanceRateUseCase.call(contracts);
              final monthlyStats = calculateMonthlyStatsUseCase.call(contracts);
              final nextShow = calculateNextShowUseCase.call(contracts);

              // 5. Retornar estatísticas agregadas
              return Right(ArtistDashboardStatsEntity(
                monthEarnings: earnings.monthEarnings,
                previousMonthEarnings: earnings.previousMonthEarnings,
                growthPercentage: earnings.growthPercentage,
                averageRating: artist.rating ?? 0.0,
                totalReviews: artist.rateCount ?? 0,
                pendingRequests: pendingRequests,
                upcomingEvents: upcomingEvents,
                completedEvents: completedEvents,
                acceptanceRate: acceptanceRate,
                nextShow: nextShow,
                monthlyStats: monthlyStats,
              ));
            },
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
