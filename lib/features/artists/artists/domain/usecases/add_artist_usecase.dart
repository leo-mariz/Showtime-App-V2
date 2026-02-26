import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/users/domain/usecases/get_user_data_usecase.dart';
import 'package:app/features/artists/artists/domain/repositories/artists_repository.dart';
import 'package:app/features/artists/artist_bank_account/domain/usecases/save_bank_account_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Adicionar novo artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Validar dados do artista
/// - Adicionar artista no repositório
class AddArtistUseCase {
  final IArtistsRepository repository;
  final SaveBankAccountUseCase saveBankAccountUseCase;
  final GetUserDataUseCase getUserDataUseCase;

  AddArtistUseCase({
    required this.repository,
    required this.saveBankAccountUseCase,
    required this.getUserDataUseCase,
  });

  Future<Either<Failure, void>> call(String uid) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      final userData = await getUserDataUseCase.call(uid);
      final user = userData.fold(
        (failure) => throw failure,
        (user) => user,
      );

      var bankAccount = BankAccountEntity();
      if (user.cpfUser != null) {
        bankAccount = BankAccountEntity(
          fullName: '${user.cpfUser?.firstName ?? ''} ${user.cpfUser?.lastName ?? ''}'.trim(),
          cpfOrCnpj: user.cpfUser?.cpf ?? '',
        );
      } else {
        bankAccount = BankAccountEntity(
          fullName: user.cnpjUser?.fantasyName ?? '',
          cpfOrCnpj: user.cnpjUser?.cnpj ?? '',
        );
      }

      final artist = ArtistEntity.defaultEntity();

      String artistName = '';

      if (user.isCnpj == true) {
        artistName = user.cnpjUser?.fantasyName ?? '';
      } else {
        artistName = '${user.cpfUser?.firstName ?? ''} ${user.cpfUser?.lastName ?? ''}'.trim();
      }

      final updatedArtist = artist.copyWith(artistName: artistName);

      // Validar se dateRegistered está presente (obrigatório)
      if (updatedArtist.dateRegistered == null) {
        return const Left(ValidationFailure('Data de registro não pode ser vazia'));
      }

      // Adicionar artista primeiro; só depois salvar conta bancária para manter consistência
      final addResult = await repository.addArtist(uid, updatedArtist);
      if (addResult.isLeft()) {
        return addResult.fold((l) => Left(l), (_) => throw StateError('unreachable'));
      }

      final saveBankAccountResult = await saveBankAccountUseCase.call(uid, bankAccount);
      return saveBankAccountResult;
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

