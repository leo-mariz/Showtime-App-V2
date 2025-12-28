import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se novo email está verificado (para mudança de email)
/// 
/// RESPONSABILIDADES:
/// - Recarregar dados do usuário
/// - Verificar se novo email está verificado
class CheckNewEmailVerifiedUseCase {
  final IAuthServices authServices;

  CheckNewEmailVerifiedUseCase({
    required this.authServices,
  });

  Future<Either<Failure, bool>> call(String newEmail) async {
    try {
      // 1. Validar email
      if (newEmail.isEmpty) {
        return const Left(ValidationFailure('Email não pode ser vazio'));
      }

      // 2. Recarregar dados do usuário para obter status atualizado
      await authServices.reloadUser();

      // 3. Verificar se email está verificado
      final isVerified = await authServices.isEmailVerified();

      return Right(isVerified);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

