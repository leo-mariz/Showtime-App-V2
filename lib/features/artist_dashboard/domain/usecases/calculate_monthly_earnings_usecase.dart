import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';

/// UseCase: Calcular ganhos do mês atual e mês anterior
/// 
/// RESPONSABILIDADES:
/// - Filtrar contratos pagos do mês atual
/// - Filtrar contratos pagos do mês anterior
/// - Calcular soma dos valores
/// - Calcular crescimento percentual
class CalculateMonthlyEarningsUseCase {
  const CalculateMonthlyEarningsUseCase();

  ({
    double monthEarnings,
    double previousMonthEarnings,
    double growthPercentage,
  }) call(List<ContractEntity> contracts) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);

    double monthEarnings = 0.0;
    double previousMonthEarnings = 0.0;

    for (final contract in contracts) {
      // Só considerar contratos pagos
      if (contract.status != ContractStatusEnum.paid) continue;
      
      // Verificar se tem paymentDate
      if (contract.paymentDate == null) continue;

      final paymentDate = contract.paymentDate!;
      final paymentMonth = DateTime(paymentDate.year, paymentDate.month);

      if (paymentMonth == currentMonth) {
        monthEarnings += contract.value;
      } else if (paymentMonth == previousMonth) {
        previousMonthEarnings += contract.value;
      }
    }

    // Calcular crescimento percentual
    double growthPercentage = 0.0;
    if (previousMonthEarnings > 0) {
      growthPercentage = ((monthEarnings - previousMonthEarnings) / previousMonthEarnings) * 100;
    } else if (monthEarnings > 0) {
      growthPercentage = 100.0; // Crescimento de 0 para algum valor
    }

    return (
      monthEarnings: monthEarnings,
      previousMonthEarnings: previousMonthEarnings,
      growthPercentage: growthPercentage,
    );
  }
}
