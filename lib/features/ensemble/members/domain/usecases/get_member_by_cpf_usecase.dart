import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_all_members_by_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: buscar um integrante pelo CPF na tabela de membros do artista.
/// Usado ao criar conjunto para verificar se o membro já existe (evitar duplicar).
class GetMemberByCpfUseCase {
  final GetAllMembersByArtistUseCase getAllMembersByArtistUseCase;

  GetMemberByCpfUseCase({required this.getAllMembersByArtistUseCase});

  static String _normalizeCpf(String cpf) =>
      cpf.replaceAll(RegExp(r'[^\d]'), '');

  Future<Either<Failure, EnsembleMemberEntity?>> call(
    String artistId,
    String cpf, {
    bool forceRemote = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      final normalized = _normalizeCpf(cpf);
      if (normalized.isEmpty) {
        return const Right(null);
      }
      final result = await getAllMembersByArtistUseCase.call(
        artistId,
        forceRemote: forceRemote,
      );
      return result.fold(
        (f) => Left(f),
        (members) {
          EnsembleMemberEntity? found;
          for (final m in members) {
            if (_normalizeCpf(m.cpf ?? '') == normalized) {
              found = m;
              break;
            }
          }
          return Right(found);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
