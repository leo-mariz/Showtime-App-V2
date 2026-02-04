import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: listar todos os integrantes cadastrados pelo artista.
/// Resultado pode vir do cache local ou remoto, dependendo do [forceRemote].
class GetAllMembersUseCase {
  final IMembersRepository membersRepository;

  GetAllMembersUseCase({required this.membersRepository});

  Future<Either<Failure, List<EnsembleMemberEntity>>> call(
    String artistId,
    {bool forceRemote = false}
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      return await membersRepository.getAll(
        artistId: artistId,
        forceRemote: forceRemote,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
