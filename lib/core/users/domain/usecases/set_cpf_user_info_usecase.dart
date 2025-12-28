import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/users/domain/entities/cpf/cpf_user_entity.dart';
import 'package:app/core/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Salvar dados CPF do usuário
/// 
/// RESPONSABILIDADES:
/// - Validar UID e dados CPF
/// - Salvar dados CPF no Firestore
class SetCpfUserInfoUseCase {
  final IUsersRepository usersRepository;

  SetCpfUserInfoUseCase({
    required this.usersRepository,
  });

  Future<Either<Failure, void>> call(String uid, CpfUserEntity cpfUser) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID não pode ser vazio'));
      }

      // Salvar dados CPF
      final result = await usersRepository.setCpfUserInfo(uid, cpfUser);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

