import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/users/domain/entities/cpf/cpf_user_entity.dart';
import 'package:app/core/users/domain/usecases/get_user_data_usecase.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: criar um integrante no pool do artista.
/// Antes de criar, verifica duplicidade de CPF consultando a lista completa.
class CreateMemberUseCase {
  final IMembersRepository repository;
  final GetUserDataUseCase getUserDataUseCase;

  CreateMemberUseCase({required this.repository, required this.getUserDataUseCase});

  Future<Either<Failure, EnsembleMemberEntity>> call({
    required String artistId,
    required EnsembleMemberEntity member,
  }) async {
    try {
      final userData = await getUserDataUseCase.call(artistId);
      final user = userData.fold(
        (_) => throw Exception('Usuário não encontrado'),
        (user) => user,
      );
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      final cpf = member.cpf?.trim() ?? '';
      if (cpf.isEmpty) {
        return const Left(ValidationFailure('cpf é obrigatório'));
      }
      if (user.cpfUser != null && user.cpfUser != CpfUserEntity()) {
        if (user.cpfUser?.cpf == cpf) {
          return const Left(ValidationFailure('Você já possui um integrante com este CPF.'));
        }
      }
      final existing = await repository.getAll(
        artistId: artistId,
        forceRemote: true,
      );
      final duplicated = existing.fold<List<EnsembleMemberEntity>>(
        (_) => [],
        (list) => list,
      );
      final alreadyExists = duplicated.any(
        (current) => (current.cpf ?? '').trim() == cpf,
      );
      if (alreadyExists) {
        return const Left(
          ValidationFailure('Já existe um integrante com este CPF.'),
        );
      }
      final sanitized = member.copyWith(ensembleIds: []);
      return await repository.create(
        artistId: artistId,
        member: sanitized,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
