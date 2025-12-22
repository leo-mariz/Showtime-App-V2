import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se CPF já existe no banco de dados
/// 
/// RESPONSABILIDADES:
/// - Validar formato do CPF
/// - Verificar existência no banco de dados
class CheckCpfExistsUseCase {
  final IAuthRepository repository;

  CheckCpfExistsUseCase({
    required this.repository,
  });

  Future<Either<Failure, bool>> call(String cpf) async {
    try {
      // Remover formatação do CPF
      final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');

      // Validar se tem 11 dígitos
      if (cleanCpf.length != 11) {
        return const Left(ValidationFailure('CPF deve conter 11 dígitos'));
      }

      // Verificar se existe no banco
      final result = await repository.cpfExists(cleanCpf);

      return result.fold(
        (failure) => Left(failure),
        (exists) => Right(exists),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

