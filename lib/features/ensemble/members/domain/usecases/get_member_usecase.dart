import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: buscar um integrante do artista por ID.
class GetMemberUseCase {
  final IMembersRepository repository;

  GetMemberUseCase({required this.repository});

  Future<Either<Failure, EnsembleMemberEntity?>> call(
    String artistId,
    String memberId, {
    bool forceRemote = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (memberId.isEmpty) {
        return const Left(ValidationFailure('memberId é obrigatório'));
      }
      return await repository.getById(
        artistId: artistId,
        memberId: memberId,
        forceRemote: forceRemote,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
