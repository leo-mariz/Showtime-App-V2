import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'favorite_entity.mapper.dart';

/// Entidade que representa um artista favorito do cliente
/// Armazenada em subcoleção: Clients/{clientId}/Favorites/{artistId}
/// 
/// Armazena apenas o UID do artista. Os dados do artista
/// (nome, foto, rating, disponibilidades) são buscados dinamicamente
/// do Firestore para garantir sempre dados atualizados.
@MappableClass()
class FavoriteEntity with FavoriteEntityMappable {
  /// UID do artista favorito
  final String artistId;
  
  /// Data/hora em que foi adicionado aos favoritos
  final DateTime addedAt;

  FavoriteEntity({
    required this.artistId,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}

extension FavoriteEntityReference on FavoriteEntity {
  /// Referência para a coleção de favoritos de um cliente
  static CollectionReference favoritesCollection(
    FirebaseFirestore firestore,
    String clientId,
  ) {
    return firestore
        .collection('Clients')
        .doc(clientId)
        .collection('Favorites');
  }

  /// Referência para um documento específico de favorito
  static DocumentReference favoriteDocument(
    FirebaseFirestore firestore,
    String clientId,
    String artistId,
  ) {
    return favoritesCollection(firestore, clientId).doc(artistId);
  }
  
  /// Chave para cache local da lista de favoritos
  static String cachedFavoritesKey() {
    return 'CACHED_FAVORITES';
  }
}

