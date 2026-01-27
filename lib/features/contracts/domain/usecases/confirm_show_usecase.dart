import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/get_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contract_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Confirmar show realizado com código de confirmação
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Validar código de confirmação
/// - Buscar contrato existente
/// - Validar que o contrato está pago (PAID)
/// - Validar código de confirmação
/// - Alterar status para COMPLETED
/// - Adicionar timestamp de confirmação (showConfirmedAt)
/// - Atualizar contrato usando UpdateContractUseCase
class ConfirmShowUseCase {
  final GetContractUseCase getContractUseCase;
  final UpdateContractUseCase updateContractUseCase;
  final IContractRepository contractRepository;

  ConfirmShowUseCase({
    required this.getContractUseCase,
    required this.updateContractUseCase,
    required this.contractRepository,
  });

  Future<Either<Failure, void>> call({
    required String contractUid,
    required String confirmationCode,
  }) async {
    try {
      // Validar UID do contrato
      if (contractUid.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }

      // Validar código de confirmação
      if (confirmationCode.isEmpty) {
        return const Left(ValidationFailure('Código de confirmação não pode ser vazio'));
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

      // Validar que o contrato está pago (PAID)
      if (contract.status != ContractStatusEnum.paid) {
        return Left(ValidationFailure(
          'Apenas contratos pagos podem ser confirmados. Status atual: ${contract.status.value}'
        ));
      }

      // Validar que o contrato tem código
      final keyCodeResult = await contractRepository.getKeyCode(contractUid);
      if (keyCodeResult.isLeft()) {
        return const Left(ValidationFailure('Contrato não possui código de confirmação'));
      }

      // Validar código de confirmação (case-insensitive)
      final normalizedInputCode = confirmationCode.trim().toUpperCase();
      final normalizedContractCode = keyCodeResult.fold(
        (failure) => null,
        (keyCode) => keyCode?.trim().toUpperCase(),
      );


      if (normalizedInputCode != normalizedContractCode) {
        return const Left(ValidationFailure('Código de confirmação inválido'));
      }

      // Criar cópia do contrato com status completado
      final updatedContract = contract.copyWith(
        status: ContractStatusEnum.completed,
        keyCode: confirmationCode,
        showConfirmedAt: DateTime.now(),
        statusChangedAt: DateTime.now(),
      );

      // Atualizar contrato usando UpdateContractUseCase
      // O UpdateContractUseCase já atualiza o índice automaticamente
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

