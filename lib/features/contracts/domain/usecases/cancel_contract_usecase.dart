import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/data/datasources/contracts_functions.dart';
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
  final IContractsFunctionsService contractsFunctions;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;

  CancelContractUseCase({
    required this.repository,
    required this.contractsFunctions,
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

      await contractsFunctions.cancelContract(contractUid, canceledBy, cancelReason: cancelReason);

      final getResult2 = await repository.getContract(contractUid, forceRefresh: true);
      await getResult2.fold(
        (_) async {},
        (updatedContract) async {
          if (updateContractsIndexUseCase != null) {
            await updateContractsIndexUseCase!.call(
              contract: updatedContract,
              oldStatus: contract.status,
            );
          }
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

