import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/mercado_pago_service.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/cancel_contract_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Abrir link de pagamento do Mercado Pago
/// 
/// RESPONSABILIDADES:
/// - Validar link de pagamento
/// - Abrir checkout do Mercado Pago usando o serviço
class MakePaymentUseCase {
  final MercadoPagoService mercadoPagoService;
  final IContractRepository repository;
  final CancelContractUseCase cancelContractUseCase;

  MakePaymentUseCase({
    required this.mercadoPagoService,
    required this.repository,
    required this.cancelContractUseCase,
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

      // Verificar se não existe slot BOOKED no horário antes de abrir o pagamento
      // final overlapResult = await repository.checkContractOverlapWithBooked(contractUid);
      // final hasOverlap = overlapResult.fold((failure) => null, (overlap) => overlap);
      // if (hasOverlap == null) return overlapResult.fold((l) => Left(l), (_) => throw StateError('unreachable'));
      // if (hasOverlap) {
      //   await cancelContractUseCase.call(contractUid: contractUid, canceledBy: 'ARTIST', cancelReason: 'Horário já está reservado por outro show.');
      //   return Left(ValidationFailure(
      //     'Este horário já está reservado por outro show.',
      //   ));
      // }

      final updatedContract = contract.copyWith(
        isPaying: true,
      );

      final updateResult = await repository.updateContract(updatedContract);

      return updateResult.fold(
        (failure) => Left(failure),
        (_) async {
            if (linkPayment.isEmpty) {
            return const Left(ValidationFailure('Link de pagamento não pode ser vazio'));
          }

          // Validar se é uma URL válida
          final uri = Uri.tryParse(linkPayment);
          if (uri == null || !uri.hasScheme) {
            return const Left(ValidationFailure('Link de pagamento inválido'));
          }

          // Abrir checkout do Mercado Pago
          await mercadoPagoService.openCheckout(linkPayment);

          return const Right(null); 
        }
      );

      // Validar link de pagamento
      
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

