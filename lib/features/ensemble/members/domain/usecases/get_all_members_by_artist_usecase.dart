import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: listar todos os integrantes de todos os conjuntos do artista.
/// Usado no modal de seleção ao criar novo conjunto (pool de integrantes disponíveis).
class GetAllMembersByArtistUseCase {
  final IEnsembleRepository ensembleRepository;
  final IMembersRepository membersRepository;

  GetAllMembersByArtistUseCase({
    required this.ensembleRepository,
    required this.membersRepository,
  });

  Future<Either<Failure, List<EnsembleMemberEntity>>> call(
    String artistId, {
    bool forceRemote = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      final ensemblesResult = await ensembleRepository.getAllByArtist(
        artistId: artistId,
        forceRemote: forceRemote,
      );
      return await ensemblesResult.fold(
        (f) async => Left(f),
        (ensembles) async {
          final all = <EnsembleMemberEntity>[];
          for (final e in ensembles) {
            final id = e.id;
            if (id == null || id.isEmpty) continue;
            final membersResult = await membersRepository.getAllByEnsemble(
              artistId: artistId,
              ensembleId: id,
              forceRemote: forceRemote,
            );
            membersResult.fold(
              (_) {},
              (members) => all.addAll(members),
            );
          }
          return Right(all);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
