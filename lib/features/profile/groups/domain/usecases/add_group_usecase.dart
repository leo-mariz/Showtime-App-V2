import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/groups/domain/repositories/groups_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Adicionar novo grupo
/// 
/// RESPONSABILIDADES:
/// - Validar UID do grupo
/// - Validar dados do grupo
/// - Adicionar grupo no repositório
class AddGroupUseCase {
  final IGroupsRepository repository;

  AddGroupUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(String uid, GroupEntity group) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do grupo não pode ser vazio'));
      }

      // Adicionar grupo
      final result = await repository.addGroup(uid, group);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
