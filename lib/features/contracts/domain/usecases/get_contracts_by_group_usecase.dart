import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar lista de contratos por grupo
/// 
/// RESPONSABILIDADES:
/// - Validar UID do grupo
/// - Buscar contratos do repositório (cache primeiro, depois remoto)
/// - Retornar lista de contratos
class GetContractsByGroupUseCase {
  final IContractRepository repository;

  GetContractsByGroupUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<ContractEntity>>> call(String groupUid) async {
    try {
      // Validar UID
      if (groupUid.isEmpty) {
        return const Left(ValidationFailure('UID do grupo não pode ser vazio'));
      }

      // Buscar contratos
      final result = await repository.getContractsByGroup(groupUid);

      return result.fold(
        (failure) => Left(failure),
        (contracts) => Right(contracts),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

