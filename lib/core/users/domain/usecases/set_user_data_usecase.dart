import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:app/core/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Salvar dados do usuário
/// 
/// RESPONSABILIDADES:
/// - Validar dados do usuário
/// - Salvar dados no Firestore e cache
class SetUserDataUseCase {
  final IUsersRepository usersRepository;

  SetUserDataUseCase({
    required this.usersRepository,
  });

  Future<Either<Failure, void>> call(UserEntity user) async {
    try {
      // Validar email
      if (user.email.isEmpty) {
        return const Left(ValidationFailure('Email não pode ser vazio'));
      }

      // Salvar dados do usuário
      final result = await usersRepository.setUserData(user);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

