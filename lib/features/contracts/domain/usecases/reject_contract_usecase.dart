import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Rejeitar uma solicitação de contrato
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Buscar contrato existente
/// - Validar que o contrato está pendente
/// - Alterar status para rejected
/// - Adicionar timestamp de rejeição
/// - Atualizar contrato no repositório
class RejectContractUseCase {
  final IContractRepository repository;

  RejectContractUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call({
    required String contractUid,
    List<String>? rejectedTimes,
  }) async {
    try {
      // Validar UID do contrato
      if (contractUid.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }

      // Buscar contrato
      final getResult = await repository.getContract(contractUid);
      
      final contract = getResult.fold(
        (failure) => null,
        (contract) => contract,
      );

      if (contract == null) {
        return const Left(NotFoundFailure('Contrato não encontrado'));
      }

      // Validar que o contrato está pendente
      if (!contract.isPending) {
        return Left(ValidationFailure(
          'Apenas contratos pendentes podem ser rejeitados. Status atual: ${contract.status.value}'
        ));
      }

      // Criar cópia do contrato com status rejeitado
      final updatedContract = contract.copyWith(
        status: ContractStatusEnum.rejected,
        rejectedAt: DateTime.now(),
      );

      // Atualizar contrato
      final updateResult = await repository.updateContract(updatedContract);

      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

