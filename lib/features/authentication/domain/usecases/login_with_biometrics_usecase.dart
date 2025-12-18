import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Login com biometria
/// 
/// RESPONSABILIDADES:
/// - Verificar se biometria está habilitada
/// - Autenticar com biometria
/// - Recuperar credenciais salvas
/// - Fazer login usando LoginUseCase
class LoginWithBiometricsUseCase {
  final IBiometricAuthService biometricService;
  final LoginUseCase loginUseCase;

  LoginWithBiometricsUseCase({
    required this.biometricService,
    required this.loginUseCase,
  });

  Future<Either<Failure, bool>> call() async {
    try {
      // 1. Verificar se biometria está habilitada
      final isEnabled = await biometricService.isBiometricsEnabled();
      
      if (!isEnabled) {
        return const Left(AuthFailure('Biometria não habilitada'));
      }

      // 2. Autenticar com biometria
      final didAuthenticate = await biometricService.authenticateWithBiometrics();
      
      if (!didAuthenticate) {
        return const Left(AuthFailure('Biometria incorreta'));
      }

      // 3. Recuperar credenciais salvas
      final credentials = await biometricService.getCredentials();
      
      if (credentials == null) {
        return const Left(AuthFailure('Erro ao obter credenciais'));
      }

      final email = credentials[SecureStorageKeys.email];
      final password = credentials[SecureStorageKeys.password];
      final isArtistStr = credentials[SecureStorageKeys.isArtist];

      if (email == null || password == null || isArtistStr == null) {
        return const Left(AuthFailure('Credenciais incompletas'));
      }

      final isArtist = isArtistStr == 'true';

      // 4. Fazer login usando LoginUseCase
      final user = UserEntity(
        email: email,
        password: password,
        isArtist: isArtist,
      );

      final loginResult = await loginUseCase.call(user);

      return loginResult.fold(
        (failure) => Left(failure),
        (_) => Right(isArtist),
      );
    } catch (e) {
      // Em caso de erro, desabilitar biometria por segurança
      try {
        await biometricService.disableBiometrics();
      } catch (_) {
        // Ignora erro ao desabilitar
      }

      return Left(ErrorHandler.handle(e));
    }
  }
}

