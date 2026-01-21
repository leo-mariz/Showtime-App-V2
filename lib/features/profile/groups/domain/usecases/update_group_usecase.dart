import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/groups/domain/repositories/groups_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar grupo
/// 
/// RESPONSABILIDADES:
/// - Validar UID do grupo
/// - Validar dados do grupo
/// - Atualizar grupo no repositório
class UpdateGroupUseCase {
  final IGroupsRepository repository;

  UpdateGroupUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(String uid, GroupEntity group) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do grupo não pode ser vazio'));
      }

      // Atualizar grupo
      final result = await repository.updateGroup(uid, group);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
