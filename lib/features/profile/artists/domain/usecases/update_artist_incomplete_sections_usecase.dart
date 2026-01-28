import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artists/domain/entities/artist_completeness_entity.dart';
import 'package:app/features/profile/artists/domain/enums/artist_info_category_enum.dart';
import 'package:app/features/profile/artists/domain/repositories/artists_repository.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar informações incompletas no ArtistEntity
/// 
/// RESPONSABILIDADES:
/// - Receber ArtistCompletenessEntity
/// - Converter para formato Map<String, List<String>> para incompleteSections
/// - Atualizar hasIncompleteSections
/// - Atualizar ArtistEntity no repositório
/// 
/// Este usecase atualiza o campo incompleteSections do ArtistEntity com base
/// no resultado do CheckArtistCompletenessUseCase.
class UpdateArtistIncompleteSectionsUseCase {
  final GetArtistUseCase getArtistUseCase;
  final IArtistsRepository repository;

  UpdateArtistIncompleteSectionsUseCase({
    required this.getArtistUseCase,
    required this.repository,
  });

  /// Atualiza as informações incompletas no ArtistEntity
  /// 
  /// [uid] - UID do artista
  /// [completeness] - Resultado da verificação de completude
  /// 
  /// Atualiza os campos:
  /// - hasIncompleteSections: true se houver alguma informação incompleta
  /// - incompleteSections: Map com categorias e tipos incompletos
  ///   Ex: {
  ///     'approvalRequired': ['documents', 'bankAccount'],
  ///     'exploreRequired': ['profilePicture'],
  ///     'optional': ['professionalInfo']
  ///   }
  Future<Either<Failure, void>> call(
    String uid,
    ArtistCompletenessEntity completeness,
  ) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Buscar artista atual
      final getResult = await getArtistUseCase.call(uid);
      
      return await getResult.fold(
        (failure) => Left(failure),
        (currentArtist) async {
          // Construir Map de seções incompletas
          final incompleteSections = <String, List<String>>{};

          // Agrupar informações incompletas por categoria
          for (final category in ArtistInfoCategory.values) {
            final incompleteByCategory = completeness.getIncompleteByCategory(category);
            
            if (incompleteByCategory.isNotEmpty) {
              incompleteSections[category.name] = incompleteByCategory
                  .map((status) => status.type.name)
                  .toList();
            }
          }

          // Determinar se há seções incompletas
          final hasIncomplete = incompleteSections.isNotEmpty;

          // Criar artista atualizado
          final updatedArtist = currentArtist.copyWith(
            hasIncompleteSections: hasIncomplete,
            incompleteSections: incompleteSections.isEmpty ? null : incompleteSections,
            isActive: hasIncomplete ? false : true,
          );

          // Atualizar no repositório
          final updateResult = await repository.updateArtist(uid, updatedArtist);
          
          return updateResult;
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
