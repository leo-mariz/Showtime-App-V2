// import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Logout do usuário
/// 
/// RESPONSABILIDADES:
/// - Deslogar do Firebase Auth
/// - Limpar cache local
/// - Opcionalmente desabilitar biometria
class LogoutUseCase {
  final IAuthRepository authRepository;
  final IAuthServices authServices;
  final IBiometricAuthService? biometricService;

  LogoutUseCase({
    required this.authRepository,
    required this.authServices,
    this.biometricService,
  });

  Future<Either<Failure, void>> call({bool resetBiometrics = false}) async {
    try {
      // 1. Deslogar do Firebase Auth
      await authServices.logout();

      // 2. Limpar cache local
      final clearResult = await authRepository.clearCache();
      clearResult.fold(
        (failure) => throw failure,
        (_) async{
          // await authRepository.printCache(DocumentsEntityReference.cachedKey());
        },
      );

      // 3. Desabilitar biometria se solicitado
      if (resetBiometrics && biometricService != null) {
        await biometricService!.disableBiometrics();
      }

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

