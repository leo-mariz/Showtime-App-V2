import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/availability/address_availability_entity.dart';
import 'package:app/core/domain/artist/availability/pattern_metadata_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'availability_day_entity.mapper.dart';

/// Representa a disponibilidade de um artista em um dia específico
/// 
/// Este é o documento principal que armazena toda a informação de disponibilidade
/// Substitui o antigo modelo de regras de recorrência
@MappableClass()
class AvailabilityDayEntity with AvailabilityDayEntityMappable {
  /// ID do documento (formato: YYYY-MM-DD)
  final String? id;
  
  /// Data específica deste dia
  final DateTime date;
  
  /// Metadata sobre como este dia foi gerado
  final PatternMetadata? generatedFrom;
  
  /// Indica se este dia foi customizado manualmente (override)
  final bool isOverridden;
  
  /// Campos que foram alterados manualmente (para tracking)
  final Map<String, dynamic>? overrides;
  
  /// Lista de disponibilidades por endereço
  final List<AddressAvailabilityEntity> addresses;
  
  /// Data de criação
  final DateTime createdAt;
  
  /// Última atualização
  final DateTime? updatedAt;
  
  const AvailabilityDayEntity({
    this.id,
    required this.date,
    this.generatedFrom,
    this.isOverridden = false,
    this.overrides,
    required this.addresses,
    required this.createdAt,
    this.updatedAt,
  });
  
  /// Retorna o ID do documento (YYYY-MM-DD)
  String get documentId {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
  
  /// Verifica se tem alguma disponibilidade neste dia
  bool get hasAvailability => 
      addresses.any((addr) => addr.hasAvailableSlots);
  
  /// Retorna todos os endereços com slots disponíveis
  List<AddressAvailabilityEntity> get availableAddresses => 
      addresses.where((addr) => addr.hasAvailableSlots).toList();
  
  /// Verifica se foi gerado de um padrão
  bool get isFromPattern => generatedFrom != null;
  
  /// Retorna o ID do padrão (se existir)
  String? get patternId => generatedFrom?.patternId;
}

/// Extension para referências do Firestore e cache
extension AvailabilityDayReference on AvailabilityDayEntity {
  /// Referência da collection no Firestore
  static CollectionReference firestoreCollection(
    FirebaseFirestore firestore,
    String artistId,
  ) {
    final artistRef = ArtistEntityReference.firebaseUidReference(
      firestore,
      artistId,
    );
    return artistRef.collection('AvailabilityDays');
  }
  
  /// Referência de um documento específico
  static DocumentReference firestoreDocument(
    FirebaseFirestore firestore,
    String artistId,
    String dayId,
  ) {
    return firestoreCollection(firestore, artistId).doc(dayId);
  }
  
  /// Key para cache local
  static String cacheKey(String artistId) {
    return 'availability_days_$artistId';
  }
  
  /// Key para cache de um dia específico
  static String cacheDayKey(String artistId, String dayId) {
    return 'availability_day_${artistId}_$dayId';
  }
  
  /// Key para cache de padrão
  static String cachePatternKey(String artistId, String patternId) {
    return 'availability_pattern_${artistId}_$patternId';
  }
}

/// Constantes para dias da semana
extension WeekdayConstants on AvailabilityDayEntity {
  static const List<String> codes = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  static const List<String> names = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
  
  static Map<String, String> get codeToName => {
    for (var i = 0; i < codes.length; i++) codes[i]: names[i],
  };
  
  static Map<String, String> get nameToCode => {
    for (var i = 0; i < names.length; i++) names[i]: codes[i],
  };
}
