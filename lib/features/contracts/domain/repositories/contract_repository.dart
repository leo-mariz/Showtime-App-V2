import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/failure.dart';
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
  Future<Either<Failure, ContractEntity>> getContract(String contractUid);
  
  /// Busca lista de contratos por cliente
  Future<Either<Failure, List<ContractEntity>>> getContractsByClient(String clientUid);
  
  /// Busca lista de contratos por artista
  Future<Either<Failure, List<ContractEntity>>> getContractsByArtist(String artistUid);
  
  /// Busca lista de contratos por grupo
  Future<Either<Failure, List<ContractEntity>>> getContractsByGroup(String groupUid);

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
}

