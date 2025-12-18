import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Enviar email de recuperação de senha
/// 
/// RESPONSABILIDADES:
/// - Validar email
/// - Enviar email de recuperação via Firebase Auth
class SendPasswordResetEmailUseCase {
  final IAuthServices authServices;

  SendPasswordResetEmailUseCase({
    required this.authServices,
  });

  Future<Either<Failure, void>> call(String email) async {
    try {
      // 1. Validar email
      if (email.isEmpty) {
        return const Left(ValidationFailure('Email não pode ser vazio'));
      }

      // Validação básica de formato de email
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return const Left(ValidationFailure('Email inválido'));
      }

      // 2. Enviar email de recuperação
      await authServices.sendPasswordResetEmail(email);

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

