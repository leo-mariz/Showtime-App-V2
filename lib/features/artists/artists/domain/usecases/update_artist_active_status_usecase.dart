import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar status ativo do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Buscar artista atual (do cache se disponível)
/// - Atualizar apenas o campo isActive
/// - Salvar atualização
class UpdateArtistActiveStatusUseCase {
  final GetArtistUseCase getArtistUseCase;
  final UpdateArtistUseCase updateArtistUseCase;

  UpdateArtistActiveStatusUseCase({
    required this.getArtistUseCase,
    required this.updateArtistUseCase,
  });

  Future<Either<Failure, void>> call(String uid, bool isActive) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Buscar artista atual (cache-first)
      final getResult = await getArtistUseCase.call(uid);
      
      return getResult.fold(
        (failure) => Left(failure),
        (currentArtist) async {
          // Criar nova entidade com apenas isActive atualizado
          final updatedArtist = currentArtist.copyWith(
            isActive: isActive,
          );

          // Atualizar artista
          return await updateArtistUseCase.call(uid, updatedArtist);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
