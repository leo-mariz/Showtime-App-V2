import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar dados bancários do artista logado
/// 
/// RESPONSABILIDADES:
/// - Obter UID do usuário logado
/// - Validar dados bancários:
///   - Dados do titular (fullName e cpfOrCnpj) são obrigatórios
///   - Deve ter ou (agência e conta) OU PIX preenchidos
/// - Buscar artista atual
/// - Atualizar dados bancários no artista
/// - Salvar artista atualizado
class UpdateArtistBankAccountUseCase {
  final GetArtistUseCase getArtistUseCase;
  final UpdateArtistUseCase updateArtistUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  UpdateArtistBankAccountUseCase({
    required this.getArtistUseCase,
    required this.updateArtistUseCase,
    required this.getUserUidUseCase,
  });

  Future<Either<Failure, void>> call(BankAccountEntity bankAccount) async {
    try {
      // Obter UID do usuário logado
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (failure) => throw failure,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não encontrado'));
      }

      // Validar dados bancários
      final validationResult = _validateBankAccount(bankAccount);
      if (validationResult != null) {
        return Left(ValidationFailure(validationResult));
      }

      // Buscar artista atual
      final getResult = await getArtistUseCase.call(uid);

      return await getResult.fold(
        (failure) => Left(failure),
        (currentArtist) async {
          // Atualizar dados bancários no artista
          // Por enquanto, o código está preparado para quando o campo existir
          final updatedArtist = currentArtist.copyWith(
            bankAccount: bankAccount,
          );

          // Atualizar artista
          return await updateArtistUseCase.call(uid, updatedArtist);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Valida os dados bancários conforme as regras de negócio
  /// 
  /// REGRAS:
  /// 1. Dados do titular são obrigatórios (fullName e cpfOrCnpj)
  /// 2. Deve ter ou (agência e conta) OU PIX preenchidos
  String? _validateBankAccount(BankAccountEntity bankAccount) {
    // Validar dados do titular (obrigatórios)
    if (bankAccount.fullName == null || bankAccount.fullName!.isEmpty) {
      return 'Nome completo do titular é obrigatório';
    }

    if (bankAccount.cpfOrCnpj == null || bankAccount.cpfOrCnpj!.isEmpty) {
      return 'CPF/CNPJ do titular é obrigatório';
    }

    // Validar que tem ou (agência e conta) OU PIX preenchidos
    final hasBankAccount = bankAccount.agency != null &&
        bankAccount.agency!.isNotEmpty &&
        bankAccount.accountNumber != null &&
        bankAccount.accountNumber!.isNotEmpty &&
        bankAccount.accountType != null &&
        bankAccount.accountType!.isNotEmpty &&
        bankAccount.bankName != null &&
        bankAccount.bankName!.isNotEmpty;

    final hasPix = bankAccount.pixType != null &&
        bankAccount.pixType!.isNotEmpty &&
        bankAccount.pixKey != null &&
        bankAccount.pixKey!.isNotEmpty;

    if (!hasBankAccount && !hasPix) {
      return 'É necessário preencher ou os dados da conta bancária (banco, agência, conta e tipo) ou os dados do PIX (tipo e chave)';
    }

    return null; // Validação passou
  }
}

