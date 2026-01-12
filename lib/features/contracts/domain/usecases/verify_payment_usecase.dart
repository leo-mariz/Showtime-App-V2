import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/usecases/get_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contract_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar um contrato específico por UID
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Buscar contrato do repositório (cache primeiro, depois remoto)
/// - Retornar contrato encontrado
class VerifyPaymentUseCase {
  final GetContractUseCase getContractUseCase;
  final UpdateContractUseCase updateContractUseCase;

  VerifyPaymentUseCase({
    required this.getContractUseCase,
    required this.updateContractUseCase,
  });

  Future<Either<Failure, void>> call(String contractUid) async {
    try {
      final contractResult = await getContractUseCase.call(contractUid, forceRefresh: true);

      final contract = contractResult.fold(
        (failure) => null,
        (contract) => contract,
      );

      if (contract == null) {
        return const Left(NotFoundFailure('Contrato não encontrado'));
      }

      final updatedContract = contract.copyWith(
        isPaying: false,
      );

      await updateContractUseCase.call(updatedContract);

      if (updatedContract.status != ContractStatusEnum.paid) {
        return const Left(ValidationFailure('Pagamento não realizado. Caso já tenha realizado o pagamento, aguarde alguns minutos para o status ser atualizado.'));
      }

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

