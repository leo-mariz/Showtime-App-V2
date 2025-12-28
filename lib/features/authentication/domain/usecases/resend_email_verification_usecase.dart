import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Reenviar email de verificação
/// 
/// RESPONSABILIDADES:
/// - Verificar se usuário está autenticado
/// - Reenviar email de verificação
class ResendEmailVerificationUseCase {
  final IAuthServices authServices;

  ResendEmailVerificationUseCase({
    required this.authServices,
  });

  Future<Either<Failure, void>> call() async {
    try {
      // 1. Verificar se usuário está autenticado
      final isLoggedIn = await authServices.isUserLoggedIn();
      
      if (!isLoggedIn) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // 2. Reenviar email de verificação
      await authServices.sendEmailVerification();

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

