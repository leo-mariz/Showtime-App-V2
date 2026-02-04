import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Referências Firestore e cache para disponibilidade de conjunto.
/// Caminho: Ensembles/{ensembleId}/AvailabilityDays
extension EnsembleAvailabilityDayReference on AvailabilityDayEntity {
  /// Coleção de dias de disponibilidade do conjunto no Firestore.
  static CollectionReference firestoreCollection(
    FirebaseFirestore firestore,
    String ensembleId,
  ) {
    return firestore
        .collection(EnsembleEntityReference.remoteKey)
        .doc(ensembleId)
        .collection('AvailabilityDays');
  }

  /// Documento de um dia específico.
  static DocumentReference firestoreDocument(
    FirebaseFirestore firestore,
    String ensembleId,
    String dayId,
  ) {
    return firestoreCollection(firestore, ensembleId).doc(dayId);
  }

  /// Key para cache local (lista de dias do conjunto).
  static String cacheKey(String ensembleId) {
    return 'ensemble_availability_days_$ensembleId';
  }

  /// Key para cache de um dia específico.
  static String cacheDayKey(String ensembleId, String dayId) {
    return 'ensemble_availability_day_${ensembleId}_$dayId';
  }

  /// Key para cache de padrão.
  static String cachePatternKey(String ensembleId, String patternId) {
    return 'ensemble_availability_pattern_${ensembleId}_$patternId';
  }
}
