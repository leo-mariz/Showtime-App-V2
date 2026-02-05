import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:app/features/artists/artist_documents/domain/repositories/documents_repository.dart';
import 'package:app/features/artists/artists/domain/entities/artist_completeness_entity.dart';
import 'package:app/features/artists/artists/domain/usecases/check_artist_completeness_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Obter completude do artista logado
///
/// Busca Artist, Documents e BankAccount e chama [CheckArtistCompletenessUseCase].
class GetArtistCompletenessUseCase {
  final GetArtistUseCase getArtistUseCase;
  final IDocumentsRepository documentsRepository;
  final IBankAccountRepository bankAccountRepository;
  final GetUserUidUseCase getUserUidUseCase;
  final CheckArtistCompletenessUseCase checkArtistCompletenessUseCase;

  GetArtistCompletenessUseCase({
    required this.getArtistUseCase,
    required this.documentsRepository,
    required this.bankAccountRepository,
    required this.getUserUidUseCase,
    required this.checkArtistCompletenessUseCase,
  });

  Future<Either<Failure, ArtistCompletenessEntity>> call() async {
    try {
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (failure) => throw failure,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(AuthFailure('UID do artista não encontrado'));
      }

      final artistResult = await getArtistUseCase.call(uid);
      final documentsResult = await documentsRepository.getDocuments(uid);
      final bankAccountResult = await bankAccountRepository.getBankAccount(uid);

      if (artistResult.isLeft()) {
        return artistResult.fold((l) => Left(l), (r) => throw Exception());
      }
      if (documentsResult.isLeft()) {
        return documentsResult.fold((l) => Left(l), (r) => throw Exception());
      }

      final artist = artistResult.fold((l) => throw l, (r) => r);
      final documents = documentsResult.fold((l) => throw l, (r) => r);
      final bankAccount = bankAccountResult.fold(
        (l) => null,
        (r) => r,
      );

      final completeness = checkArtistCompletenessUseCase.call(
        artist: artist,
        documents: documents,
        bankAccount: bankAccount,
      );

      return Right(completeness);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ErrorHandler.handle(e));
    }
  }
}
