import 'package:app/core/utils/timestamp_hook.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'chat_entity.mapper.dart';

/// Entidade que representa um chat entre cliente e artista
/// Armazenada em coleção: chats/{chatId}
/// 
/// O chatId segue o padrão: "contract_{contractId}"
/// Cada chat está vinculado a um contrato específico
@MappableClass(hook: TimestampHook())
class ChatEntity with ChatEntityMappable {
  /// ID do chat (padrão: "contract_{contractId}")
  final String chatId;

  /// ID do contrato associado
  final String contractId;

  /// UID do cliente
  final String clientId;

  /// UID do artista
  final String artistId;

  /// Nome do cliente
  final String clientName;

  /// Nome do artista
  final String artistName;

  /// URL da foto do cliente
  final String? clientPhoto;

  /// URL da foto do artista
  final String? artistPhoto;

  /// Status do chat: 'active', 'closed'
  final String status;

  /// Data de criação do chat
  final DateTime createdAt;

  /// Data da última mensagem
  final DateTime? lastMessageAt;

  /// Texto da última mensagem
  final String? lastMessage;

  /// ID do remetente da última mensagem
  final String? lastMessageSenderId;

  /// Contador de mensagens não lidas por usuário
  /// Exemplo: {'user1': 0, 'user2': 3}
  final Map<String, int> unreadCount;

  /// Status de digitação por usuário
  /// Exemplo: {'user1': false, 'user2': true}
  final Map<String, bool> typing;

  ChatEntity({
    required this.chatId,
    required this.contractId,
    required this.clientId,
    required this.artistId,
    required this.clientName,
    required this.artistName,
    this.clientPhoto,
    this.artistPhoto,
    required this.status,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
    this.lastMessageSenderId,
    required this.unreadCount,
    required this.typing,
  });

  /// Retorna o ID do outro participante do chat
  String getOtherUserId(String currentUserId) {
    return currentUserId == clientId ? artistId : clientId;
  }

  /// Retorna o nome do outro participante do chat
  String getOtherUserName(String currentUserId) {
    return currentUserId == clientId ? artistName : clientName;
  }

  /// Retorna a foto do outro participante do chat
  String? getOtherUserPhoto(String currentUserId) {
    return currentUserId == clientId ? artistPhoto : clientPhoto;
  }

  /// Retorna o número de mensagens não lidas para o usuário
  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }

  /// Verifica se o outro usuário está digitando
  bool isOtherUserTyping(String currentUserId) {
    final otherUserId = getOtherUserId(currentUserId);
    return typing[otherUserId] ?? false;
  }

  /// Verifica se o chat está ativo
  bool get isActive => status == 'active';

  /// Verifica se o chat está fechado
  bool get isClosed => status == 'closed';
}

extension ChatEntityReference on ChatEntity {
  /// Referência para a coleção de chats
  static CollectionReference chatsCollection(FirebaseFirestore firestore) {
    return firestore.collection('chats');
  }

  /// Referência para um documento específico de chat
  static DocumentReference chatDocument(
    FirebaseFirestore firestore,
    String chatId,
  ) {
    return chatsCollection(firestore).doc(chatId);
  }

  /// Referência para a subcoleção de mensagens de um chat
  static CollectionReference messagesCollection(
    FirebaseFirestore firestore,
    String chatId,
  ) {
    return chatDocument(firestore, chatId).collection('messages');
  }

  /// Referência para um documento específico de mensagem
  static DocumentReference messageDocument(
    FirebaseFirestore firestore,
    String chatId,
    String messageId,
  ) {
    return messagesCollection(firestore, chatId).doc(messageId);
  }

  /// Gera um chatId a partir de um contractId
  static String generateChatId(String contractId) {
    return 'contract_$contractId';
  }

  /// Extrai o contractId de um chatId
  static String extractContractId(String chatId) {
    return chatId.replaceFirst('contract_', '');
  }

  /// Chave para cache local de um chat específico
  static String cachedChatKey(String chatId) {
    return 'CACHED_CHAT_$chatId';
  }

  /// Chave para cache local da lista de chats de um usuário
  static String cachedUserChatsKey(String userId) {
    return 'CACHED_USER_CHATS_$userId';
  }
}
