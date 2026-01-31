import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: remover um integrante.
class DeleteMemberUseCase {
  final IMembersRepository repository;

  DeleteMemberUseCase({required this.repository});

  Future<Either<Failure, void>> call(
    String artistId,
    String ensembleId,
    String memberId,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }
      if (memberId.isEmpty) {
        return const Left(ValidationFailure('memberId é obrigatório'));
      }
      return await repository.delete(
        artistId: artistId,
        ensembleId: ensembleId,
        memberId: memberId,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
