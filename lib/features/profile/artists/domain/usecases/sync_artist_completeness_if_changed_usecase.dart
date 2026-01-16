import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artists/domain/entities/artist_completeness_entity.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_completeness_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_incomplete_sections_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Sincronizar completude do artista apenas se houver mudanças
/// 
/// RESPONSABILIDADES:
/// - Buscar completude atual do artista
/// - Buscar ArtistEntity atual (para comparar)
/// - Comparar se a completude mudou
/// - Atualizar incompleteSections apenas se houver mudança
/// 
/// VANTAGENS:
/// - Evita escritas desnecessárias no Firestore
/// - Reduz operações de rede
/// - Mantém performance otimizada
/// 
/// USO RECOMENDADO:
/// - Use este usecase em vez de SyncArtistCompletenessUseCase quando
///   quiser otimizar para evitar atualizações desnecessárias
class SyncArtistCompletenessIfChangedUseCase {
  final GetArtistCompletenessUseCase getArtistCompletenessUseCase;
  final UpdateArtistIncompleteSectionsUseCase updateArtistIncompleteSectionsUseCase;
  final GetArtistUseCase getArtistUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  SyncArtistCompletenessIfChangedUseCase({
    required this.getArtistCompletenessUseCase,
    required this.updateArtistIncompleteSectionsUseCase,
    required this.getArtistUseCase,
    required this.getUserUidUseCase,
  });

  /// Sincroniza a completude do artista logado apenas se houver mudanças
  /// 
  /// 1. Busca a completude atual
  /// 2. Busca o ArtistEntity atual
  /// 3. Compara se a completude mudou em relação ao que está salvo
  /// 4. Atualiza incompleteSections apenas se houver mudança
  /// 
  /// Retorna [bool] indicando se houve atualização (true) ou não (false)
  Future<Either<Failure, bool>> call() async {
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

      // 2. Buscar completude atual e ArtistEntity em paralelo
      final completenessResult = await getArtistCompletenessUseCase.call();
      final artistResult = await getArtistUseCase.call(uid);

      return await completenessResult.fold(
        (failure) => Left(failure),
        (completeness) async {
          return await artistResult.fold(
            (failure) => Left(failure),
            (currentArtist) async {
              // 3. Comparar se a completude mudou
              final hasChanged = _hasCompletenessChanged(
                currentArtist,
                completeness,
              );

              // 4. Atualizar apenas se houver mudança
              if (!hasChanged) {
                return const Right(false); // Não houve atualização
              }

              // 5. Atualizar incompleteSections
              final updateResult = await updateArtistIncompleteSectionsUseCase.call(
                uid,
                completeness,
              );

              return updateResult.fold(
                (failure) => Left(failure),
                (_) => const Right(true), // Houve atualização
              );
            },
          );
        },
      );
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Compara se a completude mudou em relação ao que está salvo no ArtistEntity
  /// 
  /// Verifica:
  /// - hasIncompleteSections mudou?
  /// - incompleteSections mudou? (comparação profunda do Map)
  bool _hasCompletenessChanged(
    ArtistEntity currentArtist,
    ArtistCompletenessEntity newCompleteness,
  ) {
    // Construir o Map de seções incompletas esperado
    final expectedIncompleteSections = <String, List<String>>{};

    for (final status in newCompleteness.incompleteStatuses) {
      final categoryName = status.category.name;
      if (!expectedIncompleteSections.containsKey(categoryName)) {
        expectedIncompleteSections[categoryName] = [];
      }
      expectedIncompleteSections[categoryName]!.add(status.type.name);
    }

    // Ordenar listas para comparação
    for (final key in expectedIncompleteSections.keys) {
      expectedIncompleteSections[key]!.sort();
    }

    // Comparar hasIncompleteSections
    final expectedHasIncomplete = expectedIncompleteSections.isNotEmpty;
    if (currentArtist.hasIncompleteSections != expectedHasIncomplete) {
      return true; // Mudou
    }

    // Comparar incompleteSections (comparação profunda)
    final currentIncompleteSections = currentArtist.incompleteSections ?? <String, List<String>>{};

    // Ordenar listas do current para comparação
    final currentIncompleteSectionsSorted = <String, List<String>>{};
    for (final entry in currentIncompleteSections.entries) {
      final sortedList = List<String>.from(entry.value)..sort();
      currentIncompleteSectionsSorted[entry.key] = sortedList;
    }

    // Comparar tamanho dos maps
    if (currentIncompleteSectionsSorted.length != expectedIncompleteSections.length) {
      return true; // Mudou
    }

    // Comparar cada categoria
    for (final categoryName in expectedIncompleteSections.keys) {
      if (!currentIncompleteSectionsSorted.containsKey(categoryName)) {
        return true; // Categoria nova adicionada
      }

      final expectedList = expectedIncompleteSections[categoryName]!;
      final currentList = currentIncompleteSectionsSorted[categoryName]!;

      // Comparar listas
      if (expectedList.length != currentList.length) {
        return true; // Tamanho diferente
      }

      for (int i = 0; i < expectedList.length; i++) {
        if (expectedList[i] != currentList[i]) {
          return true; // Item diferente
        }
      }
    }

    // Verificar se há categorias removidas
    for (final categoryName in currentIncompleteSectionsSorted.keys) {
      if (!expectedIncompleteSections.containsKey(categoryName)) {
        return true; // Categoria removida
      }
    }

    return false; // Não mudou
  }
}
