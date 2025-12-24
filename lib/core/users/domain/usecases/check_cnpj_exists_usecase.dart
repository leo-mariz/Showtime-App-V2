import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/users/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se CNPJ já existe no banco de dados
/// 
/// RESPONSABILIDADES:
/// - Validar formato do CNPJ
/// - Verificar existência no banco de dados
class CheckCnpjExistsUseCase {
  final IUsersRepository usersRepository;

  CheckCnpjExistsUseCase({
    required this.usersRepository,
  });

  Future<Either<Failure, bool>> call(String cnpj) async {
    try {
      // Remover formatação do CNPJ
      final cleanCnpj = cnpj.replaceAll(RegExp(r'[^\d]'), '');

      // Validar se tem 14 dígitos
      if (cleanCnpj.length != 14) {
        return const Left(ValidationFailure('CNPJ deve conter 14 dígitos'));
      }

      // Verificar se existe no banco
      final result = await usersRepository.cnpjExists(cleanCnpj);

      return result.fold(
        (failure) => Left(failure),
        (exists) => Right(exists),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

