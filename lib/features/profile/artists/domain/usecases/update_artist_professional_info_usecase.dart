import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar informações profissionais do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Validar informações profissionais
/// - Buscar artista atual (do cache se disponível)
/// - Atualizar apenas o campo professionalInfo
/// - Salvar atualização
class UpdateArtistProfessionalInfoUseCase {
  final GetArtistUseCase getArtistUseCase;
  final UpdateArtistUseCase updateArtistUseCase;

  UpdateArtistProfessionalInfoUseCase({
    required this.getArtistUseCase,
    required this.updateArtistUseCase,
  });

  Future<Either<Failure, void>> call(
    String uid,
    ProfessionalInfoEntity professionalInfo,
  ) async {
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
          // Criar nova entidade com apenas professionalInfo atualizado
          final updatedArtist = currentArtist.copyWith(
            professionalInfo: professionalInfo,
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

