import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:app/core/enums/message_sender_type_enum.dart';

part 'message_entity.mapper.dart';

/// Entidade que representa uma mensagem no chat de um contrato
/// Armazenada em subcoleção: Contracts/{contractId}/Messages/{messageId}
/// 
/// Suporta mensagens de usuários (cliente/artista) e mensagens do sistema
@MappableClass()
class MessageEntity with MessageEntityMappable {
  /// UID da mensagem (gerado pelo Firestore)
  final String? uid;
  
  /// UID do contrato ao qual esta mensagem pertence
  final String contractId;
  
  /// Texto da mensagem
  final String text;
  
  /// UID do remetente (se senderType == USER, é o UID do cliente/artista)
  /// Se senderType == SYSTEM, pode ser null ou um identificador do sistema
  final String? senderId;
  
  /// Nome do remetente (para exibição)
  final String? senderName;
  
  /// Tipo de remetente (USER ou SYSTEM)
  final MessageSenderTypeEnum senderType;
  
  /// Timestamp de criação da mensagem
  final DateTime timestamp;
  
  /// Se a mensagem foi lida (apenas para mensagens de USER)
  final bool isRead;
  
  /// URL da foto de perfil do remetente (opcional, apenas para USER)
  final String? senderAvatarUrl;

  MessageEntity({
    this.uid,
    required this.contractId,
    required this.text,
    this.senderId,
    this.senderName,
    required this.senderType,
    DateTime? timestamp,
    this.isRead = false,
    this.senderAvatarUrl,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Verifica se a mensagem foi enviada pelo sistema
  bool get isSystemMessage => senderType == MessageSenderTypeEnum.system;
  
  /// Verifica se a mensagem foi enviada por um usuário
  bool get isUserMessage => senderType == MessageSenderTypeEnum.user;
}

extension MessageEntityReference on MessageEntity {
  /// Referência para a coleção de mensagens de um contrato
  static CollectionReference messagesCollection(
    FirebaseFirestore firestore,
    String contractId,
  ) {
    return firestore
        .collection('Contracts')
        .doc(contractId)
        .collection('Messages');
  }

  /// Referência para um documento específico de mensagem
  static DocumentReference messageDocument(
    FirebaseFirestore firestore,
    String contractId,
    String messageId,
  ) {
    return messagesCollection(firestore, contractId).doc(messageId);
  }

  /// Stream para escutar mensagens em tempo real
  static Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(
    FirebaseFirestore firestore,
    String contractId,
  ) {
    return messagesCollection(firestore, contractId)
        .orderBy('timestamp', descending: false)
        .snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }

  /// Chave para cache local das mensagens de um contrato
  static String cachedMessagesKey(String contractId) {
    return 'CACHED_MESSAGES_$contractId';
  }
}