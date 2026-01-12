import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar um contrato específico por UID
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Buscar contrato do repositório (cache primeiro, depois remoto)
/// - Retornar contrato encontrado
class GetContractUseCase {
  final IContractRepository repository;

  GetContractUseCase({
    required this.repository,
  });

  Future<Either<Failure, ContractEntity>> call(String contractUid, {bool forceRefresh = false}) async {
    try {
      // Validar UID
      if (contractUid.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }

      // Buscar contrato
      final result = await repository.getContract(contractUid, forceRefresh: forceRefresh);

      return result.fold(
        (failure) => Left(failure),
        (contract) => Right(contract),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

