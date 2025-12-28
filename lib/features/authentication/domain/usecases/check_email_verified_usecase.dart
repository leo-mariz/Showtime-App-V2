import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se email está verificado
/// 
/// RESPONSABILIDADES:
/// - Recarregar dados do usuário
/// - Verificar se email está verificado
class CheckEmailVerifiedUseCase {
  final IAuthServices authServices;

  CheckEmailVerifiedUseCase({
    required this.authServices,
  });

  Future<Either<Failure, bool>> call() async {
    try {
      // 1. Recarregar dados do usuário para obter status atualizado
      await authServices.reloadUser();

      // 2. Verificar se email está verificado
      final isVerified = await authServices.isEmailVerified();

      return Right(isVerified);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

