import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_member.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/create_empty_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/sync_ensemble_completeness_if_changed_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/update_member_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: criar um conjunto a partir da lista de integrantes (slots).
///
/// [otherMembers]: integrantes não-dono (memberId + specialty). O dono é sempre o [artistId].
/// Lógica:
/// 1. Cria o grupo (vazio) para obter o ensembleId.
/// 2. Atualiza o conjunto com a lista de [EnsembleMember] (dono + outros).
/// 3. Para cada integrante não-dono, atualiza o documento do membro (ensembleIds) na feature members.
/// 4. Sincroniza completude do conjunto.
class CreateEnsembleUseCase {
  final CreateEmptyEnsembleUseCase createEmptyEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;
  final GetMemberUseCase getMemberUseCase;
  final UpdateMemberUseCase updateMemberUseCase;
  final SyncEnsembleCompletenessIfChangedUseCase syncEnsembleCompletenessIfChangedUseCase;

  CreateEnsembleUseCase({
    required this.createEmptyEnsembleUseCase,
    required this.updateEnsembleUseCase,
    required this.getMemberUseCase,
    required this.updateMemberUseCase,
    required this.syncEnsembleCompletenessIfChangedUseCase,
    required IEnsembleRepository repository,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    List<EnsembleMember> otherMembers,
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
          final ownerSlot = EnsembleMember(
            memberId: artistId,
            specialty: null,
            isOwner: true,
          );
          final members = [ownerSlot, ...otherMembers];

          final ensembleWithMembers = created.copyWith(members: members);
          final updateResult = await updateEnsembleUseCase.call(
            artistId,
            ensembleWithMembers,
          );
          final failUpdate = updateResult.fold((f) => f, (_) => null);
          if (failUpdate != null) return Left(failUpdate);

          for (final slot in otherMembers) {
            final getResult = await getMemberUseCase.call(
              artistId,
              slot.memberId,
              forceRemote: true,
            );
            await getResult.fold(
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

          await syncEnsembleCompletenessIfChangedUseCase.call(artistId, ensembleId);

          return Right(ensembleWithMembers);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
