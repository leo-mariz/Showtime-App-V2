import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se deve mostrar o prompt de biometria
/// 
/// RESPONSABILIDADES:
/// - Verificar se biometria está disponível no dispositivo
/// - Verificar se biometria já está habilitada
/// - Retornar se deve mostrar o prompt
class CheckShouldShowBiometricsPromptUseCase {
  final IBiometricAuthService biometricService;

  CheckShouldShowBiometricsPromptUseCase({
    required this.biometricService,
  });

  Future<Either<Failure, bool>> call() async {
    try {
      // 1. Verificar se biometria está disponível no dispositivo
      final isAvailable = await biometricService.isBiometricsAvailable();
      
      if (!isAvailable) {
        // Biometria não disponível (ex: emulador sem biometria configurada)
        // Retornar false silenciosamente, não é um erro
        return const Right(false);
      }

      // 2. Verificar se biometria já está habilitada
      final isEnabled = await biometricService.isBiometricsEnabled();
      
      if (isEnabled) {
        // Já está habilitada, não precisa mostrar prompt
        return const Right(false);
      }

      // 3. Se está disponível e não está habilitada, deve mostrar
      return const Right(true);
    } catch (e) {
      // Em caso de erro, não mostrar prompt (tratamento gracioso)
      // Não retornar Left para evitar quebrar o fluxo de login
      return const Right(false);
    }
  }
}

