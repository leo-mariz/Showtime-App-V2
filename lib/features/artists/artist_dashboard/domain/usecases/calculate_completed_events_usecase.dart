import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';

/// UseCase: Calcular quantidade de eventos concluídos
/// 
/// RESPONSABILIDADES:
/// - Filtrar contratos com status completed ou rated
/// - Retornar contagem
class CalculateCompletedEventsUseCase {
  const CalculateCompletedEventsUseCase();

  int call(List<ContractEntity> contracts) {
    return contracts.where((contract) {
      return contract.status == ContractStatusEnum.completed ||
          contract.status == ContractStatusEnum.rated;
    }).length;
  }
}
