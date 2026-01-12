import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/mercado_pago_service.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Abrir link de pagamento do Mercado Pago
/// 
/// RESPONSABILIDADES:
/// - Validar link de pagamento
/// - Abrir checkout do Mercado Pago usando o serviço
class MakePaymentUseCase {
  final MercadoPagoService mercadoPagoService;

  MakePaymentUseCase({
    required this.mercadoPagoService,
  });

  Future<Either<Failure, void>> call({
    required String linkPayment,
  }) async {
    try {
      // Validar link de pagamento
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
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

