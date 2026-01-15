import 'package:app/core/domain/chat/message_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Interface para operações remotas (Firestore) de mensagens
abstract class IChatRemoteDataSource {
  /// Envia uma nova mensagem
  /// Retorna o UID da mensagem criada
  /// Lança [ServerException] em caso de erro
  Future<String> sendMessage({
    required String contractId,
    required MessageEntity message,
  });

  /// Busca todas as mensagens de um contrato (ordenadas por timestamp)
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<MessageEntity>> getMessages({
    required String contractId,
  });

  /// Stream de mensagens em tempo real
  /// Retorna um Stream que emite QuerySnapshot quando há mudanças
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesStream({
    required String contractId,
  });

  /// Marca mensagens específicas como lidas
  /// Lança [ServerException] em caso de erro
  Future<void> markMessagesAsRead({
    required String contractId,
    required List<String> messageIds,
    required String readerId,
  });

  /// Marca todas as mensagens não lidas de um contrato como lidas
  /// Lança [ServerException] em caso de erro
  Future<void> markAllMessagesAsRead({
    required String contractId,
    required String readerId,
  });
}

/// Implementação do DataSource remoto (Firestore) para mensagens
/// 
/// REGRAS:
/// - Lança [ServerException] em caso de erro do Firestore
/// - Lança [ValidationException] em caso de validação falhar
/// - Converte Timestamps do Firestore para DateTime antes do mapeamento
/// - NÃO faz validações de negócio
class ChatRemoteDataSourceImpl implements IChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  CollectionReference _messagesCollection(String contractId) => MessageEntityReference.messagesCollection(firestore, contractId);

  static const String _timestampField = 'timestamp';
  static const String _uidField = 'uid';
  static const String _isReadField = 'isRead';  



  @override
  Future<String> sendMessage({
    required String contractId,
    required MessageEntity message,
  }) async {
    try {
      if (contractId.isEmpty) {
        throw const ValidationException(
          'ID do contrato não pode ser vazio',
        );
      }

      if (message.text.isEmpty) {
        throw const ValidationException(
          'Texto da mensagem não pode ser vazio',
        );
      }

      final messagesCollection = _messagesCollection(contractId);

      // Converter mensagem para Map, removendo o UID (será gerado pelo Firestore)
      final messageMap = message.toMap();
      messageMap.remove(_uidField);

      // Garantir que o timestamp está presente
      if (!messageMap.containsKey(_timestampField) || messageMap[_timestampField] == null) {
        messageMap[_timestampField] = FieldValue.serverTimestamp();
      }

      final docRef = await messagesCollection.add(messageMap);
      return docRef.id;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao enviar mensagem no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;

      throw ServerException(
        'Erro inesperado ao enviar mensagem',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<MessageEntity>> getMessages({
    required String contractId,
  }) async {
    try {
      if (contractId.isEmpty) {
        throw const ValidationException(
          'ID do contrato não pode ser vazio',
        );
      }

      final messagesCollection = _messagesCollection(contractId);

      final querySnapshot = await messagesCollection
          .orderBy(_timestampField, descending: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            try {
              final messageMap = doc.data() as Map<String, dynamic>;
              // Converter Timestamps para DateTime antes do mapeamento
              final convertedMap = _convertTimestampsToDateTime(messageMap);
              final message = MessageEntityMapper.fromMap(convertedMap);
              return message.copyWith(uid: doc.id);
            } catch (e, stackTrace) {
              // Log detalhado do erro para debug
              debugPrint('❌ Erro ao mapear mensagem ${doc.id}: $e');
              debugPrint('📄 Dados do documento: ${doc.data()}');
              debugPrint('📚 Stack trace: $stackTrace');
              rethrow;
            }
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar mensagens no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;

      throw ServerException(
        'Erro inesperado ao buscar mensagens',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesStream({
    required String contractId,
  }) {
    if (contractId.isEmpty) {
      throw const ValidationException(
        'ID do contrato não pode ser vazio',
      );
    }

    try {
      final messagesCollection = _messagesCollection(contractId);

      return messagesCollection
          .orderBy(_timestampField, descending: false)
          .snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro ao criar stream de mensagens',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> markMessagesAsRead({
    required String contractId,
    required List<String> messageIds,
    required String readerId,
  }) async {
    try {
      if (contractId.isEmpty) {
        throw const ValidationException(
          'ID do contrato não pode ser vazio',
        );
      }

      if (messageIds.isEmpty) {
        throw const ValidationException(
          'Lista de IDs de mensagens não pode estar vazia',
        );
      }

      if (readerId.isEmpty) {
        throw const ValidationException(
          'ID do leitor não pode ser vazio',
        );
      }

      final messagesCollection = _messagesCollection(contractId);

      // Atualizar cada mensagem em batch
      final batch = firestore.batch();
      
      for (final messageId in messageIds) {
        final messageRef = messagesCollection.doc(messageId);
        batch.update(messageRef, {_isReadField: true});
      }

      await batch.commit();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao marcar mensagens como lidas no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;

      throw ServerException(
        'Erro inesperado ao marcar mensagens como lidas',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> markAllMessagesAsRead({
    required String contractId,
    required String readerId,
  }) async {
    try {
      if (contractId.isEmpty) {
        throw const ValidationException(
          'ID do contrato não pode ser vazio',
        );
      }

      if (readerId.isEmpty) {
        throw const ValidationException(
          'ID do leitor não pode ser vazio',
        );
      }

      final messagesCollection = _messagesCollection(contractId);

      // Buscar todas as mensagens não lidas
      final querySnapshot = await messagesCollection
          .where(_isReadField, isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return;
      }

      // Atualizar em batch
      final batch = firestore.batch();
      
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {_isReadField: true});
      }

      await batch.commit();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao marcar todas as mensagens como lidas no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;

      throw ServerException(
        'Erro inesperado ao marcar todas as mensagens como lidas',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converte Timestamps do Firestore para DateTime
  Map<String, dynamic> _convertTimestampsToDateTime(Map<String, dynamic> map) {
    final convertedMap = Map<String, dynamic>.from(map);

    // Campo timestamp
    if (convertedMap.containsKey(_timestampField) && convertedMap[_timestampField] != null) {
      if (convertedMap[_timestampField] is Timestamp) {
        convertedMap[_timestampField] = (convertedMap[_timestampField] as Timestamp).toDate();
      } else if (convertedMap[_timestampField] is String) {
        // Se for String ISO, tentar converter
        try {
          convertedMap[_timestampField] = DateTime.parse(convertedMap[_timestampField] as String);
        } catch (e) {
          debugPrint('⚠️ Erro ao converter timestamp de String para DateTime: $e');
        }
      }
    }

    return convertedMap;
  }
}