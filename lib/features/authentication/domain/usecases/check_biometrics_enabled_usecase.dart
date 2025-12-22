import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se biometria está habilitada
/// 
/// RESPONSABILIDADES:
/// - Verificar se biometria está habilitada no dispositivo
/// - Retornar true/false de forma segura
class CheckBiometricsEnabledUseCase {
  final IBiometricAuthService biometricService;

  CheckBiometricsEnabledUseCase({
    required this.biometricService,
  });

  Future<Either<Failure, bool>> call() async {
    try {
      final isEnabled = await biometricService.isBiometricsEnabled();
      return Right(isEnabled);
    } catch (e) {
      // Em caso de erro, retornar false (não é crítico)
      return const Right(false);
    }
  }
}

