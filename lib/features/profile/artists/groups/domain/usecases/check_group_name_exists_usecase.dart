import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artists/groups/domain/repositories/groups_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se nome do grupo já existe no banco de dados
/// 
/// RESPONSABILIDADES:
/// - Validar nome do grupo
/// - Verificar existência no banco de dados
/// - Excluir o próprio grupo da verificação (se excludeUid fornecido)
/// 
/// NOTA: Requer implementação do método groupNameExists no IGroupsRepository
class CheckGroupNameExistsUseCase {
  final IGroupsRepository repository;

  CheckGroupNameExistsUseCase({
    required this.repository,
  });

  Future<Either<Failure, bool>> call(
    String groupName, {
    String? excludeUid,
  }) async {
    try {
      // Validar nome do grupo
      if (groupName.isEmpty) {
        return const Left(ValidationFailure('Nome do grupo não pode ser vazio'));
      }

      // Verificar se existe no banco
      final result = await repository.groupNameExists(
        groupName,
      );

      return result.fold(
        (failure) => Left(failure),
        (exists) => Right(exists),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

