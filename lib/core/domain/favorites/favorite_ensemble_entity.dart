import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'favorite_ensemble_entity.mapper.dart';

/// Entidade que representa um conjunto favorito do cliente.
/// Armazenada em subcoleção: Clients/{clientId}/FavoriteEnsembles/{ensembleId}
@MappableClass()
class FavoriteEnsembleEntity with FavoriteEnsembleEntityMappable {
  /// UID do conjunto favorito
  final String ensembleId;

  /// Data/hora em que foi adicionado aos favoritos
  final DateTime addedAt;

  FavoriteEnsembleEntity({
    required this.ensembleId,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}

extension FavoriteEnsembleEntityReference on FavoriteEnsembleEntity {
  static CollectionReference favoriteEnsemblesCollection(
    FirebaseFirestore firestore,
    String clientId,
  ) {
    return firestore
        .collection('Clients')
        .doc(clientId)
        .collection('FavoriteEnsembles');
  }

  static DocumentReference favoriteEnsembleDocument(
    FirebaseFirestore firestore,
    String clientId,
    String ensembleId,
  ) {
    return favoriteEnsemblesCollection(firestore, clientId).doc(ensembleId);
  }

  static String cachedFavoriteEnsemblesKey() {
    return 'CACHED_FAVORITE_ENSEMBLES';
  }
}
