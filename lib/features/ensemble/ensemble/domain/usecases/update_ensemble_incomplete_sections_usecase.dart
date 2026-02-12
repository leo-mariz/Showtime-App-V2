import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/ensemble_completeness_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/enums/ensemble_info_type_enum.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

/// Atualiza [hasIncompleteSections] e [incompleteSections] do conjunto no Firestore.
///
/// Converte [EnsembleCompletenessEntity] em Map por tipo e persiste no [EnsembleEntity].
class UpdateEnsembleIncompleteSectionsUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final IEnsembleRepository repository;

  UpdateEnsembleIncompleteSectionsUseCase({
    required this.getEnsembleUseCase,
    required this.repository,
  });

  /// [artistId] dono do conjunto, [ensembleId] ID do conjunto.
  Future<Either<Failure, void>> call(
    String artistId,
    String ensembleId,
    EnsembleCompletenessEntity completeness,
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
        (f) => Left(f),
        (current) async {
          if (current == null) {
            return const Left(NotFoundFailure('Conjunto não encontrado'));
          }

          final incompleteSections = <String, List<String>>{};
          for (final status in completeness.incompleteStatuses) {
            incompleteSections[status.type.name] = [status.type.name];
          }
          final hasIncomplete = incompleteSections.isNotEmpty;
          // Quando há seções incompletas, desativa a visibilidade do conjunto.
          final isActive = hasIncomplete ? false : (current.isActive ?? false);
          // Quando a seção incompleta é memberDocuments (documentos dos integrantes), garantir allMembersApproved = false.
          final hasMemberDocumentsIncomplete = incompleteSections.containsKey(EnsembleInfoType.memberDocuments.name);
          final allMembersApproved = hasMemberDocumentsIncomplete ? false : current.allMembersApproved;

          debugPrint('[UpdateEnsembleIncompleteSections] ensembleId=$ensembleId hasIncomplete=$hasIncomplete keys=${incompleteSections.keys.toList()} isActive=$isActive allMembersApproved=$allMembersApproved');
          debugPrint('[UpdateEnsembleIncompleteSections] current.hasIncomplete=${current.hasIncompleteSections} current.keys=${current.incompleteSections?.keys.toList()}');

          final updated = current.copyWith(
            hasIncompleteSections: hasIncomplete,
            incompleteSections: incompleteSections.isEmpty ? null : incompleteSections,
            isActive: isActive,
            allMembersApproved: allMembersApproved,
          );

          return await repository.update(
            artistId: artistId,
            ensemble: updated,
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
