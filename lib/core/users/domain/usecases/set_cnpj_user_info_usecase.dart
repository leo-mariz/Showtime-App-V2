import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/users/domain/entities/cnpj/cnpj_user_entity.dart';
import 'package:app/core/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Salvar dados CNPJ do usuário
/// 
/// RESPONSABILIDADES:
/// - Validar UID e dados CNPJ
/// - Salvar dados CNPJ no Firestore
class SetCnpjUserInfoUseCase {
  final IUsersRepository usersRepository;

  SetCnpjUserInfoUseCase({
    required this.usersRepository,
  });

  Future<Either<Failure, void>> call(String uid, CnpjUserEntity cnpjUser) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID não pode ser vazio'));
      }

      // Salvar dados CNPJ
      final result = await usersRepository.setCnpjUserInfo(uid, cnpjUser);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

