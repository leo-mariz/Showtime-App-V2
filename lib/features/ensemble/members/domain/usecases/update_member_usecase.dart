import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: atualizar um integrante.
class UpdateMemberUseCase {
  final IMembersRepository repository;

  UpdateMemberUseCase({required this.repository});

  Future<Either<Failure, void>> call(
    String artistId,
    String ensembleId,
    EnsembleMemberEntity member,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }
      if (member.id == null || member.id!.isEmpty) {
        return const Left(ValidationFailure('member.id é obrigatório'));
      }
      return await repository.update(
        artistId: artistId,
        ensembleId: ensembleId,
        member: member,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
