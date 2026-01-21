import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/groups/domain/repositories/groups_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar dados do grupo
/// 
/// RESPONSABILIDADES:
/// - Validar UID do grupo
/// - Buscar grupo do repositório
/// - Retornar dados do grupo
class GetGroupUseCase {
  final IGroupsRepository repository;

  GetGroupUseCase({
    required this.repository,
  });

  Future<Either<Failure, GroupEntity>> call(String uid) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do grupo não pode ser vazio'));
      }

      // Buscar grupo
      final result = await repository.getGroup(uid);

      return result.fold(
        (failure) => Left(failure),
        (group) => Right(group),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
