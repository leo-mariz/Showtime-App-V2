import 'package:app/core/domain/favorites/favorite_artist_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface para operações remotas (Firestore) de favoritos
abstract class IFavoriteRemoteDataSource {
  /// Adiciona um artista aos favoritos no Firestore
  Future<void> addFavorite({
    required String clientId,
    required FavoriteArtistEntity favorite,
  });

  /// Remove um artista dos favoritos no Firestore
  Future<void> removeFavorite({
    required String clientId,
    required String artistId,
  });

  /// Busca todos os favoritos de um cliente do Firestore
  Future<List<FavoriteArtistEntity>> getFavorites({
    required String clientId,
  });

  /// Verifica se um artista está nos favoritos no Firestore
  Future<bool> isFavorite({
    required String clientId,
    required String artistId,
  });

  /// Busca um favorito específico do Firestore
  Future<FavoriteArtistEntity?> getFavorite({
    required String clientId,
    required String artistId,
  });
}

/// Implementação do datasource remoto de favoritos
class FavoriteRemoteDataSourceImpl implements IFavoriteRemoteDataSource {
  final FirebaseFirestore firestore;

  FavoriteRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addFavorite({
    required String clientId,
    required FavoriteArtistEntity favorite,
  }) async {
    try {
      final docRef = FavoriteArtistEntityReference.favoriteDocument(
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
      final docRef = FavoriteArtistEntityReference.favoriteDocument(
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
  Future<List<FavoriteArtistEntity>> getFavorites({
    required String clientId,
  }) async {
    try {
      final collectionRef = FavoriteArtistEntityReference.favoritesCollection(
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
              return FavoriteArtistEntityMapper.fromMap(data);
            } catch (e) {
              // Se houver erro ao mapear um documento, logar e pular
              debugPrint('❌ Erro ao mapear favorito ${doc.id}: $e');
              return null;
            }
          })
          .whereType<FavoriteArtistEntity>()
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao buscar favoritos');
    } catch (e) {
      throw ServerException('Erro desconhecido ao buscar favoritos: $e');
    }
  }

  @override
  Future<bool> isFavorite({
    required String clientId,
    required String artistId,
  }) async {
    try {
      final docRef = FavoriteArtistEntityReference.favoriteDocument(
        firestore,
        clientId,
        artistId,
      );

      final docSnapshot = await docRef.get();
      return docSnapshot.exists;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao verificar favorito');
    } catch (e) {
      throw ServerException('Erro desconhecido ao verificar favorito: $e');
    }
  }

  @override
  Future<FavoriteArtistEntity?> getFavorite({
    required String clientId,
    required String artistId,
  }) async {
    try {
      final docRef = FavoriteArtistEntityReference.favoriteDocument(
        firestore,
        clientId,
        artistId,
      );

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      return FavoriteArtistEntityMapper.fromMap(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao buscar favorito');
    } catch (e) {
      throw ServerException('Erro desconhecido ao buscar favorito: $e');
    }
  }
}

// Helper para debug
void debugPrint(String message) {
  print(message);
}

