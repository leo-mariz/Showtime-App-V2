import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/mercado_pago_service.dart';
import 'package:app/features/contracts/data/datasources/contracts_functions.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Abrir link de pagamento do Mercado Pago
/// 
/// RESPONSABILIDADES:
/// - Validar link de pagamento
/// - Abrir checkout do Mercado Pago usando o serviço
class MakePaymentUseCase {
  final MercadoPagoService mercadoPagoService;
  final IContractRepository repository;
  final IContractsFunctionsService contractsFunctions;

  MakePaymentUseCase({
    required this.mercadoPagoService,
    required this.repository,
    required this.contractsFunctions,
  });

  Future<Either<Failure, void>> call({
    required String contractUid,
    required String linkPayment,
  }) async {
    try {

      // Buscar contrato
      final result = await repository.getContract(contractUid, forceRefresh: true);

      final contract = result.fold(
        (failure) => null,
        (contract) => contract,
      );

      if (contract == null) {
        return const Left(NotFoundFailure('Contrato não encontrado'));
      }

      // Validar se o contrato está pendente
      if (contract.status != ContractStatusEnum.paymentPending) {
        return const Left(ValidationFailure('Contrato não está pendente de pagamento. Atualizando contrato...'));
      }

      // Etapa de segurança: verificar se o contrato ainda é aceitável (disponibilidade/overlap) antes de abrir pagamento
      final contractMap = contract.toMap();
      final acceptable = await contractsFunctions.verifyContract(contractMap);
      if (!acceptable) {
        return const Left(ValidationFailure(
          'Este horário não está mais disponível. Atualize o contrato ou escolha outra data.',
        ));
      }

      // isPaying é controlado apenas no app (cliente não escreve em contratos)

      if (linkPayment.isEmpty) {
        return const Left(ValidationFailure('Link de pagamento não pode ser vazio'));
      }
      final uri = Uri.tryParse(linkPayment);
      if (uri == null || !uri.hasScheme) {
        return const Left(ValidationFailure('Link de pagamento inválido'));
      }

      await mercadoPagoService.openCheckout(linkPayment);
      return const Right(null);
      
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

