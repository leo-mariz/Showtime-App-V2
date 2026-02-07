import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/contract/rating_entity.dart';
import 'package:app/core/domain/event/event_type_entity.dart';
import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/enums/contractor_type_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'contract_entity.mapper.dart';

@MappableClass()
class ContractEntity with ContractEntityMappable {
  // Identificação
  final String? uid;
  
  // Referências (UIDs)
  final String? refArtist;           // UID do artista (se individual)
  final String? refGroup;             // UID do grupo (se grupo)
  /// UID do artista dono do conjunto (quando contractorType == group). Usado para atualizar índice do dono.
  final String? refArtistOwner;
  final String? refClient;            // UID do cliente/anfitrião
  
  // Tipo de contratado
  final ContractorTypeEnum contractorType; // ARTIST ou GROUP
  
  // Snapshots (para histórico, caso dados mudem)
  final String? nameArtist;           // Nome do artista no momento da solicitação
  final String? nameGroup;            // Nome do grupo (se aplicável)
  final String? nameClient;           // Nome do cliente no momento da solicitação
  final double? clientRating;          // Avaliação do cliente no momento da solicitação
  final int? clientRatingCount;        // Quantidade de avaliações do cliente no momento da solicitação
  
  // Snapshot da disponibilidade (para consulta futura)
  final AvailabilityDayEntity? availabilitySnapshot; // Snapshot da disponibilidade usada
  
  // Detalhes do evento
  final DateTime date;                // Data do evento
  final String time;                  // Hora de início (formato "HH:mm")
  final int duration;                 // Duração em minutos
  final int? preparationTime;          // Tempo de preparação em minutos
  final AddressInfoEntity address;     // Endereço do evento
  final EventTypeEntity? eventType;   // Tipo de evento
  
  // Status e fluxo
  final ContractStatusEnum status;     // Status principal do contrato
  
  // Pagamento
  final double value;                 // Valor total do contrato
  final String? linkPayment;           // Link de pagamento gerado
  final DateTime? paymentDueDate;      // Data limite para pagamento
  final DateTime? paymentDate;         // Data em que foi pago
  
  // Confirmação do show
  final String? keyCode;              // Código de confirmação (gerado após pagamento)
  final DateTime? showConfirmedAt;    // Data/hora em que o código foi validado
  final DateTime? ratingsPublishedAt;  // NOVO: quando ficam públicas
  
  // Avaliação
  final RatingEntity? rateByClient;
  final RatingEntity? rateByArtist;
  
  // Controle de avaliação do show (futuro)
  final bool? showRatingRequested;      // Dialog de avaliação foi mostrado?
  final bool? showRatingSkipped;       // Usuário pulou a avaliação?
  final bool? showRatingCompleted;     // Avaliação foi feita?
  final DateTime? showRatingRequestedAt; // Quando foi solicitado
  final String? showRatingRequestedFor; // 'CLIENT' ou 'ARTIST' (quem deve avaliar)
  
  // Timestamps
  final DateTime? createdAt;               // Data de criação da solicitação
  final DateTime? acceptedAt;         // Data de aceitação pelo artista
  final DateTime? rejectedAt;          // Data de recusa pelo artista
  final DateTime? canceledAt;          // Data de cancelamento
  final String? canceledBy;            // Quem cancelou ('CLIENT' ou 'ARTIST')
  final String? cancelReason;          // Motivo do cancelamento
  final DateTime? statusChangedAt;    // Data da última mudança de status (para rastreamento de notificações)
  final DateTime? acceptDeadline;    // Data/hora limite para o artista aceitar a solicitação

  /// URL da foto do anfitrião no momento da solicitação (snapshot para o card).
  final String? clientPhotoUrl;
  /// URL da foto do artista ou do conjunto no momento da solicitação (snapshot para o card).
  final String? contractorPhotoUrl;

  final bool? isPaying;
  
