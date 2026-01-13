import 'package:app/core/domain/contract/rating_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/usecases/get_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contract_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Pular avaliação do artista (pelo cliente/anfitrião)
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Buscar contrato existente
/// - Validar que o contrato está completado (COMPLETED)
/// - Validar que ainda não foi avaliado pelo cliente
/// - Criar RatingEntity com skippedRating = true para rateByClient
/// - Atualizar contrato usando UpdateContractUseCase
class SkipRatingArtistUseCase {
  final GetContractUseCase getContractUseCase;
  final UpdateContractUseCase updateContractUseCase;

  SkipRatingArtistUseCase({
    required this.getContractUseCase,
    required this.updateContractUseCase,
  });

  Future<Either<Failure, void>> call({
    required String contractUid,
  }) async {
    try {
      // Validar UID do contrato
      if (contractUid.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
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

      // Validar que ainda não foi avaliado pelo cliente
      if (contract.rateByClient != null) {
        return const Left(ValidationFailure('Contrato já foi avaliado pelo cliente'));
      }

      // Criar RatingEntity com skippedRating = true
      final ratingEntity = RatingEntity(
        comment: null,
        rating: 0.0,
        isClientRating: true,
        skippedRating: true,
        ratedAt: null,
      );

      // Criar cópia do contrato com a avaliação pulada
      final updatedContract = contract.copyWith(
        rateByClient: ratingEntity,
      );

      // Atualizar contrato usando UpdateContractUseCase
      final updateResult = await updateContractUseCase.call(updatedContract);

      return updateResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

