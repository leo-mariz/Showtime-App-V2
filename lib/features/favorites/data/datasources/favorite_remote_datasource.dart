import 'package:app/core/domain/favorites/favorite_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface para operações remotas (Firestore) de favoritos
abstract class IFavoriteRemoteDataSource {
  /// Adiciona um artista aos favoritos no Firestore
  Future<void> addFavorite({
    required String clientId,
    required FavoriteEntity favorite,
  });

  /// Remove um artista dos favoritos no Firestore
  Future<void> removeFavorite({
    required String clientId,
    required String artistId,
  });

  /// Busca todos os favoritos de um cliente do Firestore
  Future<List<FavoriteEntity>> getAllFavorites({
    required String clientId,
  });

  /// Busca um artista favorito de um cliente do Firestore
}

/// Implementação do datasource remoto de favoritos
class FavoriteRemoteDataSourceImpl implements IFavoriteRemoteDataSource {
  final FirebaseFirestore firestore;

  FavoriteRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addFavorite({
    required String clientId,
    required FavoriteEntity favorite,
  }) async {
    try {
      final docRef = FavoriteEntityReference.favoriteDocument(
        firestore,
        clientId,
        favorite.artistId,
      );

      await docRef.set(favorite.toMap());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao adicionar favorito');
    } catch (e) {
      throw ServerException('Erro desconhecido ao adicionar favorito: $e');
    }
  }

  @override
  Future<void> removeFavorite({
    required String clientId,
    required String artistId,
  }) async {
    try {
      final docRef = FavoriteEntityReference.favoriteDocument(
        firestore,
        clientId,
        artistId,
      );

      await docRef.delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao remover favorito');
    } catch (e) {
      throw ServerException('Erro desconhecido ao remover favorito: $e');
    }
  }

  @override
  Future<List<FavoriteEntity>> getAllFavorites({
    required String clientId,
  }) async {
    try {
      final collectionRef = FavoriteEntityReference.favoritesCollection(
        firestore,
        clientId,
      );

      final querySnapshot = await collectionRef
          .orderBy('addedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return FavoriteEntityMapper.fromMap(data);
            } catch (e) {
              // Se houver erro ao mapear, criar entidade apenas com o ID
              return FavoriteEntity(artistId: doc.id);
            }
          })
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao buscar favoritos');
    } catch (e) {
      throw ServerException('Erro desconhecido ao buscar favoritos: $e');
    }
  }
}

