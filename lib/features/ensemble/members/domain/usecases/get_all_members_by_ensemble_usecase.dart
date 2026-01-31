import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: listar todos os integrantes do conjunto.
class GetAllMembersByEnsembleUseCase {
  final IMembersRepository repository;

  GetAllMembersByEnsembleUseCase({required this.repository});

  Future<Either<Failure, List<EnsembleMemberEntity>>> call(
    String artistId,
    String ensembleId, {
    bool forceRemote = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }
      return await repository.getAllByEnsemble(
        artistId: artistId,
        ensembleId: ensembleId,
        forceRemote: forceRemote,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
