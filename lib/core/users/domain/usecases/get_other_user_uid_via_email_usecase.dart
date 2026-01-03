import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se email já existe no banco de dados
/// 
/// RESPONSABILIDADES:
/// - Validar formato do email
/// - Verificar existência no banco de dados
class GetOtherUserUidViaEmailUseCase {
  final IUsersRepository usersRepository;

  GetOtherUserUidViaEmailUseCase({
    required this.usersRepository,
  });

  Future<Either<Failure, String?>> call(String email) async {
    try {
      // Validar email
      if (email.isEmpty) {
        return const Left(ValidationFailure('Email não pode ser vazio'));
      }

      // Validar formato básico de email
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(email)) {
        return const Left(ValidationFailure('Email inválido'));
      }

      // Verificar se existe no banco
      final result = await usersRepository.getOtherUserUidViaEmail(email);

      return result.fold(
        (failure) => Left(failure),
        (uid) => Right(uid),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

