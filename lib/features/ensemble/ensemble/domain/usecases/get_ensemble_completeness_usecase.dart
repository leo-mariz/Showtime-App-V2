import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:app/features/artists/artist_documents/domain/repositories/documents_repository.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/ensemble_completeness_entity.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/check_ensemble_completeness_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';

/// Busca a completude do conjunto (ensemble).
///
/// Obtém ensemble, documentos e banco do dono e retorna [EnsembleCompletenessEntity].
/// Aprovação do grupo é dada quando o artista dono está aprovado (não é mais por documentos de membros).
class GetEnsembleCompletenessUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final IDocumentsRepository documentsRepository;
  final IBankAccountRepository bankAccountRepository;
  final CheckEnsembleCompletenessUseCase checkEnsembleCompletenessUseCase;

  GetEnsembleCompletenessUseCase({
    required this.getEnsembleUseCase,
    required this.documentsRepository,
    required this.bankAccountRepository,
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

      final ensembleResult = await getEnsembleUseCase.call(artistId, ensembleId);
      return await ensembleResult.fold(
        (f) => Left(f),
        (ensemble) async {
          if (ensemble == null) {
            return const Left(NotFoundFailure('Conjunto não encontrado'));
          }

          final ownerId = ensemble.ownerArtistId;
          final documentsResult = await documentsRepository.getDocuments(ownerId);
          final bankResult = await bankAccountRepository.getBankAccount(ownerId);

          final ownerDocs = documentsResult.fold((_) => <DocumentsEntity>[], (l) => l);
          final ownerBank = bankResult.fold((_) => null, (b) => b);

          final completeness = checkEnsembleCompletenessUseCase.call(
            ensemble: ensemble,
            ownerDocuments: ownerDocs,
            ownerBankAccount: ownerBank,
          );
          return Right(completeness);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