  ContractEntity({
    required this.date,
    required this.time,
    required this.duration,
    required this.preparationTime,
    required this.address,
    required this.contractorType,
    required this.refClient,
    this.uid,
    this.refArtist,
    this.refGroup,
    this.refArtistOwner,
    this.nameArtist,
    this.nameGroup,
    this.nameClient,
    this.clientRating,
    this.clientRatingCount,
    this.availabilitySnapshot,
    this.eventType,
    this.status = ContractStatusEnum.pending,
    this.value = 0.0,
    this.linkPayment,
    this.paymentDueDate,
    this.paymentDate,
    this.keyCode,
    this.showConfirmedAt,
    this.ratingsPublishedAt,
    this.rateByClient,
    this.rateByArtist,
    this.showRatingRequested,
    this.showRatingSkipped,
    this.showRatingCompleted,
    this.showRatingRequestedAt,
    this.showRatingRequestedFor,
    DateTime? createdAt,
    this.acceptedAt,
    this.rejectedAt,
    this.canceledAt,
    this.canceledBy,
    this.cancelReason,
    this.statusChangedAt,
    this.acceptDeadline,
    this.clientPhotoUrl,
    this.contractorPhotoUrl,
    this.isPaying = false,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // Validações de negócio
  bool get isPending => status == ContractStatusEnum.pending;
  bool get isRejected => status == ContractStatusEnum.rejected;
  bool get isPaymentPending => status == ContractStatusEnum.paymentPending;
  bool get isPaid => status == ContractStatusEnum.paid;
  bool get isCompleted => status == ContractStatusEnum.completed;
  bool get canBeRated => isCompleted && (rateByClient == null || rateByArtist == null);
  bool get isGroupContract => contractorType == ContractorTypeEnum.group;
  bool get isArtistContract => contractorType == ContractorTypeEnum.artist;
  
  // Retorna o UID correto baseado no tipo
  String? get contractorUid => isGroupContract ? refGroup : refArtist;
  String? get contractorName => isGroupContract ? nameGroup : nameArtist;
  
  /// Verifica se o prazo para aceitar a solicitação expirou (comparação em UTC)
  bool get isAcceptDeadlineExpired {
    if (acceptDeadline == null || !isPending) return false;
    final nowUtc = DateTime.now().toUtc();
    final d = acceptDeadline!;
    final deadlineUtc = d.isUtc ? d : DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second, d.millisecond);
    return nowUtc.isAfter(deadlineUtc);
  }

  /// Retorna o tempo restante até o deadline em UTC (ou null se expirado)
  Duration? get remainingTimeToAccept {
    if (acceptDeadline == null || !isPending) return null;
    final nowUtc = DateTime.now().toUtc();
    final d = acceptDeadline!;
    final deadlineUtc = d.isUtc ? d : DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second, d.millisecond);
    if (nowUtc.isAfter(deadlineUtc)) return null;
    return deadlineUtc.difference(nowUtc);
  }

  /// Verifica se o prazo para o anfitrião pagar expirou (comparação em UTC)
  bool get isPaymentDeadlineExpired {
    if (paymentDueDate == null || !isPaymentPending) return false;
    final nowUtc = DateTime.now().toUtc();
    final d = paymentDueDate!;
    final deadlineUtc = d.isUtc ? d : DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second, d.millisecond);
    return nowUtc.isAfter(deadlineUtc);
  }

  /// Tempo restante para o anfitrião pagar (UTC), ou null se expirado/não aplicável
  Duration? get remainingTimeToPay {
    if (paymentDueDate == null || !isPaymentPending) return null;
    final nowUtc = DateTime.now().toUtc();
    final d = paymentDueDate!;
    final deadlineUtc = d.isUtc ? d : DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second, d.millisecond);
    if (nowUtc.isAfter(deadlineUtc)) return null;
    return deadlineUtc.difference(nowUtc);
  }
}

extension ContractEntityReference on ContractEntity {
  static DocumentReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    return firestore.collection('Contracts').doc(uid);
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> firebaseStreamReference(
    FirebaseFirestore firestore, 
    String uid
  ) {
    return firestore.collection('Contracts').doc(uid).snapshots();
  }

  static CollectionReference firebaseCollectionReference(FirebaseFirestore firestore) {
    return firestore.collection('Contracts');
  }

  static Reference firestorageReference(String uid) {
    return FirebaseStorage.instance.ref().child('Contracts').child(uid);
  }

  static String cachedKey() {
    return 'CACHED_CONTRACT_INFO';
  }

  // ==================== CACHE VALIDITY (Constantes) ====================
  
  /// Validade do cache de contratos (10 minutos)
  static const Duration contractsCacheValidity = Duration(minutes: 1);

  static List<String> contractFields = [
    'uid',
    'refArtist',
    'refGroup',
    'refArtistOwner',
    'refClient',
    'contractorType',
    'nameArtist',
    'nameGroup',
    'nameClient',
    'availabilitySnapshot',
    'date',
    'time',
    'duration',
    'preparationTime',
    'address',
    'eventType',
    'status',
    'value',
    'linkPayment',
    'paymentDueDate',
    'paymentDate',
    'keyCode',
    'showConfirmedAt',
    'rating',
    'ratingComment',
    'ratedAt',
    'createdAt',
    'acceptedAt',
    'rejectedAt',
    'canceledAt',
    'canceledBy',
    'cancelReason',
    'statusChangedAt',
    'acceptDeadline',
    'clientPhotoUrl',
    'contractorPhotoUrl',
  ];
}

