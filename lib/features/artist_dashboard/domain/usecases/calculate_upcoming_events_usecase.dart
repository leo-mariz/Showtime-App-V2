import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';

/// UseCase: Calcular quantidade de eventos agendados (futuros)
/// 
/// RESPONSABILIDADES:
/// - Filtrar contratos pagos com data futura
/// - Retornar contagem
class CalculateUpcomingEventsUseCase {
  const CalculateUpcomingEventsUseCase();

  int call(List<ContractEntity> contracts) {
    final now = DateTime.now();
    
    return contracts.where((contract) {
      if (contract.status != ContractStatusEnum.paid) return false;
      
      // Verificar se a data do evento é futura
      final eventDateTime = DateTime(
        contract.date.year,
        contract.date.month,
        contract.date.day,
      );
      
      return eventDateTime.isAfter(now);
    }).length;
  }
}
