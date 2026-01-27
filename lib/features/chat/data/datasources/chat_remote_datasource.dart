import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:app/features/chat/domain/entities/user_chat_info_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface para operações remotas (Firestore) de chat
abstract class IChatRemoteDataSource {
  /// Cria um novo chat no Firestore
  Future<ChatEntity> createChat({
    required String contractId,
    required String clientId,
    required String artistId,
    required String clientName,
    required String artistName,
    String? clientPhoto,
    String? artistPhoto,
  });

  /// Busca um chat por ID do Firestore
  Future<ChatEntity> getChatById(String chatId);

  /// Stream de um chat específico
  Stream<ChatEntity> getChatStream(String chatId);

  /// Stream de todos os chats de um usuário
  Stream<List<ChatEntity>> getUserChatsStream(String userId);

  /// Fecha um chat
  Future<void> closeChat(String chatId);

  /// Envia uma mensagem em um chat
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  });

  /// Stream de mensagens de um chat
  Stream<List<MessageEntity>> getMessagesStream({
    required String chatId,
    int limit = 50,
  });

  /// Busca mensagens paginadas
  Future<List<MessageEntity>> getMessagesPaginated({
    required String chatId,
    int limit = 50,
    DateTime? beforeDate,
  });

  /// Marca mensagens como lidas
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  });

  /// Atualiza status de digitação
  Future<void> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  });

  /// Stream do contador de mensagens não lidas
  Stream<int> getUnreadCountStream(String userId);
}

