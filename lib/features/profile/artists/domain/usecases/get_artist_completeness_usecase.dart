import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:app/features/profile/artist_documents/domain/repositories/documents_repository.dart';
import 'package:app/features/profile/artists/domain/entities/artist_completeness_entity.dart';
import 'package:app/features/profile/artists/domain/usecases/check_artist_completeness_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Obter completude do artista logado
/// 
/// RESPONSABILIDADES:
/// - Obter UID do artista logado
/// - Buscar todos os dados necessários (Artist, Documents, BankAccount, Availabilities)
/// - Chamar CheckArtistCompletenessUseCase
/// - Retornar ArtistCompletenessEntity
/// 
/// Este usecase orquestra a busca de todos os dados necessários para verificar
/// a completude do perfil do artista.
class GetArtistCompletenessUseCase {
  final GetArtistUseCase getArtistUseCase;
  final IDocumentsRepository documentsRepository;
  final IBankAccountRepository bankAccountRepository;
  final IAvailabilityRepository availabilityRepository;
  final GetUserUidUseCase getUserUidUseCase;
  final CheckArtistCompletenessUseCase checkArtistCompletenessUseCase;

  GetArtistCompletenessUseCase({
    required this.getArtistUseCase,
    required this.documentsRepository,
    required this.bankAccountRepository,
    required this.availabilityRepository,
    required this.getUserUidUseCase,
    required this.checkArtistCompletenessUseCase,
  });

  /// Busca a completude do artista logado
  /// 
  /// Retorna [ArtistCompletenessEntity] com o status completo de todas as informações
  Future<Either<Failure, ArtistCompletenessEntity>> call() async {
    try {
      // 1. Obter UID do artista
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (failure) => throw failure,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(AuthFailure('UID do artista não encontrado'));
      }

      // 2. Buscar todos os dados necessários em paralelo
      final artistResult = await getArtistUseCase.call(uid);
      final documentsResult = await documentsRepository.getDocuments(uid);
      final bankAccountResult = await bankAccountRepository.getBankAccount(uid);
      final availabilitiesResult = await availabilityRepository.getAvailability(artistId: uid);

      // 3. Verificar se algum falhou
      if (artistResult.isLeft()) {
        return artistResult.fold((l) => Left(l), (r) => throw Exception());
      }
      if (documentsResult.isLeft()) {
        return documentsResult.fold((l) => Left(l), (r) => throw Exception());
      }
      if (availabilitiesResult.isLeft()) {
        return availabilitiesResult.fold((l) => Left(l), (r) => throw Exception());
      }

      // 4. Extrair dados
      final artist = artistResult.fold((l) => throw l, (r) => r);
      final documents = documentsResult.fold((l) => throw l, (r) => r);
      final bankAccount = bankAccountResult.fold(
        (l) => null,
        (r) => r,
      );
      final availabilities = availabilitiesResult.fold((l) => throw l, (r) => r);

      // 6. Verificar completude
      final completeness = checkArtistCompletenessUseCase.call(
        artist: artist,
        documents: documents,
        bankAccount: bankAccount,
        availabilities: availabilities,
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
