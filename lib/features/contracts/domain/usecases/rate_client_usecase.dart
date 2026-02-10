import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/data/datasources/contracts_functions.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/get_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Avaliar cliente/anfitrião (pelo artista)
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Validar dados da avaliação (rating, comentário opcional)
/// - Buscar contrato existente
/// - Validar que o contrato está completado (COMPLETED)
/// - Validar que ainda não foi avaliado pelo artista
/// - Criar RatingEntity para rateByArtist
/// - Atualizar contrato usando UpdateContractUseCase
class RateClientUseCase {
  final GetContractUseCase getContractUseCase;
  final IContractRepository repository;
  final IContractsFunctionsService contractsFunctions;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;

  RateClientUseCase({
    required this.getContractUseCase,
    required this.repository,
    required this.contractsFunctions,
    this.updateContractsIndexUseCase,
  });

  Future<Either<Failure, void>> call({
    required String contractUid,
    required double rating,
    String? comment,
    bool skippedRating = false,
  }) async {
    try {
      // Validar UID do contrato
      if (contractUid.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }

      // Validar rating (deve estar entre 0.0 e 5.0)
      if (rating < 0.0 || rating > 5.0) {
        return const Left(ValidationFailure('Avaliação deve estar entre 0.0 e 5.0'));
      }

      // Se não for skip, rating deve ser maior que 0
      if (!skippedRating && rating <= 0.0) {
        return const Left(ValidationFailure('Avaliação deve ser maior que 0'));
      }

      // Buscar contrato
      final contractResult = await getContractUseCase.call(contractUid, forceRefresh: true);

      final contract = contractResult.fold(
        (failure) => null,
        (contract) => contract,
      );

      if (contract == null) {
        return const Left(NotFoundFailure('Contrato não encontrado'));
      }

      // Validar que o contrato está completado (COMPLETED)
      if (contract.status != ContractStatusEnum.completed) {
        return Left(ValidationFailure(
          'Apenas contratos completados podem ser avaliados. Status atual: ${contract.status.value}'
        ));
      }

      // Validar que ainda não foi avaliado pelo artista
      if (contract.rateByArtist != null) {
        return const Left(ValidationFailure('Contrato já foi avaliado pelo artista'));
      }

      await contractsFunctions.rateClient(
        contractUid,
        rating,
        comment: comment?.trim().isEmpty == true ? null : comment?.trim(),
        skippedRating: skippedRating,
      );

      final getResult = await repository.getContract(contractUid, forceRefresh: true);
      await getResult.fold(
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

