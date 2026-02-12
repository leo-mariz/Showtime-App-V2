import 'package:cloud_firestore/cloud_firestore.dart';

/// Utilitário para converter mapas vindos do Firestore antes de passar ao dart_mappable.
///
/// O [DateTimeMapper] do dart_mappable só decodifica [DateTime] a partir de [String] ou [num].
/// O Firestore retorna [Timestamp]. Este helper converte recursivamente todo [Timestamp]
/// para [millisecondsSinceEpoch] (int), evitando MapperException ao decodificar entidades.
///
/// Use antes de qualquer [EntityMapper.fromMap(map)] quando o mapa veio do Firestore.
Object? convertFirestoreTimestampsForMapper(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) {
    return value.millisecondsSinceEpoch;
  }
  if (value is Map<String, dynamic>) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      result[entry.key] = convertFirestoreTimestampsForMapper(entry.value);
    }
    return result;
  }
  if (value is Map) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      final k = entry.key;
      result[k is String ? k : k.toString()] =
          convertFirestoreTimestampsForMapper(entry.value);
    }
    return result;
  }
  if (value is List) {
    return value.map((e) => convertFirestoreTimestampsForMapper(e)).toList();
  }
  return value;
}

/// Converte um mapa Firestore para formato aceito pelo dart_mappable (Timestamp → ms).
Map<String, dynamic> convertFirestoreMapForMapper(Map<String, dynamic> data) {
  final result = convertFirestoreTimestampsForMapper(data);
  return result is Map<String, dynamic> ? result : Map<String, dynamic>.from(data);
}
