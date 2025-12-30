import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/core/users/domain/usecases/get_user_data_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase para reautenticar o usuário antes de acessar dados sensíveis
/// 
/// LÓGICA:
/// 1. Primeiro tenta reautenticar com biometria (se disponível e habilitada)
/// 2. Se biometria não disponível ou falhar, reautentica com senha
/// 3. Email é obtido via GetUserUidUseCase + GetUserDataUseCase
class ReauthenticateUserUseCase {
  final IAuthServices authServices;
  final IBiometricAuthService biometricService;
  final GetUserUidUseCase getUserUidUseCase;
  final GetUserDataUseCase getUserDataUseCase;

  ReauthenticateUserUseCase({
    required this.authServices,
    required this.biometricService,
    required this.getUserUidUseCase,
    required this.getUserDataUseCase,
  });

  /// Reautentica o usuário
  /// 
  /// [tryBiometrics] indica se deve tentar biometria primeiro (padrão: true)
  /// [password] é necessário apenas se biometria falhar ou não estiver disponível
  /// 
  /// Retorna:
  /// - Right(null) se sucesso
  /// - Left(ValidationFailure) se biometria falhou e precisa de senha
  /// - Left(AuthFailure) se senha está incorreta ou outro erro de autenticação
  Future<Either<Failure, void>> call({
    bool tryBiometrics = true,
    String? password,
  }) async {
    try {
      // 1. Tentar reautenticar com biometria primeiro (se solicitado)
      if (tryBiometrics) {
        final isBiometricsAvailable = await biometricService.isBiometricsAvailable();
        final isBiometricsEnabled = await biometricService.isBiometricsEnabled();

        if (isBiometricsAvailable && isBiometricsEnabled) {
          try {
            final didAuthenticate = await biometricService.authenticateWithBiometrics();
            
            if (didAuthenticate) {
              // Biometria bem-sucedida - obter credenciais e reautenticar
              final credentials = await biometricService.getCredentials();
              
              if (credentials != null) {
                final email = credentials[SecureStorageKeys.email];
                final savedPassword = credentials[SecureStorageKeys.password];
                
                if (email != null && savedPassword != null) {
                  await authServices.reauthenticateUser(email, savedPassword);
                  return const Right(null);
                }
              }
            }
            // Se biometria não autenticou, retornar ValidationFailure para indicar que precisa de senha
            return const Left(ValidationFailure('Biometria não autenticada. Senha necessária.'));
          } catch (e) {
            // Se biometria falhar, retornar ValidationFailure para indicar que precisa de senha
            return const Left(ValidationFailure('Biometria falhou. Senha necessária.'));
          }
        }
        // Se biometria não disponível, retornar ValidationFailure para indicar que precisa de senha
        return const Left(ValidationFailure('Biometria não disponível. Senha necessária.'));
      }

      // 2. Reautenticar com senha (quando biometria falhou ou não disponível)
      if (password == null || password.isEmpty) {
        return const Left(ValidationFailure('Senha é necessária para reautenticação'));
      }

      // Obter email do usuário atual
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (_) => null,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(AuthFailure('Usuário não encontrado'));
      }

      final userResult = await getUserDataUseCase.call(uid);
      final user = userResult.fold(
        (_) => null,
        (user) => user,
      );

      if (user == null || user.email.isEmpty) {
        return const Left(AuthFailure('Email do usuário não encontrado'));
      }

      await authServices.reauthenticateUser(user.email, password);

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
