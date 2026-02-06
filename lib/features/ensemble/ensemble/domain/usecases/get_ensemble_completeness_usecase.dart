import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:app/features/artists/artist_documents/domain/repositories/documents_repository.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/ensemble_completeness_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/check_ensemble_completeness_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/member_documents/domain/usecases/get_all_member_documents_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

/// Busca a completude do conjunto (ensemble).
///
/// Obtém ensemble, documentos e banco do dono, documentos de cada integrante (não dono)
/// e retorna [EnsembleCompletenessEntity].
class GetEnsembleCompletenessUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final IDocumentsRepository documentsRepository;
  final IBankAccountRepository bankAccountRepository;
  final GetAllMemberDocumentsUseCase getAllMemberDocumentsUseCase;
  final CheckEnsembleCompletenessUseCase checkEnsembleCompletenessUseCase;

  GetEnsembleCompletenessUseCase({
    required this.getEnsembleUseCase,
    required this.documentsRepository,
    required this.bankAccountRepository,
    required this.getAllMemberDocumentsUseCase,
    required this.checkEnsembleCompletenessUseCase,
  });

  Future<Either<Failure, EnsembleCompletenessEntity>> call(
    String artistId,
    String ensembleId,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }

      debugPrint('[GetEnsembleCompleteness] call artistId=$artistId ensembleId=$ensembleId');
      final ensembleResult = await getEnsembleUseCase.call(artistId, ensembleId);
      return await ensembleResult.fold(
        (f) => Left(f),
        (ensemble) async {
          if (ensemble == null) {
            debugPrint('[GetEnsembleCompleteness] ensemble null');
            return const Left(NotFoundFailure('Conjunto não encontrado'));
          }

          final ownerId = ensemble.ownerArtistId;
          final documentsResult = await documentsRepository.getDocuments(ownerId);
          final bankResult = await bankAccountRepository.getBankAccount(ownerId);

          final ownerDocs = documentsResult.fold((_) => <DocumentsEntity>[], (l) => l);
          final ownerBank = bankResult.fold((_) => null, (b) => b);

          final memberDocsMap = <String, List<MemberDocumentEntity>>{};
          final nonOwnerMembers = ensemble.members
                  ?.where((m) => !m.isOwner && m.memberId.isNotEmpty)
                  .toList() ??
              [];
          for (final member in nonOwnerMembers) {
            final memberId = member.memberId;
            final result = await getAllMemberDocumentsUseCase.call(
              artistId,
              ensembleId,
              memberId,
            );
            result.fold(
              (_) => memberDocsMap[memberId] = [],
              (list) => memberDocsMap[memberId] = list,
            );
          }

          final completeness = checkEnsembleCompletenessUseCase.call(
            ensemble: ensemble,
            ownerDocuments: ownerDocs,
            ownerBankAccount: ownerBank,
            memberDocumentsByMemberId: memberDocsMap,
          );
          final incompleteCount = completeness.incompleteStatuses.length;
          debugPrint('[GetEnsembleCompleteness] done ensembleId=$ensembleId | nonOwnerMembers=${nonOwnerMembers.length} | memberDocsKeys=${memberDocsMap.keys.toList()} | incompleteSections=$incompleteCount');
          return Right(completeness);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
