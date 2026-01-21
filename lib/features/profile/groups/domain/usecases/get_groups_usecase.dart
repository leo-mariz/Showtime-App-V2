import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/groups/domain/repositories/groups_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar todos os grupos
/// 
/// RESPONSABILIDADES:
/// - Buscar todos os grupos do repositório
/// - Retornar lista de grupos
class GetGroupsUseCase {
  final IGroupsRepository repository;

  GetGroupsUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<GroupEntity>>> call() async {
    try {
      // Buscar grupos
      final result = await repository.getGroups();

      return result.fold(
        (failure) => Left(failure),
        (groups) => Right(groups),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
