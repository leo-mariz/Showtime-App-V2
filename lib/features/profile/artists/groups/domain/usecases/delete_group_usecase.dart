import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artists/groups/domain/repositories/groups_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Deletar grupo
/// 
/// RESPONSABILIDADES:
/// - Validar UID do grupo
/// - Deletar grupo no repositório
class DeleteGroupUseCase {
  final IGroupsRepository repository;

  DeleteGroupUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(String uid) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do grupo não pode ser vazio'));
      }

      // Deletar grupo
      final result = await repository.deleteGroup(uid);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
