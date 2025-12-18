import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/features/authentication/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// Resultado da operação de habilitar biometria
enum BiometricsResult {
  enabledSuccessfully,
  alreadyEnabled,
  notAvailable,
  disabledSuccessfully,
  enableFailed,
}

/// UseCase: Habilitar autenticação por biometria
/// 
/// RESPONSABILIDADES:
/// - Verificar disponibilidade de biometria no dispositivo
/// - Verificar se biometria já está habilitada
/// - Autenticar com biometria
/// - Salvar credenciais criptografadas
class EnableBiometricsUseCase {
  final IAuthRepository repository;
  final IAuthServices authServices;
  final IBiometricAuthService biometricService;

  EnableBiometricsUseCase({
    required this.repository,
    required this.authServices,
    required this.biometricService,
  });

  Future<Either<Failure, BiometricsResult>> call(UserEntity user) async {
    try {
      // 1. Verificar se biometria está disponível no dispositivo
      final canCheckBiometrics = await biometricService.canCheckBiometrics();
      final isDeviceSupported = await biometricService.isDeviceSupported();
      final canAuthenticate = canCheckBiometrics || isDeviceSupported;

      if (!canAuthenticate) {
        return const Right(BiometricsResult.notAvailable);
      }

      // 2. Verificar se biometria já está habilitada
      final isEnabled = await biometricService.isBiometricsEnabled();
      if (isEnabled) {
        return const Right(BiometricsResult.alreadyEnabled);
      }

      // 3. Autenticar com biometria
      try {
        final didAuthenticate = await biometricService.authenticateWithBiometrics();
        
        if (!didAuthenticate) {
          return const Right(BiometricsResult.disabledSuccessfully);
        }

        // 4. Salvar credenciais criptografadas
        await biometricService.enableBiometrics(
          user.email,
          user.password ?? '',
          user.isArtist ?? false,
        );

        return const Right(BiometricsResult.enabledSuccessfully);
      } catch (e) {
        // Em caso de erro, fazer logout e limpar cache por segurança
        await authServices.logout();
        await repository.clearCache();
        return const Right(BiometricsResult.enableFailed);
      }
    } catch (e) {
      // Em caso de erro crítico, fazer logout e limpar cache
      await authServices.logout();
      await repository.clearCache();
      
      return Left(ErrorHandler.handle(e));
    }
  }
}

