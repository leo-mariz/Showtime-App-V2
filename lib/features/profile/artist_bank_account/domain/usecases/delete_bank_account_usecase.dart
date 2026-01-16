import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:app/features/profile/artists/domain/usecases/sync_artist_completeness_if_changed_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Deletar conta bancária do artista
/// 
/// RESPONSABILIDADES:
/// - Validar artistId
/// - Deletar conta bancária do repositório
class DeleteBankAccountUseCase {
  final IBankAccountRepository repository;
  final SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase; 
   
  DeleteBankAccountUseCase({
    required this.repository,
    required this.syncArtistCompletenessIfChangedUseCase,
  });

  Future<Either<Failure, void>> call(String artistId) async {
    try {
      // Validar artistId
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista não pode ser vazio'));
      }

      // Deleta conta bancária do repositório
      final result = await repository.deleteBankAccount(artistId);

      // Sincronizar completude apenas se mudou
      await syncArtistCompletenessIfChangedUseCase.call();

      return result;
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

