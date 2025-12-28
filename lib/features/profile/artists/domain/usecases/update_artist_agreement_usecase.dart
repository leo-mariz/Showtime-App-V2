import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar acordo de termos de uso do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Buscar artista atual (do cache se disponível)
/// - Atualizar apenas o campo agreedToArtistTermsOfUse
/// - Salvar atualização
class UpdateArtistAgreementUseCase {
  final GetArtistUseCase getArtistUseCase;
  final UpdateArtistUseCase updateArtistUseCase;

  UpdateArtistAgreementUseCase({
    required this.getArtistUseCase,
    required this.updateArtistUseCase,
  });

  Future<Either<Failure, void>> call(String uid, bool agreedToTerms) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Buscar artista atual (cache-first)
      final getResult = await getArtistUseCase(uid);
      
      return getResult.fold(
        (failure) => Left(failure),
        (currentArtist) async {
          // Criar nova entidade com apenas agreedToArtistTermsOfUse atualizado
          final updatedArtist = currentArtist.copyWith(
            agreedToArtistTermsOfUse: agreedToTerms,
          );

          // Atualizar artista
          return await updateArtistUseCase(uid, updatedArtist);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

