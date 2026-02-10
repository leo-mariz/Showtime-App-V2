import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/data/datasources/contracts_functions.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Aceitar uma solicitação de contrato
/// 
/// Chama a Cloud Function acceptContract; a escrita do contrato é feita no backend.
/// O índice de contratos é atualizado no client após sucesso.
class AcceptContractUseCase {
  final IContractRepository repository;
  final IContractsFunctionsService contractsFunctions;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;

  AcceptContractUseCase({
    required this.repository,
    required this.contractsFunctions,
    this.updateContractsIndexUseCase,
  });

  Future<Either<Failure, void>> call({
    required String contractUid,
    List<String>? acceptedTimes,
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
          'Apenas contratos pendentes podem ser aceitos. Status atual: ${contract.status.value}'
        ));
      }

      // Aceitar contrato via Cloud Function (cria link de pagamento e atualiza status no backend)
      await contractsFunctions.acceptContract(contractUid);

      // Buscar contrato atualizado e atualizar índice no client
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
      if (e is Failure) return Left(e);
      return Left(ErrorHandler.handle(e));
    }
  }
}

