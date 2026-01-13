import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'favorite_artist_entity.mapper.dart';

/// Entidade que representa um artista favorito do cliente
/// Armazenada em subcoleção: Clients/{clientId}/Favorites/{artistId}
@MappableClass()
class FavoriteArtistEntity with FavoriteArtistEntityMappable {
  /// UID do artista favorito
  final String artistId;
  
  /// Nome do artista (snapshot para exibição rápida)
  final String? artistName;
  
  /// URL da foto do artista (snapshot)
  final String? artistPhoto;
  
  /// Rating do artista (snapshot)
  final double? artistRating;
  
  /// Total de apresentações avaliadas do artista (snapshot)
  final int? artistRatedPresentations;
  
  /// Data/hora em que foi adicionado aos favoritos
  final DateTime addedAt;
  
  /// Tags personalizadas para organização (opcional)
  final List<String>? tags;
  
  /// Notas pessoais do cliente sobre o artista (opcional)
  final String? notes;

  FavoriteArtistEntity({
    required this.artistId,
    this.artistName,
    this.artistPhoto,
    this.artistRating,
    this.artistRatedPresentations,
    DateTime? addedAt,
    this.tags,
    this.notes,
  }) : addedAt = addedAt ?? DateTime.now();
}

extension FavoriteArtistEntityReference on FavoriteArtistEntity {
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
  static String cachedFavoritesKey(String clientId) {
    return 'CACHED_FAVORITES_$clientId';
  }
  
  /// Chave para cache local de verificação de favorito
  static String cachedIsFavoriteKey(String clientId, String artistId) {
    return 'CACHED_IS_FAVORITE_${clientId}_$artistId';
  }
}

