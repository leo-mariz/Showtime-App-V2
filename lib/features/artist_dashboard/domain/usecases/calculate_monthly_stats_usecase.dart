import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/features/artist_dashboard/domain/entities/artist_dashboard_stats_entity.dart';
import 'package:intl/intl.dart';

/// UseCase: Calcular estatísticas mensais para gráficos (últimos 6 meses)
/// 
/// RESPONSABILIDADES:
/// - Agrupar contratos por mês
/// - Calcular receita, contratos, solicitações e taxa de aceitação por mês
/// - Retornar lista ordenada dos últimos 6 meses
class CalculateMonthlyStatsUseCase {
  const CalculateMonthlyStatsUseCase();

  List<MonthlyStatsEntity> call(List<ContractEntity> contracts) {
    final now = DateTime.now();
    final months = <DateTime>[];
    
    // Gerar lista dos últimos 6 meses
    for (int i = 5; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i));
    }

    final monthlyStats = <MonthlyStatsEntity>[];

    for (final month in months) {
      // Filtrar contratos do mês (baseado na data de criação ou paymentDate)
      final monthContracts = contracts.where((contract) {
        // Usar paymentDate se existir, senão usar createdAt
        final referenceDate = contract.paymentDate ?? contract.createdAt;
        if (referenceDate == null) return false;
        
        final contractMonth = DateTime(referenceDate.year, referenceDate.month);
        return contractMonth == month;
      }).toList();

      // Calcular receita (soma de valores pagos)
      double earnings = 0.0;
      int paidContracts = 0;
      int totalRequests = 0;
      int acceptedRequests = 0;

      for (final contract in monthContracts) {
        totalRequests++;
        
        if (contract.status == ContractStatusEnum.paid ||
            contract.status == ContractStatusEnum.completed ||
            contract.status == ContractStatusEnum.rated) {
          earnings += contract.value;
          paidContracts++;
          acceptedRequests++;
        } else if (contract.status == ContractStatusEnum.pending ||
            contract.status == ContractStatusEnum.paymentPending) {
          // Contar como solicitação, mas não aceita
        }
      }

      // Calcular taxa de aceitação do mês
      final acceptanceRate = totalRequests > 0 
          ? (acceptedRequests / totalRequests) * 100 
          : 0.0;

      // Formatar nome do mês
      final monthName = DateFormat('MMM', 'pt_BR').format(month);
      final capitalizedMonthName = monthName[0].toUpperCase() + monthName.substring(1);

      monthlyStats.add(MonthlyStatsEntity(
        month: capitalizedMonthName,
        earnings: earnings,
        contracts: paidContracts,
        requests: totalRequests,
        acceptanceRate: acceptanceRate,
      ));
    }

    return monthlyStats;
  }
}
