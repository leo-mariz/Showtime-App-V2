import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:app/core/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar dados do usuário
/// 
/// RESPONSABILIDADES:
/// - Validar UID
/// - Buscar dados do usuário no Firestore
class GetUserDataUseCase {
  final IUsersRepository usersRepository;

  GetUserDataUseCase({
    required this.usersRepository,
  });

  Future<Either<Failure, UserEntity>> call(String uid) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID não pode ser vazio'));
      }

      // Buscar dados do usuário
      final result = await usersRepository.getUserData(uid);

      return result.fold(
        (failure) => Left(failure),
        (user) => Right(user),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

