import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_member.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: atualizar os talentos de um integrante dentro do conjunto.
class UpdateEnsembleMemberTalentsUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;

  UpdateEnsembleMemberTalentsUseCase({
    required this.getEnsembleUseCase,
    required this.updateEnsembleUseCase,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    String ensembleId,
    String memberId,
    List<String> talents,
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
      if (talents.isEmpty) {
        return const Left(ValidationFailure('talents é obrigatório'));
      }
      final getResult = await getEnsembleUseCase.call(artistId, ensembleId);
      return await getResult.fold(
        (failure) => Left(failure),
        (ensemble) async {
          if (ensemble == null) {
            return const Left(NotFoundFailure('Conjunto não encontrado'));
          }
          final members = ensemble.members ?? [];
          final slotIndex = members.indexWhere((m) => m.memberId == memberId);
          if (slotIndex < 0) {
            return const Left(NotFoundFailure('Integrante não encontrado'));
          }
          final membersUpdated = <EnsembleMember>[
            for (var i = 0; i < members.length; i++)
              i == slotIndex
                  ? members[i].copyWith(specialty: talents)
                  : members[i],
          ];
          final updatedEnsemble = ensemble.copyWith(
            members: membersUpdated,
            updatedAt: DateTime.now(),
          );
          final updateResult =
              await updateEnsembleUseCase.call(artistId, updatedEnsemble);
          return updateResult.fold(
            (failure) => Left(failure),
            (_) => Right(updatedEnsemble),
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
