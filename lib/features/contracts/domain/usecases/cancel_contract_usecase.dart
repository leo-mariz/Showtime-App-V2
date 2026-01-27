import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Cancelar um contrato
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Buscar contrato existente
/// - Validar que o contrato pode ser cancelado
/// - Alterar status para canceled
/// - Adicionar informações de cancelamento (quem cancelou, motivo, timestamp)
/// - Atualizar contrato no repositório
class CancelContractUseCase {
  final IContractRepository repository;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;

  CancelContractUseCase({
    required this.repository,
    this.updateContractsIndexUseCase,
  });

  Future<Either<Failure, void>> call({
    required String contractUid,
    required String canceledBy, // 'CLIENT' ou 'ARTIST'
    String? cancelReason,
  }) async {
    try {
      // Validar UID do contrato
      if (contractUid.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }

      // Validar quem está cancelando
      if (canceledBy.isEmpty) {
        return const Left(ValidationFailure('Informação de quem está cancelando é obrigatória'));
      }

      if (canceledBy != 'CLIENT' && canceledBy != 'ARTIST') {
        return const Left(ValidationFailure('canceledBy deve ser "CLIENT" ou "ARTIST"'));
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

      // Validar que o contrato pode ser cancelado
      // Não pode estar já cancelado, completado ou rejeitado
      if (contract.status == ContractStatusEnum.canceled) {
        return const Left(ValidationFailure('Contrato já está cancelado'));
      }

      if (contract.status == ContractStatusEnum.completed) {
        return const Left(ValidationFailure('Não é possível cancelar um contrato já completado'));
      }

      if (contract.status == ContractStatusEnum.rejected) {
        return const Left(ValidationFailure('Não é possível cancelar um contrato já rejeitado'));
      }

      // Criar cópia do contrato com status cancelado
      final updatedContract = contract.copyWith(
        status: ContractStatusEnum.canceled,
        canceledAt: DateTime.now(),
        canceledBy: canceledBy,
        cancelReason: cancelReason,
        statusChangedAt: DateTime.now(),
      );

      // Atualizar contrato
      final updateResult = await repository.updateContract(updatedContract);

      return updateResult.fold(
        (failure) => Left(failure),
        (_) async {
          // Atualizar índice de contratos (não bloqueia se falhar)
          if (updateContractsIndexUseCase != null) {
            await updateContractsIndexUseCase!.call(
              contract: updatedContract,
              oldStatus: contract.status,
            );
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

