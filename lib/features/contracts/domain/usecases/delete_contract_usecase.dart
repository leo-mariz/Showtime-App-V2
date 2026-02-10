import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Remover contrato
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Buscar contrato (para atualizar índice)
/// - Remover contrato do repositório
/// - Atualizar índice de contratos (artist/client) após remoção
class DeleteContractUseCase {
  final IContractRepository repository;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;

  DeleteContractUseCase({
    required this.repository,
    this.updateContractsIndexUseCase,
  });

  Future<Either<Failure, void>> call(String contractUid) async {
    try {
      if (contractUid.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }

      ContractEntity? contractForIndex;
      if (updateContractsIndexUseCase != null) {
        final getResult = await repository.getContract(contractUid);
        contractForIndex = getResult.fold((_) => null, (c) => c);
      }

      final result = await repository.deleteContract(contractUid);

      return await result.fold(
        (failure) => Future.value(Left<Failure, void>(failure)),
        (_) async {
          if (contractForIndex != null && updateContractsIndexUseCase != null) {
            await updateContractsIndexUseCase!.call(
              contract: contractForIndex,
              removed: true,
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

