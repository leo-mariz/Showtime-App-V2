import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se o usuário pode trocar para perfil de artista
/// 
/// RESPONSABILIDADES:
/// - Obter UID do usuário logado
/// - Verificar se perfil de artista já existe
/// - Retornar resultado indicando se perfil existe ou não
class SwitchToArtistUseCase {
  final GetUserUidUseCase getUserUidUseCase;
  final GetArtistUseCase getArtistUseCase;

  SwitchToArtistUseCase({
    required this.getUserUidUseCase,
    required this.getArtistUseCase,
  });

  Future<Either<Failure, bool>> call() async {
    try {
      // 1. Obter UID do usuário
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (failure) => throw failure,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(ValidationFailure('UID do usuário não encontrado'));
      }

      // 2. Verificar se artista já existe
      final artistResult = await getArtistUseCase.call(uid);

      return artistResult.fold(
        (failure) {
          // Se for NotFoundFailure, significa que não existe
          // Se for outro tipo de erro, retornar o erro
          return Left(failure);
        },
        (artist) {
          // Comparar com entidade vazia para verificar se existe
          final profileExists = artist != ArtistEntity() && artist.uid != null;
          return Right(profileExists);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

