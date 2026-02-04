import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_members_usecase.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_member_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

const String _logTag = '[DeleteMemberUseCase]';

/// Use case: remover um integrante.
/// Antes de deletar o documento do membro, remove-o da lista de membros
/// de todos os conjuntos em [EnsembleMemberEntity.ensembleIds].
class DeleteMemberUseCase {
  final IMembersRepository repository;
  final GetMemberUseCase getMemberUseCase;
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleMembersUseCase updateEnsembleMembersUseCase;

  DeleteMemberUseCase({
    required this.repository,
    required this.getMemberUseCase,
    required this.getEnsembleUseCase,
    required this.updateEnsembleMembersUseCase,
  });

  Future<Either<Failure, void>> call(
    String artistId,
    String memberId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('$_logTag call(artistId=$artistId, memberId=$memberId)');
      }
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (memberId.isEmpty) {
        return const Left(ValidationFailure('memberId é obrigatório'));
      }

      final getMemberResult = await getMemberUseCase.call(
        artistId,
        memberId,
        forceRemote: true,
      );
      return await getMemberResult.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint('$_logTag getMember falhou: ${failure.message}');
          }
          return Left(failure);
        },
        (member) async {
          if (member == null) {
            if (kDebugMode) debugPrint('$_logTag membro não encontrado (null)');
            return const Left(NotFoundFailure('Integrante não encontrado'));
          }

          final ensembleIds = member.ensembleIds;
          if (kDebugMode) {
            debugPrint(
              '$_logTag membro obtido: id=${member.id}, name=${member.name}, '
              'ensembleIds=$ensembleIds (isEmpty=${ensembleIds?.isEmpty ?? true})',
            );
          }

          if (ensembleIds?.isNotEmpty ?? false) {
            for (final ensembleId in ensembleIds ?? []) {
              if (kDebugMode) {
                debugPrint('$_logTag processando ensembleId=$ensembleId');
              }
              final getEnsembleResult =
                  await getEnsembleUseCase.call(artistId, ensembleId);
              final Either<Failure, void> updatedResult =
                  await getEnsembleResult.fold(
                (failure) {
                  if (kDebugMode) {
                    debugPrint(
                      '$_logTag getEnsemble($ensembleId) falhou: ${failure.message}',
                    );
                  }
                  return Future.value(Left<Failure, void>(failure));
                },
                (ensemble) async {
                  if (ensemble == null) {
                    if (kDebugMode) {
                      debugPrint('$_logTag getEnsemble($ensembleId) retornou null');
                    }
                    return const Right(null);
                  }
                  final currentMembers = ensemble.members ?? [];
                  final newMembers =
                      currentMembers.where((m) => m.id != memberId).toList();
                  if (kDebugMode) {
                    debugPrint(
                      '$_logTag ensemble $ensembleId: currentMembers.length=${currentMembers.length}, '
                      'newMembers.length=${newMembers.length}, '
                      'ids atuais=${currentMembers.map((m) => m.id).toList()}',
                    );
                  }
                  final result = await updateEnsembleMembersUseCase.call(
                    artistId,
                    ensembleId,
                    newMembers,
                  );
                  if (kDebugMode) {
                    result.fold(
                      (f) => debugPrint(
                        '$_logTag updateEnsembleMembers($ensembleId) falhou: ${f.message}',
                      ),
                      (_) => debugPrint(
                        '$_logTag updateEnsembleMembers($ensembleId) ok',
                      ),
                    );
                  }
                  return result;
                },
              );
              final didFail = updatedResult.fold((_) => true, (_) => false);
              if (didFail) {
                return updatedResult;
              }
            }
          } else if (kDebugMode) {
            debugPrint(
              '$_logTag ensembleIds vazio ou null, pulando remoção dos conjuntos',
            );
          }

          if (kDebugMode) debugPrint('$_logTag chamando repository.delete');
          return await repository.delete(
            artistId: artistId,
            memberId: memberId,
          );
        },
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('$_logTag exceção: $e');
        debugPrint('$_logTag stackTrace: $st');
      }
      return Left(ErrorHandler.handle(e));
    }
  }
}
