import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/firebase_functions_service.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Aceitar uma solicitação de contrato
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Buscar contrato existente
/// - Validar que o contrato está pendente
/// - Alterar status para accepted
/// - Adicionar timestamp de aceitação
/// - Atualizar contrato no repositório
class AcceptContractUseCase {
  final IContractRepository repository;
  final IFirebaseFunctionsService firebaseFunctionsService;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;

  AcceptContractUseCase({
    required this.repository,
    required this.firebaseFunctionsService,
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

      // Criar pagamento no Mercado Pago
      final paymentLink = await firebaseFunctionsService.createMercadoPagoPayment(
        contract.uid!,
        false,
      );

      // Criar cópia do contrato com status aceito
      final updatedContract = contract.copyWith(
        status: ContractStatusEnum.paymentPending,
        acceptedAt: DateTime.now(),
        linkPayment: paymentLink,
        statusChangedAt: DateTime.now(),
      );

      // Atualizar contrato
      final updateResult = await repository.updateContract(updatedContract);

      return updateResult.fold(
        (failure) => Left(failure),
        (_) async {
          // Atualizar índice de contratos (não bloqueia se falhar)
          if (updateContractsIndexUseCase != null) {
            await updateContractsIndexUseCase!.call(
              contract: updatedContract,
              oldStatus: contract.status,
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

