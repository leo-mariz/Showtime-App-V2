import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/entities/user_contracts_index_entity.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Contracts
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados (primeiro do cache, depois do remoto)
/// - Create: Adicionar novo contrato
/// - Update: Atualizar contrato existente
/// - Delete: Remover contrato
abstract class IContractRepository {
  // ==================== GET OPERATIONS ====================
  
  /// Busca um contrato específico por UID
  Future<Either<Failure, ContractEntity>> getContract(String contractUid, {bool forceRefresh = false});
  
  /// Busca lista de contratos por cliente
  Future<Either<Failure, List<ContractEntity>>> getContractsByClient(String clientUid, {bool forceRefresh = false});
  
  /// Busca lista de contratos por artista
  Future<Either<Failure, List<ContractEntity>>> getContractsByArtist(String artistUid, {bool forceRefresh = false});
  
  /// Busca lista de contratos por grupo
  Future<Either<Failure, List<ContractEntity>>> getContractsByGroup(String groupUid, {bool forceRefresh = false});

  // ==================== CREATE OPERATIONS ====================
  
  /// Adiciona um novo contrato
  /// Retorna o UID do contrato criado
  Future<Either<Failure, String>> addContract(ContractEntity contract);

  // ==================== UPDATE OPERATIONS ====================
  
  /// Atualiza um contrato existente
  Future<Either<Failure, void>> updateContract(ContractEntity contract);

  // ==================== DELETE OPERATIONS ====================
  
  /// Remove um contrato
  Future<Either<Failure, void>> deleteContract(String contractUid);

  // ==================== KEY CODE OPERATIONS ====================
  
  /// Busca o código de confirmação (keyCode) de um contrato
  Future<Either<Failure, String?>> getKeyCode(String contractUid, {bool forceRefresh = false});
  
  /// Salva/atualiza o código de confirmação (keyCode) de um contrato
  Future<Either<Failure, void>> setKeyCode(String contractUid, String keyCode);

  // ==================== CONTRACTS INDEX OPERATIONS ====================

  /// Stream do índice de contratos do usuário
  /// 
  /// Escuta o documento user_contracts_index/{userId} que contém:
  /// - Contadores totais por tab
  /// - Contadores de não vistos por tab
  /// - Timestamps de última visualização
  Stream<UserContractsIndexEntity> getContractsIndexStream(String userId);

  /// Marca uma tab como vista
  /// 
  /// Atualiza o timestamp lastSeenTab{index} no índice
  /// [isArtist] - Define qual role usar (artista ou cliente) para marcar como visto
  Future<Either<Failure, void>> markTabAsSeen(String userId, int tabIndex, {bool isArtist = false});

  /// Atualiza o índice de contratos com os valores fornecidos
  /// 
  /// [updates] - Map com os campos a serem atualizados (ex: {'tab0Total': 5, 'tab0Unseen': 2})
  Future<Either<Failure, void>> updateContractsIndex(String userId, Map<String, dynamic> updates);

  // ==================== AVAILABILITY FUNCTIONS ====================

  /// Verifica se a disponibilidade do artista ainda é válida para o contrato
  /// 
  /// Retorna Map com resultado da verificação:
  /// - isValid: bool
  /// - reason?: string (se inválido)
  /// - availableSlots?: Array (se válido)
  /// - distance?: number
  /// - withinRadius?: bool
  Future<Either<Failure, Map<String, dynamic>>> verifyContractAvailability({
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
  /// Retorna Map com resultado:
  /// - success: bool
  /// - releasedSlot?: {startTime, endTime, valorHora}
  /// - error?: string
  Future<Either<Failure, Map<String, dynamic>>> releaseAvailabilitySlotAfterCancel({
    required String contractId,
    required String artistId,
    required String date, // YYYY-MM-DD
  });
}

