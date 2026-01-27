import 'package:app/core/enums/chat_user_role_enum.dart';
import 'package:app/core/utils/timestamp_hook.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'user_chat_info_entity.mapper.dart';

/// Entidade de índice para chats de um usuário
/// Armazenada em coleção: user_chats/{userId}
/// 
/// Esta coleção serve como índice otimizado para:
/// - Buscar todos os chats de um usuário rapidamente
/// - Contar mensagens não lidas totais
/// - Evitar queries complexas em múltiplos chats
@MappableClass(hook: TimestampHook())
class UserChatInfoEntity with UserChatInfoEntityMappable {
  /// UID do usuário
  final String userId;

  /// Total de mensagens não lidas em todos os chats
  final int totalUnread;

  /// Número de chats ativos
  final int activeChatsCount;

  /// Data da última atualização
  final DateTime lastUpdate;

  /// Mapa de previews dos chats do usuário
  /// Chave: chatId, Valor: ChatPreviewEntity
  final Map<String, ChatPreviewEntity> chats;

  UserChatInfoEntity({
    required this.userId,
    required this.totalUnread,
    required this.activeChatsCount,
    required this.lastUpdate,
    required this.chats,
  });

  /// Retorna a lista de ChatPreviewEntity ordenada por data da última mensagem
  List<ChatPreviewEntity> get sortedChats {
    final list = chats.values.toList();
    list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return list;
  }

  /// Verifica se há mensagens não lidas
  bool get hasUnreadMessages => totalUnread > 0;
}

/// Preview de um chat para exibição em lista
@MappableClass(hook: TimestampHook())
class ChatPreviewEntity with ChatPreviewEntityMappable {
  /// ID do chat
  final String chatId;

  /// Role do usuário no chat (client ou artist)
  final ChatUserRoleEnum userRole;

  /// Número de mensagens não lidas neste chat
  final int unread;

  /// Data da última mensagem
  final DateTime lastMessageAt;

  /// UID do outro participante
  final String otherUserId;

  /// Nome do outro participante
  final String otherUserName;

  /// URL da foto do outro participante
  final String? otherUserPhoto;

  /// Texto da última mensagem
  final String lastMessage;

  /// ID do contrato associado
  final String contractId;

  ChatPreviewEntity({
    required this.chatId,
    required this.userRole,
    required this.unread,
    required this.lastMessageAt,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
    required this.lastMessage,
    required this.contractId,
  });

  /// Verifica se há mensagens não lidas neste chat
  bool get hasUnreadMessages => unread > 0;

  /// Retorna a última mensagem truncada (máx 100 caracteres)
  String get lastMessagePreview {
    if (lastMessage.isEmpty) return '';
    return lastMessage.length > 100
        ? '${lastMessage.substring(0, 100)}...'
        : lastMessage;
  }
}

extension UserChatInfoEntityReference on UserChatInfoEntity {
  /// Referência para a coleção de índices de chats dos usuários
  static CollectionReference userChatsCollection(FirebaseFirestore firestore) {
    return firestore.collection('user_chats');
  }

  /// Referência para um documento específico de índice de usuário
  static DocumentReference userChatDocument(
    FirebaseFirestore firestore,
    String userId,
  ) {
    return userChatsCollection(firestore).doc(userId);
  }

  /// Chave para cache local do índice de chats de um usuário
  static String cachedUserChatInfoKey(String userId) {
    return 'CACHED_USER_CHAT_INFO_$userId';
  }

  /// Chave para cache do timestamp de unread count
  static String unreadCountCacheKey(String userId) {
    return 'UNREAD_COUNT_$userId';
  }
}
