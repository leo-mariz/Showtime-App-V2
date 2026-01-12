import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/event/event_type_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
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
  final String? refClient;            // UID do cliente/anfitrião
  
  // Tipo de contratado
  final ContractorTypeEnum contractorType; // ARTIST ou GROUP
  
  // Snapshots (para histórico, caso dados mudem)
  final String? nameArtist;           // Nome do artista no momento da solicitação
  final String? nameGroup;            // Nome do grupo (se aplicável)
  final String? nameClient;           // Nome do cliente no momento da solicitação
  
  // Snapshot da disponibilidade (para consulta futura)
  final AvailabilityEntity? availabilitySnapshot; // Snapshot da disponibilidade usada
  
  // Detalhes do evento
  final DateTime date;                // Data do evento
  final String time;                  // Hora de início (formato "HH:mm")
  final int duration;                 // Duração em minutos
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
  
  // Avaliação
  final double? rating;                // Avaliação do cliente (0.0 a 5.0)
  final String? ratingComment;         // Comentário da avaliação
  final DateTime? ratedAt;            // Data da avaliação
  
  // Timestamps
  final DateTime? createdAt;               // Data de criação da solicitação
  final DateTime? acceptedAt;         // Data de aceitação pelo artista
  final DateTime? rejectedAt;          // Data de recusa pelo artista
  final DateTime? canceledAt;          // Data de cancelamento
  final String? canceledBy;            // Quem cancelou ('CLIENT' ou 'ARTIST')
  final String? cancelReason;          // Motivo do cancelamento

  final bool? isPaying;
  
  ContractEntity({
    required this.date,
    required this.time,
    required this.duration,
    required this.address,
    required this.contractorType,
    required this.refClient,
    this.uid,
    this.refArtist,
    this.refGroup,
    this.nameArtist,
    this.nameGroup,
    this.nameClient,
    this.availabilitySnapshot,
    this.eventType,
    this.status = ContractStatusEnum.pending,
    this.value = 0.0,
    this.linkPayment,
    this.paymentDueDate,
    this.paymentDate,
    this.keyCode,
    this.showConfirmedAt,
    this.rating,
    this.ratingComment,
    this.ratedAt,
    DateTime? createdAt,
    this.acceptedAt,
    this.rejectedAt,
    this.canceledAt,
    this.canceledBy,
    this.cancelReason,
    this.isPaying = false,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // Validações de negócio
  bool get isPending => status == ContractStatusEnum.pending;
  bool get isAccepted => status == ContractStatusEnum.accepted;
  bool get isRejected => status == ContractStatusEnum.rejected;
  bool get isPaymentPending => status == ContractStatusEnum.paymentPending;
  bool get isPaid => status == ContractStatusEnum.paid;
  bool get isCompleted => status == ContractStatusEnum.completed;
  bool get canBeRated => isCompleted && rating == null;
  bool get isGroupContract => contractorType == ContractorTypeEnum.group;
  bool get isArtistContract => contractorType == ContractorTypeEnum.artist;
  
  // Retorna o UID correto baseado no tipo
  String? get contractorUid => isGroupContract ? refGroup : refArtist;
  String? get contractorName => isGroupContract ? nameGroup : nameArtist;
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

  static List<String> contractFields = [
    'uid',
    'refArtist',
    'refGroup',
    'refClient',
    'contractorType',
    'nameArtist',
    'nameGroup',
    'nameClient',
    'availabilitySnapshot',
    'date',
    'time',
    'duration',
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
  ];
}

