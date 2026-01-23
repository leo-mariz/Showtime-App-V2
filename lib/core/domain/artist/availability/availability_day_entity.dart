import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/availability/pattern_metadata_entity.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/core/utils/timestamp_hook.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'availability_day_entity.mapper.dart';

/// Representa a disponibilidade de um artista em um dia específico
/// 
/// Este é o documento principal que armazena toda a informação de disponibilidade
/// Um dia pode conter múltiplas disponibilidades independentes (entries)
@MappableClass(hook: TimestampHook())
class AvailabilityDayEntity with AvailabilityDayEntityMappable {
  /// ID do documento (formato: YYYY-MM-DD)
  final String? id;
  
  /// Data específica deste dia
  final DateTime date;
  
  /// Lista de disponibilidades independentes neste dia
  /// 
  /// Cada entry pode ser:
  /// - De um padrão de recorrência diferente
  /// - Em endereços diferentes
  /// - Com horários e valores diferentes
  final List<TimeSlot>? slots;

  final List<PatternMetadata>? patternMetadata;

  /// Raio de atuação em km a partir do endereço base
  final double? raioAtuacao;
  
  /// Informações completas do endereço base
  final AddressInfoEntity? endereco;

  /// Indica se a disponibilidade foi editada manualmente
  final bool isManualOverride;
  
  /// Data de criação do documento
  final DateTime? createdAt;
  
  /// Última atualização do documento
  final DateTime? updatedAt;

  /// Indica se o dia está ativo
  final bool isActive;
  
  const AvailabilityDayEntity({
    this.id,
    required this.date,
    this.slots,
    this.raioAtuacao,
    this.endereco,
    required this.isManualOverride,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.patternMetadata,
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
      slots?.any((slot) => slot.valorHora != null) ?? false;
  
  /// Retorna todas as availabilities com slots disponíveis
  List<TimeSlot> get availableSlots => 
      slots?.where((slot) => slot.valorHora != null).toList() ?? [];
  
  /// Retorna lista de IDs de padrões presentes neste dia
  List<String> get patternIds => 
      slots
          ?.where((slot) => slot.sourcePatternId != null)
          .map((slot) => slot.sourcePatternId!)
          .toSet()
          .toList() ?? [];
  
  /// Verifica se tem alguma availability de um padrão específico
  bool hasPattern(String patternId) =>
      patternIds.contains(patternId);
  
  /// Retorna availabilities de um padrão específico
  List<TimeSlot> getSlotsByPattern(String patternId) =>
      slots?.where((slot) => slot.sourcePatternId == patternId).toList() ?? [];
  
  /// Verifica se tem availabilities que podem ser editadas via padrão
  bool get hasEditableViaPattern =>
      slots?.any((slot) => slot.sourcePatternId != null) ?? false;
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
