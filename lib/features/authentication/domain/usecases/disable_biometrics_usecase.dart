import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/biometric_auth_service.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Desabilitar autenticação por biometria
/// 
/// RESPONSABILIDADES:
/// - Verificar se biometria está habilitada
/// - Desabilitar biometria
/// - Remover credenciais salvas do armazenamento seguro
class DisableBiometricsUseCase {
  final IBiometricAuthService biometricService;

  DisableBiometricsUseCase({
    required this.biometricService,
  });

  Future<Either<Failure, void>> call() async {
    try {
      // 1. Verificar se biometria está habilitada
      final isEnabled = await biometricService.isBiometricsEnabled();
      
      if (!isEnabled) {
        // Biometria já está desabilitada, estado desejado já foi alcançado
        // Retornar sucesso silenciosamente
        return const Right(null);
      }

      // 2. Desabilitar biometria e remover credenciais
      await biometricService.disableBiometrics();

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

