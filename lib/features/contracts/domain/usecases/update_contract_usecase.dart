import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/enums/contractor_type_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar contrato existente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Validar dados do contrato
/// - Atualizar contrato no repositório
class UpdateContractUseCase {
  final IContractRepository repository;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;

  UpdateContractUseCase({
    required this.repository,
    this.updateContractsIndexUseCase,
  });

  Future<Either<Failure, void>> call(ContractEntity contract) async {
    try {
      // Validar UID do contrato
      if (contract.uid == null || contract.uid!.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }

      // Validar referência do cliente
      if (contract.refClient == null || contract.refClient!.isEmpty) {
        return const Left(ValidationFailure('Referência do cliente não pode ser vazia'));
      }

      // Validar referência do contratado (artista ou grupo)
      if (contract.contractorType == ContractorTypeEnum.artist) {
        if (contract.refArtist == null || contract.refArtist!.isEmpty) {
          return const Left(ValidationFailure('Referência do artista não pode ser vazia'));
        }
      } else if (contract.contractorType == ContractorTypeEnum.group) {
        if (contract.refGroup == null || contract.refGroup!.isEmpty) {
          return const Left(ValidationFailure('Referência do grupo não pode ser vazia'));
        }
      }

      // Validar duração
      if (contract.duration <= 0) {
        return const Left(ValidationFailure('Duração deve ser maior que zero'));
      }

      // Validar valor
      if (contract.value < 0) {
        return const Left(ValidationFailure('Valor não pode ser negativo'));
      }

      // Buscar contrato antigo para comparar status
      ContractStatusEnum? oldStatus;
      if (updateContractsIndexUseCase != null) {
        final oldContractResult = await repository.getContract(contract.uid!);
        oldContractResult.fold(
          (_) {},
          (oldContract) {
            oldStatus = oldContract.status;
          },
        );
      }

      // Atualizar contrato
      final result = await repository.updateContract(contract);

      return result.fold(
        (failure) => Left(failure),
        (_) async {
          // Atualizar índice de contratos (não bloqueia se falhar)
          if (updateContractsIndexUseCase != null) {
            await updateContractsIndexUseCase!.call(
              contract: contract.copyWith(
                statusChangedAt: DateTime.now(),
              ),
              oldStatus: oldStatus,
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