/// Implementação do datasource remoto de chat
class ChatRemoteDataSourceImpl implements IChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ChatEntity> createChat({
    required String contractId,
    required String clientId,
    required String artistId,
    required String clientName,
    required String artistName,
    String? clientPhoto,
    String? artistPhoto,
  }) async {
    try {
      final chatId = ChatEntityReference.generateChatId(contractId);
      final now = Timestamp.now();

      // Preparar dados do chat
      final chatData = {
        'chatId': chatId,
        'contractId': contractId,
        'clientId': clientId,
        'artistId': artistId,
        'clientName': clientName,
        'artistName': artistName,
        'clientPhoto': clientPhoto,
        'artistPhoto': artistPhoto,
        'status': 'active',
        'createdAt': now,
        'lastMessageAt': now,
        'lastMessage': null,
        'lastMessageSenderId': null,
        'unreadCount': {
          clientId: 0,
          artistId: 0,
        },
        'typing': {
          clientId: false,
          artistId: false,
        },
      };

      // Batch write para atomicidade
      final batch = firestore.batch();

      // 1. Criar documento do chat
      final chatRef = ChatEntityReference.chatDocument(firestore, chatId);
      batch.set(chatRef, chatData);

      // 2. Criar índice para o cliente
      final clientIndexRef =
          firestore.collection('user_chats').doc(clientId);
      batch.set(
        clientIndexRef,
        {
          'totalUnread': 0,
          'activeChatsCount': FieldValue.increment(1),
          'lastUpdate': now,
          'chats.$chatId': {
            'unread': 0,
            'lastMessageAt': now,
            'otherUserId': artistId,
            'otherUserName': artistName,
            'otherUserPhoto': artistPhoto,
            'lastMessage': '',
            'contractId': contractId,
          },
        },
        SetOptions(merge: true),
      );

      // 3. Criar índice para o artista
      final artistIndexRef =
          firestore.collection('user_chats').doc(artistId);
      batch.set(
        artistIndexRef,
        {
          'totalUnread': 0,
          'activeChatsCount': FieldValue.increment(1),
          'lastUpdate': now,
          'chats.$chatId': {
            'unread': 0,
            'lastMessageAt': now,
            'otherUserId': clientId,
            'otherUserName': clientName,
            'otherUserPhoto': clientPhoto,
            'lastMessage': '',
            'contractId': contractId,
          },
        },
        SetOptions(merge: true),
      );

      // 4. Criar mensagem de sistema inicial
      final systemMessageRef =
          ChatEntityReference.messagesCollection(firestore, chatId).doc();
      batch.set(systemMessageRef, {
        'messageId': systemMessageRef.id,
        'senderId': 'system',
        'text': 'Conversa iniciada. Discutam os detalhes do evento aqui.',
        'createdAt': now,
        'status': 'sent',
        'type': 'system',
      });

      await batch.commit();

      // Converter para entity
      final chatEntity = ChatEntityMapper.fromMap(chatData);
      return chatEntity;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao criar chat');
    } catch (e) {
      throw ServerException('Erro desconhecido ao criar chat: $e');
    }
  }

  @override
  Future<ChatEntity> getChatById(String chatId) async {
    try {
      final doc = await ChatEntityReference.chatDocument(firestore, chatId).get();
      
      if (!doc.exists) {
        throw NotFoundException('Chat não encontrado');
      }

      final data = doc.data() as Map<String, dynamic>;
      return ChatEntityMapper.fromMap(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao buscar chat');
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Erro desconhecido ao buscar chat: $e');
    }
  }

  @override
  Stream<ChatEntity> getChatStream(String chatId) {
    try {
      return ChatEntityReference.chatDocument(firestore, chatId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          throw NotFoundException('Chat não encontrado');
        }
        final data = doc.data() as Map<String, dynamic>;
        return ChatEntityMapper.fromMap(data);
      });
    } catch (e) {
      throw ServerException('Erro ao criar stream do chat: $e');
    }
  }

  @override
  Stream<List<ChatEntity>> getUserChatsStream(String userId) {
    try {
      
      // Escutar documento user_chats/{userId} para usar como índice
      // Isso elimina necessidade de índices compostos e melhora performance
      return UserChatInfoEntityReference.userChatDocument(firestore, userId)
          .snapshots()
          .asyncMap((userChatDoc) async {
        
        // Se documento não existe, retornar lista vazia
        if (!userChatDoc.exists) {
          return <ChatEntity>[];
        }

        final data = userChatDoc.data() as Map<String, dynamic>?;
        
        if (data == null || !data.containsKey('chats')) {
          return <ChatEntity>[];
        }

        // Extrair mapa de chats do documento
        final chatsMap = data['chats'] as Map<String, dynamic>? ?? {};
        
        if (chatsMap.isEmpty) {
          return <ChatEntity>[];
        }

        // Buscar cada chat completo em paralelo
        final chatIds = chatsMap.keys.toList();
        
        final chatFutures = chatIds.map((chatId) async {
          try {
            final chatDoc = await ChatEntityReference.chatDocument(firestore, chatId).get();
            
            if (!chatDoc.exists) {
              return null;
            }
            
            final chatData = chatDoc.data() as Map<String, dynamic>;
            
            // Converter Timestamp para DateTime manualmente
            final convertedData = Map<String, dynamic>.from(chatData);
            if (convertedData['createdAt'] is Timestamp) {
              convertedData['createdAt'] = (convertedData['createdAt'] as Timestamp).toDate();
            }
            if (convertedData['lastMessageAt'] is Timestamp) {
              convertedData['lastMessageAt'] = (convertedData['lastMessageAt'] as Timestamp).toDate();
            }
            
            return ChatEntityMapper.fromMap(convertedData);
          } catch (e) {
            // Se falhar ao buscar um chat específico, apenas pular
            return null;
          }
        });

        // Aguardar todos os chats e filtrar nulos
        final chats = await Future.wait(chatFutures);
        final validChats = chats.whereType<ChatEntity>().toList();
        

        // Ordenar por data da última mensagem (mais recente primeiro)
        validChats.sort((a, b) {
          if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
          if (a.lastMessageAt == null) return 1;
          if (b.lastMessageAt == null) return -1;
          return b.lastMessageAt!.compareTo(a.lastMessageAt!);
        });

        return validChats;
      });
    } catch (e) {
      throw ServerException('Erro ao criar stream de chats do usuário: $e');
    }
  }

  @override
  Future<void> closeChat(String chatId) async {
    try {
      final batch = firestore.batch();

      // 1. Atualizar status do chat
      final chatRef = ChatEntityReference.chatDocument(firestore, chatId);
      batch.update(chatRef, {'status': 'closed'});

      // 2. Adicionar mensagem de sistema
      final messageRef =
          ChatEntityReference.messagesCollection(firestore, chatId).doc();
      batch.set(messageRef, {
        'messageId': messageRef.id,
        'senderId': 'system',
        'text': 'Chat encerrado.',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'sent',
        'type': 'system',
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao fechar chat');
    } catch (e) {
      throw ServerException('Erro desconhecido ao fechar chat: $e');
    }
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      
      final now = Timestamp.now();

      // Buscar dados do chat
      final chatDoc = await ChatEntityReference.chatDocument(firestore, chatId).get();
      
      if (!chatDoc.exists) {
        throw NotFoundException('Chat não encontrado');
      }

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final clientId = chatData['clientId'] as String;
      final artistId = chatData['artistId'] as String;
      final receiverId = senderId == clientId ? artistId : clientId;
      
      final batch = firestore.batch();

      // 1. Adicionar mensagem
      final messageRef =
          ChatEntityReference.messagesCollection(firestore, chatId).doc();
      batch.set(messageRef, {
        'messageId': messageRef.id,
        'senderId': senderId,
        'text': text,
        'createdAt': now,
        'status': 'sent',
        'type': 'text',
      });

      // 2. Atualizar chat
      final lastMessage = text.length > 100 ? '${text.substring(0, 100)}...' : text;
      final chatRef = ChatEntityReference.chatDocument(firestore, chatId);
      batch.update(chatRef, {
        'lastMessage': lastMessage,
        'lastMessageAt': now,
        'lastMessageSenderId': senderId,
        'unreadCount.$receiverId': FieldValue.increment(1),
      });

      // 3. Atualizar índice do receptor
      final receiverIndexRef = firestore.collection('user_chats').doc(receiverId);
      batch.update(receiverIndexRef, {
        'totalUnread': FieldValue.increment(1),
        'chats.$chatId.unread': FieldValue.increment(1),
        'chats.$chatId.lastMessageAt': now,
        'chats.$chatId.lastMessage': lastMessage,
        'lastUpdate': now,
      });

      // 4. Atualizar índice do remetente (para atualizar o card na lista de chats)
      final senderIndexRef = firestore.collection('user_chats').doc(senderId);
      batch.update(senderIndexRef, {
        'chats.$chatId.lastMessageAt': now,
        'chats.$chatId.lastMessage': lastMessage,
        'lastUpdate': now,
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao enviar mensagem');
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Erro desconhecido ao enviar mensagem: $e');
    }
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream({
    required String chatId,
    int limit = 50,
  }) {
    try {
      return ChatEntityReference.messagesCollection(firestore, chatId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            
            // Converter Timestamp para DateTime manualmente
            final convertedData = Map<String, dynamic>.from(data);
            if (convertedData['createdAt'] is Timestamp) {
              convertedData['createdAt'] = (convertedData['createdAt'] as Timestamp).toDate();
            }
            
            return MessageEntityMapper.fromMap(convertedData);
          } catch (e) {
            rethrow;
          }
        }).toList();
      });
    } catch (e) {
      throw ServerException('Erro ao criar stream de mensagens: $e');
    }
  }

  @override
  Future<List<MessageEntity>> getMessagesPaginated({
    required String chatId,
    int limit = 50,
    DateTime? beforeDate,
  }) async {
    try {
      Query query = ChatEntityReference.messagesCollection(firestore, chatId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (beforeDate != null) {
        query = query.where('createdAt',
            isLessThan: Timestamp.fromDate(beforeDate));
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Converter Timestamp para DateTime manualmente
        final convertedData = Map<String, dynamic>.from(data);
        if (convertedData['createdAt'] is Timestamp) {
          convertedData['createdAt'] = (convertedData['createdAt'] as Timestamp).toDate();
        }
        
        return MessageEntityMapper.fromMap(convertedData);
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao buscar mensagens paginadas');
    } catch (e) {
      throw ServerException('Erro desconhecido ao buscar mensagens: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      final batch = firestore.batch();

      // 1. Resetar contador no chat
      final chatRef = ChatEntityReference.chatDocument(firestore, chatId);
      batch.update(chatRef, {
        'unreadCount.$userId': 0,
      });

      // 2. Buscar unread atual para calcular decremento
      final userChatsDoc =
          await firestore.collection('user_chats').doc(userId).get();

      if (userChatsDoc.exists) {
        final data = userChatsDoc.data() as Map<String, dynamic>;
        final chatsMap = data['chats'] as Map<String, dynamic>?;
        final currentUnread = chatsMap?[chatId]?['unread'] as int? ?? 0;

        // 3. Atualizar índice do usuário
        final userIndexRef = firestore.collection('user_chats').doc(userId);
        batch.update(userIndexRef, {
          'totalUnread': FieldValue.increment(-currentUnread),
          'chats.$chatId.unread': 0,
          'lastUpdate': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao marcar mensagens como lidas');
    } catch (e) {
      throw ServerException('Erro desconhecido ao marcar mensagens: $e');
    }
  }

  @override
  Future<void> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await ChatEntityReference.chatDocument(firestore, chatId).update({
        'typing.$userId': isTyping,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao atualizar status de digitação');
    } catch (e) {
      throw ServerException('Erro desconhecido ao atualizar digitação: $e');
    }
  }

  @override
  Stream<int> getUnreadCountStream(String userId) {
    try {
      return firestore
          .collection('user_chats')
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return 0;
        final data = doc.data() as Map<String, dynamic>;
        return (data['totalUnread'] as int?) ?? 0;
      });
    } catch (e) {
      throw ServerException('Erro ao criar stream de mensagens não lidas: $e');
    }
  }
}
