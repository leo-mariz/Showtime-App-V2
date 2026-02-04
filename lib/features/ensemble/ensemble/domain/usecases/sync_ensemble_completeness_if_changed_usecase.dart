import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/ensemble_completeness_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_completeness_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_incomplete_sections_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

/// Sincroniza a completude do conjunto apenas se houver mudanças.
///
/// Compara a completude calculada com [EnsembleEntity.hasIncompleteSections] e
/// [EnsembleEntity.incompleteSections]; atualiza no Firestore só quando forem diferentes.
class SyncEnsembleCompletenessIfChangedUseCase {
  final GetEnsembleCompletenessUseCase getEnsembleCompletenessUseCase;
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleIncompleteSectionsUseCase updateEnsembleIncompleteSectionsUseCase;

  SyncEnsembleCompletenessIfChangedUseCase({
    required this.getEnsembleCompletenessUseCase,
    required this.getEnsembleUseCase,
    required this.updateEnsembleIncompleteSectionsUseCase,
  });

  /// [artistId] dono do conjunto, [ensembleId] ID do conjunto.
  /// Retorna true se houve atualização, false se não havia mudança.
  Future<Either<Failure, bool>> call(String artistId, String ensembleId) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }

      final completenessResult = await getEnsembleCompletenessUseCase.call(
        artistId,
        ensembleId,
      );
      final ensembleResult = await getEnsembleUseCase.call(artistId, ensembleId);

      return await completenessResult.fold(
        (f) => Left(f),
        (completeness) async {
          return await ensembleResult.fold(
            (f) => Left(f),
            (current) async {
              if (current == null) {
                return const Left(NotFoundFailure('Conjunto não encontrado'));
              }
              final hasChanged = _hasCompletenessChanged(current, completeness);
              debugPrint('[SyncEnsembleCompleteness] ensembleId=$ensembleId hasChanged=$hasChanged current.hasIncomplete=${current.hasIncompleteSections} current.keys=${current.incompleteSections?.keys.toList()}');
              debugPrint('[SyncEnsembleCompleteness] newIncomplete=${completeness.incompleteStatuses.map((s) => s.type.name).toList()}');
              if (!hasChanged) {
                return const Right(false);
              }
              debugPrint('[SyncEnsembleCompleteness] chamando updateEnsembleIncompleteSections');
              final updateResult = await updateEnsembleIncompleteSectionsUseCase.call(
                artistId,
                ensembleId,
                completeness,
              );
              return updateResult.fold(
                (f) => Left(f),
                (_) => const Right(true),
              );
            },
          );
        },
      );
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ErrorHandler.handle(e));
    }
  }

  bool _hasCompletenessChanged(
    EnsembleEntity current,
    EnsembleCompletenessEntity newCompleteness,
  ) {
    final expected = <String, List<String>>{};
    for (final status in newCompleteness.incompleteStatuses) {
      expected[status.type.name] = [status.type.name];
    }
    for (final key in expected.keys) {
      expected[key]!.sort();
    }
    final expectedHasIncomplete = expected.isNotEmpty;
    final currentSections = current.incompleteSections ?? <String, List<String>>{};
    if (current.hasIncompleteSections != expectedHasIncomplete) {
      debugPrint('[SyncEnsembleCompleteness] _hasChanged true: hasIncomplete current=${current.hasIncompleteSections} expected=$expectedHasIncomplete');
      return true;
    }
    final currentSorted = <String, List<String>>{};
    for (final e in currentSections.entries) {
      currentSorted[e.key] = List<String>.from(e.value)..sort();
    }
    if (currentSorted.length != expected.length) {
      debugPrint('[SyncEnsembleCompleteness] _hasChanged true: length current=${currentSorted.length} expected=${expected.length}');
      return true;
    }
    for (final key in expected.keys) {
      if (!currentSorted.containsKey(key)) {
        debugPrint('[SyncEnsembleCompleteness] _hasChanged true: expected key $key missing in current');
        return true;
      }
      final a = expected[key]!;
      final b = currentSorted[key]!;
      if (a.length != b.length) return true;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return true;
      }
    }
    for (final key in currentSorted.keys) {
      if (!expected.containsKey(key)) {
        debugPrint('[SyncEnsembleCompleteness] _hasChanged true: current key $key not in expected');
        return true;
      }
    }
    debugPrint('[SyncEnsembleCompleteness] _hasChanged false');
    return false;
  }
}
