import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_member.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/sync_ensemble_completeness_if_changed_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/update_member_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: atualizar a lista de integrantes vinculados a um conjunto.
/// Recebe lista de [EnsembleMember] (memberId + specialty + isOwner).
/// Sincroniza ensembleIds em cada documento do membro na feature members.
class UpdateEnsembleMembersUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;
  final GetMemberUseCase getMemberUseCase;
  final UpdateMemberUseCase updateMemberUseCase;
  final SyncEnsembleCompletenessIfChangedUseCase syncEnsembleCompletenessIfChangedUseCase;

  UpdateEnsembleMembersUseCase({
    required this.getEnsembleUseCase,
    required this.updateEnsembleUseCase,
    required this.getMemberUseCase,
    required this.updateMemberUseCase,
    required this.syncEnsembleCompletenessIfChangedUseCase,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    String ensembleId,
    List<EnsembleMember> members,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }
      final getResult = await getEnsembleUseCase.call(artistId, ensembleId);
      return await getResult.fold(
        (failure) => Left(failure),
        (ensemble) async {
          if (ensemble == null) {
            return const Left(NotFoundFailure('Conjunto não encontrado'));
          }
          final oldMembers = ensemble.members ?? [];
          final updated = ensemble.copyWith(
            members: members,
            updatedAt: DateTime.now(),
          );
          final updateEnsembleResult =
              await updateEnsembleUseCase.call(artistId, updated);
          final failEnsemble = updateEnsembleResult.fold((f) => f, (_) => null);
          if (failEnsemble != null) return Left(failEnsemble);

          final newIds = members
              .where((m) => !m.isOwner)
              .map((m) => m.memberId)
              .toSet();
          final oldIds = oldMembers
              .where((m) => !m.isOwner)
              .map((m) => m.memberId)
              .toSet();

          for (final slot in members) {
            if (slot.isOwner) continue;
            final getMemberResult = await getMemberUseCase.call(
              artistId,
              slot.memberId,
              forceRemote: true,
            );
            await getMemberResult.fold(
              (_) => null,
              (current) async {
                if (current == null) return;
                final ids = current.ensembleIds ?? [];
                if (ids.contains(ensembleId)) return;
                final updatedMember =
                    current.copyWith(ensembleIds: [...ids, ensembleId]);
                await updateMemberUseCase.call(
                  artistId: artistId,
                  member: updatedMember,
                );
              },
            );
          }

          for (final oldId in oldIds) {
            if (newIds.contains(oldId)) continue;
            final getMemberResult = await getMemberUseCase.call(
              artistId,
              oldId,
              forceRemote: true,
            );
            await getMemberResult.fold(
              (_) => null,
              (current) async {
                if (current == null) return;
                final ids = current.ensembleIds ?? [];
                if (!ids.contains(ensembleId)) return;
                final newList = ids.where((e) => e != ensembleId).toList();
                final updatedMember = current.copyWith(ensembleIds: newList);
                await updateMemberUseCase.call(
                  artistId: artistId,
                  member: updatedMember,
                );
              },
            );
          }

          await syncEnsembleCompletenessIfChangedUseCase.call(artistId, ensembleId);

          final refetch = await getEnsembleUseCase.call(artistId, ensembleId);
          return refetch.fold(
            (_) => Right(updated),
            (fetched) => Right(fetched ?? updated),
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
