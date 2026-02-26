import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/domain/contract/key_code_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/firebase_functions_service.dart';
import 'package:app/core/utils/firestore_mapper_helper.dart';
import 'package:app/features/contracts/domain/entities/user_contracts_index_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Interface do DataSource remoto (Firestore) para Contracts
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações de lógica
abstract class IContractRemoteDataSource {
  /// Busca um contrato específico por UID
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o contrato não existir
  Future<ContractEntity> getContract(String contractUid);
  
  /// Busca lista de contratos por cliente
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<ContractEntity>> getContractsByClient(String clientUid);
  
  /// Busca lista de contratos por artista
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<ContractEntity>> getContractsByArtist(String artistUid);
  
  /// Busca lista de contratos por grupo
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<ContractEntity>> getContractsByGroup(String groupUid);
  
  /// Adiciona um novo contrato
  /// Retorna o UID do contrato criado
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se UID não estiver presente
  Future<String> addContract(ContractEntity contract);
  
  /// Atualiza um contrato existente
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o contrato não existir
  Future<void> updateContract(ContractEntity contract);
  
  /// Remove um contrato
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o contrato não existir
  Future<void> deleteContract(String contractUid);
  
  /// Busca o código de confirmação (keyCode) de um contrato
  /// Retorna null se não existir
  /// Lança [ServerException] em caso de erro
  Future<String?> getKeyCode(String contractUid);
  
  /// Salva/atualiza o código de confirmação (keyCode) de um contrato
  /// Lança [ServerException] em caso de erro
  Future<void> setKeyCode(String contractUid, String keyCode);

  // ==================== CONTRACTS INDEX OPERATIONS ====================

  /// Stream do índice de contratos do usuário
  /// 
  /// Escuta o documento user_contracts_index/{userId} que contém:
  /// - Contadores totais por tab
  /// - Contadores de não vistos por tab
  /// - Timestamps de última visualização
  /// 
  /// Lança [ServerException] em caso de erro
  Stream<UserContractsIndexEntity> getContractsIndexStream(String userId);

  /// Marca uma tab como vista
  /// 
  /// Atualiza o timestamp lastSeenTab{index} no índice
  /// [isArtist] - Define qual role usar (artista ou cliente) para marcar como visto
  /// Lança [ServerException] em caso de erro
  Future<void> markTabAsSeen(String userId, int tabIndex, {bool isArtist = false});

  /// Atualiza o índice de contratos com os valores fornecidos
  /// 
  /// [updates] - Map com os campos a serem atualizados
  /// Lança [ServerException] em caso de erro
  Future<void> updateContractsIndex(String userId, Map<String, dynamic> updates);

  // ==================== AVAILABILITY FUNCTIONS ====================

  /// Verifica se a disponibilidade do artista ainda é válida para o contrato
  /// 
  /// Lança [ServerException] em caso de erro
  /// Retorna Map com resultado da verificação:
  /// - isValid: bool
  /// - reason?: string (se inválido)
  /// - availableSlots?: Array (se válido)
  /// - distance?: number
  /// - withinRadius?: bool
  Future<Map<String, dynamic>> verifyContractAvailability({
    required String contractId,
    required String artistId,
    required String date, // YYYY-MM-DD
    required String time, // HH:mm
    required int duration, // minutos
    required Map<String, dynamic> address,
    required double value,
    Map<String, dynamic>? availabilitySnapshot,
  });

  /// Libera slot de disponibilidade após cancelamento de contrato PAID
  /// 
  /// Lança [ServerException] em caso de erro
  /// Retorna Map com resultado:
  /// - success: bool
  /// - releasedSlot?: {startTime, endTime, valorHora}
  /// - error?: string
  Future<Map<String, dynamic>> releaseAvailabilitySlotAfterCancel({
    required String contractId,
    required String artistId,
    required String date, // YYYY-MM-DD
  });

  /// Verifica se o contrato tem overlap com algum slot BOOKED na disponibilidade do artista
  /// 
  /// A função recebe apenas o ID do contrato; data, hora, duração e artista são obtidos no servidor
  /// Retorna true se há overlap com slot já reservado
  /// Lança [ServerException] em caso de erro
  Future<bool> checkContractOverlapWithBooked(String contractId);
}

/// Implementação do DataSource remoto usando Firestore
class ContractRemoteDataSourceImpl implements IContractRemoteDataSource {
  final FirebaseFirestore firestore;
  final IFirebaseFunctionsService firebaseFunctionsService;

  ContractRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseFunctionsService,
  });

  /// Converte todos os Timestamps do Firestore para DateTime no mapa
  /// Isso é necessário porque o dart_mappable espera DateTime, não Timestamp
  /// Converte Timestamps do índice de contratos para DateTime
  Map<String, dynamic> _convertIndexTimestampsToDateTime(Map<String, dynamic> map) {
    final convertedMap = Map<String, dynamic>.from(map);
    
    // Lista de campos que podem ser Timestamp no índice
    final indexDateFields = [
      'lastSeenArtistTab0',
      'lastSeenArtistTab1',
      'lastSeenArtistTab2',
      'lastSeenClientTab0',
      'lastSeenClientTab1',
      'lastSeenClientTab2',
      'lastUpdate',
    ];
    
    // Converter campos de data do índice
    for (final field in indexDateFields) {
      if (convertedMap.containsKey(field) && convertedMap[field] != null) {
        if (convertedMap[field] is Timestamp) {
          convertedMap[field] = (convertedMap[field] as Timestamp).toDate();
        } else if (convertedMap[field] is String) {
          // Se for String ISO, tentar converter
          try {
            convertedMap[field] = DateTime.parse(convertedMap[field] as String);
          } catch (e) {
            debugPrint('⚠️ Erro ao converter $field de String para DateTime: $e');
          }
        }
      }
    }
    
    return convertedMap;
  }

  @override
  Future<ContractEntity> getContract(String contractUid) async {
    try {
      if (contractUid.isEmpty) {
        throw const ValidationException(
          'UID do contrato não pode ser vazio',
        );
      }

      final documentReference = ContractEntityReference.firebaseUidReference(
        firestore,
        contractUid,
      );

      final snapshot = await documentReference.get();
      
      if (!snapshot.exists) {
        throw NotFoundException('Contrato não encontrado: $contractUid');
      }

      final contractMap = snapshot.data() as Map<String, dynamic>;
      try {
        // Converter Timestamps para DateTime antes do mapeamento
        final convertedMap = convertFirestoreMapForMapper(contractMap);
        final contract = ContractEntityMapper.fromMap(convertedMap);
      return contract.copyWith(uid: snapshot.id);
      } catch (e, stackTrace) {
        // Log detalhado do erro para debug
        debugPrint('❌ Erro ao mapear contrato ${snapshot.id}: $e');
        debugPrint('📄 Dados do documento: $contractMap');
        debugPrint('📚 Stack trace: $stackTrace');
        rethrow;
      }
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar contrato no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar contrato',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ContractEntity>> getContractsByClient(String clientUid) async {
    try {
      if (clientUid.isEmpty) {
        throw const ValidationException(
          'UID do cliente não pode ser vazio',
        );
      }

      final collectionReference = ContractEntityReference.firebaseCollectionReference(
        firestore,
      );
      
      final querySnapshot = await collectionReference
          .where('refClient', isEqualTo: clientUid)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            try {
            final contractMap = doc.data() as Map<String, dynamic>;
              // Converter Timestamps para DateTime antes do mapeamento
              final convertedMap = convertFirestoreMapForMapper(contractMap);
              final contract = ContractEntityMapper.fromMap(convertedMap);
            return contract.copyWith(uid: doc.id);
            } catch (e, stackTrace) {
              // Log detalhado do erro para debug
              debugPrint('❌ Erro ao mapear contrato ${doc.id}: $e');
              debugPrint('📄 Dados do documento: ${doc.data()}');
              debugPrint('📚 Stack trace: $stackTrace');
              rethrow;
            }
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar contratos do cliente no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar contratos do cliente',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ContractEntity>> getContractsByArtist(String artistUid) async {
    try {
      if (artistUid.isEmpty) {
        throw const ValidationException(
          'UID do artista não pode ser vazio',
        );
      }

      final collectionReference = ContractEntityReference.firebaseCollectionReference(
        firestore,
      );
      
      final querySnapshot = await collectionReference
          .where('refArtist', isEqualTo: artistUid)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            try {
            final contractMap = doc.data() as Map<String, dynamic>;
              // Converter Timestamps para DateTime antes do mapeamento
              final convertedMap = convertFirestoreMapForMapper(contractMap);
              final contract = ContractEntityMapper.fromMap(convertedMap);
            return contract.copyWith(uid: doc.id);
            } catch (e, stackTrace) {
              // Log detalhado do erro para debug
              debugPrint('❌ Erro ao mapear contrato ${doc.id}: $e');
              debugPrint('📄 Dados do documento: ${doc.data()}');
              debugPrint('📚 Stack trace: $stackTrace');
              rethrow;
            }
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar contratos do artista no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar contratos do artista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ContractEntity>> getContractsByGroup(String groupUid) async {
    try {
      if (groupUid.isEmpty) {
        throw const ValidationException(
          'UID do grupo não pode ser vazio',
        );
      }

      final collectionReference = ContractEntityReference.firebaseCollectionReference(
        firestore,
      );
      
      final querySnapshot = await collectionReference
          .where('refGroup', isEqualTo: groupUid)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            try {
            final contractMap = doc.data() as Map<String, dynamic>;
              // Converter Timestamps para DateTime antes do mapeamento
              final convertedMap = convertFirestoreMapForMapper(contractMap);
              final contract = ContractEntityMapper.fromMap(convertedMap);
            return contract.copyWith(uid: doc.id);
            } catch (e, stackTrace) {
              // Log detalhado do erro para debug
              debugPrint('❌ Erro ao mapear contrato ${doc.id}: $e');
              debugPrint('📄 Dados do documento: ${doc.data()}');
              debugPrint('📚 Stack trace: $stackTrace');
              rethrow;
            }
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar contratos do grupo no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar contratos do grupo',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String> addContract(ContractEntity contract) async {
    try {
      final collectionReference = ContractEntityReference.firebaseCollectionReference(
        firestore,
      );

      // Criar novo documento na coleção
      final newDocRef = collectionReference.doc();
      final contractMap = contract.toMap();
      
      await newDocRef.set(contractMap);

      return newDocRef.id;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao adicionar contrato no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao adicionar contrato',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateContract(ContractEntity contract) async {
    try {
      final contractUid = contract.uid;

      if (contractUid == null || contractUid.isEmpty) {
        throw const ValidationException(
          'UID do contrato não pode ser vazio',
        );
      }

      final documentReference = ContractEntityReference.firebaseUidReference(
        firestore,
        contractUid,
      );

      // Verificar se documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException('Contrato não encontrado: $contractUid');
      }

      // Atualizar documento
      final contractMap = contract.toMap();
      await documentReference.set(contractMap, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar contrato no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao atualizar contrato',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteContract(String contractUid) async {
    try {
      if (contractUid.isEmpty) {
        throw const ValidationException(
          'UID do contrato não pode ser vazio',
        );
      }

      final documentReference = ContractEntityReference.firebaseUidReference(
        firestore,
        contractUid,
      );

      // Verificar se documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException('Contrato não encontrado: $contractUid');
      }

      // Deletar documento
      await documentReference.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao deletar contrato no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao deletar contrato',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String?> getKeyCode(String contractUid) async {
    try {
      if (contractUid.isEmpty) {
        throw const ValidationException(
          'UID do contrato não pode ser vazio',
        );
      }

      final documentReference = ConfirmationEntityReference.firebaseReference(
        firestore,
        contractUid,
      );

      final snapshot = await documentReference.get();
      
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data() as Map<String, dynamic>?;
      return data?['keyCode'] as String?;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar código de confirmação no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar código de confirmação',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setKeyCode(String contractUid, String keyCode) async {
    try {
      if (contractUid.isEmpty) {
        throw const ValidationException(
          'UID do contrato não pode ser vazio',
        );
      }

      if (keyCode.isEmpty) {
        throw const ValidationException(
          'Código de confirmação não pode ser vazio',
        );
      }

      final documentReference = ConfirmationEntityReference.firebaseReference(
        firestore,
        contractUid,
      );

      final confirmationEntity = ConfirmationEntity(
        keyCode: keyCode,
        createdAt: DateTime.now(),
      );

      final data = confirmationEntity.toMap();
      
      await documentReference.set(data, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao salvar código de confirmação no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao salvar código de confirmação',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== CONTRACTS INDEX OPERATIONS ====================

  @override
  Stream<UserContractsIndexEntity> getContractsIndexStream(String userId) {
    try {
      return UserContractsIndexEntityReference.firebaseStreamReference(firestore, userId)
          .map((doc) {
        if (!doc.exists) {
          // Retornar entidade padrão se documento não existe
          return UserContractsIndexEntity();
        }
        
        final data = doc.data()!;
        
        // Converter Timestamps para DateTime antes do mapeamento
        // O TimestampHook não está funcionando corretamente, então fazemos manualmente
        final convertedData = _convertIndexTimestampsToDateTime(data);
        
        // Tentar mapear mesmo se alguns campos estiverem faltando
        // O mapper vai usar valores padrão (0) para campos ausentes
        try {
          final entity = UserContractsIndexEntityMapper.fromMap(convertedData);
          return entity;
        } catch (e) {
          // Se falhar o mapeamento, retornar entidade padrão
          return UserContractsIndexEntity();
        }
      });
    } catch (e) {
      throw ServerException('Erro ao criar stream do índice de contratos: $e');
    }
  }

  @override
  Future<void> markTabAsSeen(String userId, int tabIndex, {bool isArtist = false}) async {
    try {
      if (tabIndex < 0 || tabIndex > 2) {
        throw const ValidationException('Índice de tab inválido. Deve ser 0, 1 ou 2');
      }

      final now = Timestamp.now();
      final rolePrefix = isArtist ? 'artist' : 'client';
      final fieldName = 'lastSeen${rolePrefix[0].toUpperCase()}${rolePrefix.substring(1)}Tab$tabIndex';
      final unseenFieldName = '${rolePrefix}Tab${tabIndex}Unseen';

      // Marcar como visto: atualizar timestamp E zerar contador de não vistos
      // Quando o usuário vê a tab, todos os contratos que estavam lá são considerados "vistos"
      await UserContractsIndexEntityReference.firebaseReference(firestore, userId)
          .set({
        fieldName: now,
        unseenFieldName: 0, // Zerar contador de não vistos
        'lastUpdate': now,
      }, SetOptions(merge: true));
      
      debugPrint('✅ [ContractsIndex] Tab $tabIndex marcada como vista (Role: $rolePrefix) - Unseen zerado');
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao marcar tab como vista no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao marcar tab como vista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateContractsIndex(String userId, Map<String, dynamic> updates) async {
    try {
      if (userId.isEmpty) {
        throw const ValidationException('UID do usuário não pode ser vazio');
      }

      // Converter DateTime para Timestamp se necessário
      final convertedUpdates = <String, dynamic>{};
      for (final entry in updates.entries) {
        if (entry.value is DateTime) {
          convertedUpdates[entry.key] = Timestamp.fromDate(entry.value as DateTime);
        } else {
          convertedUpdates[entry.key] = entry.value;
        }
      }

      // Adicionar timestamp de atualização
      convertedUpdates['lastUpdate'] = Timestamp.now();

      await UserContractsIndexEntityReference.firebaseReference(firestore, userId)
          .set(convertedUpdates, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar índice de contratos no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao atualizar índice de contratos',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== AVAILABILITY FUNCTIONS ====================

  @override
  Future<Map<String, dynamic>> verifyContractAvailability({
    required String contractId,
    required String artistId,
    required String date,
    required String time,
    required int duration,
    required Map<String, dynamic> address,
    required double value,
    Map<String, dynamic>? availabilitySnapshot,
  }) async {
    try {
      final data = <String, dynamic>{
        'contractId': contractId,
        'artistId': artistId,
        'date': date,
        'time': time,
        'duration': duration,
        'address': address,
        'value': value,
      };

      if (availabilitySnapshot != null) {
        data['availabilitySnapshot'] = availabilitySnapshot;
      }

      final result = await firebaseFunctionsService.callFunction(
        'verifyContractAvailability',
        data,
      );

      return result;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro ao verificar disponibilidade do contrato: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> releaseAvailabilitySlotAfterCancel({
    required String contractId,
    required String artistId,
    required String date,
  }) async {
    try {
      final result = await firebaseFunctionsService.callFunction(
        'releaseAvailabilitySlotAfterCancel',
        {
          'contractId': contractId,
          'artistId': artistId,
          'date': date,
        },
      );

      return result;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro ao liberar slot de disponibilidade: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> checkContractOverlapWithBooked(String contractId) async {
    try {
      if (contractId.isEmpty) {
        throw const ValidationException('contractId não pode ser vazio');
      }
      final result = await firebaseFunctionsService.callFunction(
        'checkContractOverlapWithBooked',
        {'contractId': contractId},
      );
      final hasOverlap = result['hasOverlap'] == true;
      return hasOverlap;
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      if (e is ValidationException) rethrow;
      throw ServerException(
        'Erro ao verificar overlap com slots reservados: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

