import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';

/// UseCase: Calcular taxa de aceitação
/// 
/// RESPONSABILIDADES:
/// - Contar total de solicitações recebidas
/// - Contar solicitações aceitas (paid, completed, rated)
/// - Calcular percentual
class CalculateAcceptanceRateUseCase {
  const CalculateAcceptanceRateUseCase();

  double call(List<ContractEntity> contracts) {
    if (contracts.isEmpty) return 0.0;

    // Total de solicitações (excluindo cancelados)
    final totalRequests = contracts.where((contract) {
      return contract.status != ContractStatusEnum.canceled;
    }).length;

    if (totalRequests == 0) return 0.0;

    // Solicitações aceitas (paid, completed, rated)
    final acceptedRequests = contracts.where((contract) {
      return contract.status == ContractStatusEnum.paid ||
          contract.status == ContractStatusEnum.completed ||
          contract.status == ContractStatusEnum.rated;
    }).length;

    return (acceptedRequests / totalRequests) * 100;
  }
}
