import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar lista de contratos por cliente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do cliente
/// - Buscar contratos do repositório (cache primeiro, depois remoto)
/// - Retornar lista de contratos
class GetContractsByClientUseCase {
  final IContractRepository repository;

  GetContractsByClientUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<ContractEntity>>> call(String clientUid, {bool forceRefresh = false}) async {
    try {
      // Validar UID
      if (clientUid.isEmpty) {
        return const Left(ValidationFailure('UID do cliente não pode ser vazio'));
      }

      // Buscar contratos
      final result = await repository.getContractsByClient(clientUid, forceRefresh: forceRefresh);

      return result.fold(
        (failure) => Left(failure),
        (contracts) async {
          final contractsWithKeyCode = <ContractEntity>[];
          for (var contract in contracts) {
            if (contract.status == ContractStatusEnum.paid) {
              final keyCodeResult = await repository.getKeyCode(contract.uid!);
              if (keyCodeResult.isRight()) {
                contract = contract.copyWith(keyCode: keyCodeResult.fold((failure) => null, (keyCode) => keyCode));
              }
            }
            contractsWithKeyCode.add(contract);
          }
          return Right(contractsWithKeyCode);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

