import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/features/authentication/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

class GetUserUidUseCase {
  final IAuthRepository repository;
  final IAuthServices authServices;

  GetUserUidUseCase({required this.repository, required this.authServices});

  Future<Either<Failure, String?>> call() async {
    try {
      // Primeiro tenta do cache
      final cachedUidResult = await repository.getUserUid();
      final cachedUid = cachedUidResult.fold(
        (failure) => throw failure,
        (uid) => uid,
      );
      
      if (cachedUid != null && cachedUid.isNotEmpty) {
        return Right(cachedUid);
      }
      
      // Se não encontrou no cache, tenta do Firebase Auth
      final firebaseUid = await authServices.getUserUid();
      if (firebaseUid != null && firebaseUid.isNotEmpty) {
        return Right(firebaseUid);
      }
      
      return const Left(AuthFailure('UID do usuário não encontrado'));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}