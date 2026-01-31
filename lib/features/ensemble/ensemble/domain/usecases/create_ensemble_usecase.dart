import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/inputs/create_ensemble_input.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/create_empty_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/create_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_member_by_cpf_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: criar um conjunto a partir do DTO de entrada.
///
/// Lógica:
/// 1. GetMember (por CPF): verifica se o membro já existe na tabela de membros.
///    Se não existir, cria. Se existir, não faz nada.
/// 2. Adiciona os ids dos members à entidade do grupo.
/// 3. Cria o grupo (vazio) e em seguida atualiza com os integrantes.
///
/// Utiliza apenas outros use cases (não repositórios diretamente).
class CreateEnsembleUseCase {
  final CreateEmptyEnsembleUseCase createEmptyEnsembleUseCase;
  final GetMemberByCpfUseCase getMemberByCpfUseCase;
  final CreateMemberUseCase createMemberUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;

  CreateEnsembleUseCase({
    required this.createEmptyEnsembleUseCase,
    required this.getMemberByCpfUseCase,
    required this.createMemberUseCase,
    required this.updateEnsembleUseCase,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    CreateEnsembleInput input,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }

      // 3. Cria o grupo (vazio) primeiro para obter o ensembleId
      final createdResult = await createEmptyEnsembleUseCase.call(artistId);
      return await createdResult.fold(
        (f) async => Left(f),
        (created) async {
          final ensembleId = created.id ?? '';
          final collectedMembers = <EnsembleMemberEntity>[];

          // 1. Para cada membro do input: GetMember (CPF) -> se não existir, cria
          for (final m in input.members) {
            final getResult = await getMemberByCpfUseCase.call(
              artistId,
              m.cpf,
              forceRemote: true,
            );
            final failureGet = getResult.fold((f) => f, (_) => null);
            if (failureGet != null) return Left(failureGet);

            final existing = getResult.getOrElse(() => null);
            if (existing != null) {
              // Já existe: não cria, só adiciona à lista
              collectedMembers.add(existing);
            } else {
              // Não existe: cria no novo conjunto
              final memberEntity = EnsembleMemberEntity(
                ensembleId: ensembleId,
                isOwner: false,
                name: m.name,
                cpf: m.cpf,
                email: m.email,
                isApproved: false,
              );
              final createResult = await createMemberUseCase.call(
                artistId,
                ensembleId,
                memberEntity,
              );
              final failureCreate = createResult.fold((f) => f, (_) => null);
              if (failureCreate != null) return Left(failureCreate);
              collectedMembers.add(createResult.getOrElse(() => memberEntity));
            }
          }

          // 2. Adiciona os members à entidade do grupo e atualiza
          final ensembleWithMembers = created.copyWith(members: collectedMembers);
          final updateResult = await updateEnsembleUseCase.call(
            artistId,
            ensembleWithMembers,
          );
          return updateResult.fold(
            (f) => Left(f),
            (_) => Right(ensembleWithMembers),
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
