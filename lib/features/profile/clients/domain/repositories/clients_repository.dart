import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Clients
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados (primeiro do cache, depois do remoto)
/// - Create: Adicionar novo cliente
/// - Update: Atualizar cliente existente
/// - Delete: Remover cliente
abstract class IClientsRepository {
  // ==================== GET OPERATIONS ====================
  
  /// Busca dados do cliente por UID
  /// Primeiro tenta buscar do cache, depois do remoto
  Future<Either<Failure, ClientEntity>> getClient(String uid);

  // ==================== CREATE OPERATIONS ====================
  
  /// Adiciona um novo cliente
  Future<Either<Failure, void>> addClient(String uid, ClientEntity client);

  // ==================== UPDATE OPERATIONS ====================
  
  /// Atualiza um cliente existente
  Future<Either<Failure, void>> updateClient(String uid, ClientEntity client);

  // ==================== DELETE OPERATIONS ====================
  
  /// Remove um cliente
  Future<Either<Failure, void>> deleteClient(String uid);
}

