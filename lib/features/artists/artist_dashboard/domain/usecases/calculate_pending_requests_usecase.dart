import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';

/// UseCase: Calcular quantidade de solicitações pendentes
/// 
/// RESPONSABILIDADES:
/// - Filtrar contratos com status pendente
/// - Retornar contagem
class CalculatePendingRequestsUseCase {
  const CalculatePendingRequestsUseCase();

  int call(List<ContractEntity> contracts) {
    return contracts.where((contract) {
      return contract.status == ContractStatusEnum.pending ||
          contract.status == ContractStatusEnum.paymentPending ||
          contract.status == ContractStatusEnum.paymentExpired ||
          contract.status == ContractStatusEnum.paymentRefused;
    }).length;
  }
}
