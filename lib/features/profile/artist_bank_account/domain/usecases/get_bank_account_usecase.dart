import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase para obter a conta bancária do artista
/// 
/// RESPONSABILIDADES:
/// - Validar o artistId antes de chamar o repositório
/// - Retornar a conta bancária ou null se não existir
class GetBankAccountUseCase {
  final IBankAccountRepository repository;

  GetBankAccountUseCase({required this.repository});

  Future<Either<Failure, BankAccountEntity?>> call(String artistId) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista não pode ser vazio'));
      }

      return await repository.getBankAccount(artistId);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

