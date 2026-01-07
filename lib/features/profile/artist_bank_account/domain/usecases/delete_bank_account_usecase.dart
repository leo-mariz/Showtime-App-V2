import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Deletar conta bancária do artista
/// 
/// RESPONSABILIDADES:
/// - Validar artistId
/// - Deletar conta bancária do repositório
class DeleteBankAccountUseCase {
  final IBankAccountRepository repository;

  DeleteBankAccountUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(String artistId) async {
    try {
      // Validar artistId
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista não pode ser vazio'));
      }

      // Deleta conta bancária do repositório
      return await repository.deleteBankAccount(artistId);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

