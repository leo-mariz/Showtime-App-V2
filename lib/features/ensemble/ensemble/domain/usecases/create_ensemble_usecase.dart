import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/create_empty_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/sync_ensemble_completeness_if_changed_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/update_member_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: criar um conjunto a partir do DTO de entrada.
///
/// Lógica:
/// 1. Cria o grupo (vazio) para obter o ensembleId.
/// 2. Adiciona o ensembleId à lista ensembleIds de cada membro e atualiza o conjunto.
/// 3. Persiste o campo ensembleIds em cada documento do membro no Firestore.
/// 4. Sincroniza completude do conjunto (hasIncompleteSections / incompleteSections) se mudou.
///
class CreateEnsembleUseCase {
  final CreateEmptyEnsembleUseCase createEmptyEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;
  final UpdateMemberUseCase updateMemberUseCase;
  final SyncEnsembleCompletenessIfChangedUseCase syncEnsembleCompletenessIfChangedUseCase;

  CreateEnsembleUseCase({
    required this.createEmptyEnsembleUseCase,
    required this.updateEnsembleUseCase,
    required this.updateMemberUseCase,
    required this.syncEnsembleCompletenessIfChangedUseCase,
    required IEnsembleRepository repository,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    List<EnsembleMemberEntity> members,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }

      final createdResult = await createEmptyEnsembleUseCase.call(artistId);
      return await createdResult.fold(
        (f) async => Left(f),
        (created) async {
          final ensembleId = created.id ?? '';
          final membersWithEnsembleId = <EnsembleMemberEntity>[];
          membersWithEnsembleId.add(EnsembleMemberEntity(
            isOwner: true,
            artistId: artistId,
            isApproved: true,
          ));
          for (final member in members) {
            final memberWithEnsembleId = member.copyWith(
              ensembleIds: [...(member.ensembleIds ?? []), ensembleId],
            );
            membersWithEnsembleId.add(memberWithEnsembleId);
          }

          final ensembleWithMembers =
              created.copyWith(members: membersWithEnsembleId);
          final updateResult = await updateEnsembleUseCase.call(
            artistId,
            ensembleWithMembers,
          );
          final failUpdate = updateResult.fold((f) => f, (_) => null);
          if (failUpdate != null) return Left(failUpdate);

          for (final member in membersWithEnsembleId) {
            if (member.isOwner || member.id == null || member.id!.isEmpty) {
              continue;
            }
            final updateMemberResult = await updateMemberUseCase.call(
              artistId: artistId,
              member: member,
            );
            final failMember = updateMemberResult.fold((f) => f, (_) => null);
            if (failMember != null) return Left(failMember);
          }

          await syncEnsembleCompletenessIfChangedUseCase.call(artistId, ensembleId);

          return Right(ensembleWithMembers);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
