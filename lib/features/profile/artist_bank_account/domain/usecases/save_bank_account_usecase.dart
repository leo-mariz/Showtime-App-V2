import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Salvar ou atualizar conta bancária do artista
/// 
/// RESPONSABILIDADES:
/// - Validar artistId
/// - Validar dados bancários (opcional, pode ser feito em outro usecase)
/// - Salvar ou atualizar conta bancária no repositório
/// - Como cada artista tem apenas uma conta, sempre salva no documento "account"
class SaveBankAccountUseCase {
  final IBankAccountRepository repository;

  SaveBankAccountUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(
    String artistId,
    BankAccountEntity bankAccount,
  ) async {
    try {
      // Validar artistId
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista não pode ser vazio'));
      }

      // Salva ou atualiza conta bancária no repositório
      return await repository.saveBankAccount(artistId, bankAccount);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

