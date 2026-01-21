import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

/// Hook para converter Timestamp do Firestore em DateTime
/// 
/// Usado com dart_mappable para permitir desserialização automática
/// de campos Timestamp do Firebase para DateTime do Dart
class TimestampHook extends MappingHook {
  const TimestampHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return value;
  }
}
