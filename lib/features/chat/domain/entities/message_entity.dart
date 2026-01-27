import 'package:app/core/utils/timestamp_hook.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'message_entity.mapper.dart';

/// Entidade que representa uma mensagem em um chat
/// Armazenada em subcoleção: chats/{chatId}/messages/{messageId}
@MappableClass(hook: TimestampHook())
class MessageEntity with MessageEntityMappable {
  /// ID da mensagem
  final String messageId;

  /// UID do remetente (ou 'system' para mensagens do sistema)
  final String senderId;

  /// Conteúdo da mensagem
  final String text;

  /// Data/hora de criação da mensagem
  final DateTime createdAt;

  /// Status da mensagem: 'sent', 'delivered', 'read'
  final String status;

  /// Tipo da mensagem: 'text', 'system'
  final String type;

  MessageEntity({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.status,
    required this.type,
  });

  /// Verifica se é uma mensagem do sistema
  bool get isSystemMessage => type == 'system';

  /// Verifica se é uma mensagem de texto do usuário
  bool get isTextMessage => type == 'text';

  /// Verifica se a mensagem foi enviada
  bool get isSent => status == 'sent';

  /// Verifica se a mensagem foi entregue
  bool get isDelivered => status == 'delivered';

  /// Verifica se a mensagem foi lida
  bool get isRead => status == 'read';

  /// Verifica se a mensagem foi enviada por um usuário específico
  bool isSentByUser(String userId) => senderId == userId;

  /// Verifica se a mensagem foi enviada pelo sistema
  bool get isSentBySystem => senderId == 'system';
}

extension MessageEntityReference on MessageEntity {
  /// Referência para a subcoleção de mensagens de um chat
  static CollectionReference messagesCollection(
    FirebaseFirestore firestore,
    String chatId,
  ) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');
  }

  /// Referência para um documento específico de mensagem
  static DocumentReference messageDocument(
    FirebaseFirestore firestore,
    String chatId,
    String messageId,
  ) {
    return messagesCollection(firestore, chatId).doc(messageId);
  }

  /// Chave para cache local das mensagens de um chat
  static String cachedMessagesKey(String chatId) {
    return 'CACHED_MESSAGES_$chatId';
  }

  /// Chave para cache do timestamp da última mensagem carregada
  static String lastLoadedMessageKey(String chatId) {
    return 'LAST_LOADED_MESSAGE_$chatId';
  }
}
