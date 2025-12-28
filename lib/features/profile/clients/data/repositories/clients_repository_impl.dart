import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/clients/data/datasources/clients_local_datasource.dart';
import 'package:app/features/profile/clients/data/datasources/clients_remote_datasource.dart';
import 'package:app/features/profile/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Clients
/// 
/// REGRA: Este repository combina lógica de cache e remoto
/// - Primeiro busca do cache
/// - Se não encontrado, busca do remoto
/// - Em seguida salva no remoto e no cache
class ClientsRepositoryImpl implements IClientsRepository {
  final IClientsRemoteDataSource remoteDataSource;
  final IClientsLocalDataSource localDataSource;

  ClientsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, ClientEntity>> getClient(String uid) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedClient = await localDataSource.getCachedClient();
        
        if (cachedClient != null && cachedClient.uid == uid) {
          return Right(cachedClient);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final client = await remoteDataSource.getClient(uid);
      
      // Salva no cache após buscar do remoto
      await localDataSource.cacheClient(client);
      
      return Right(client);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== CREATE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> addClient(String uid, ClientEntity client) async {
    try {
      // Adiciona no remoto
      await remoteDataSource.addClient(uid, client);
      
      // Atualiza cache com o cliente adicionado
      final clientWithUid = client.copyWith(uid: uid);
      await localDataSource.cacheClient(clientWithUid);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== UPDATE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> updateClient(String uid, ClientEntity client) async {
    try {
      // Atualiza no remoto
      await remoteDataSource.updateClient(uid, client);
      
      // Atualiza cache com o cliente atualizado
      final clientWithUid = client.copyWith(uid: uid);
      await localDataSource.cacheClient(clientWithUid);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== DELETE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> deleteClient(String uid) async {
    try {
      // Remove do remoto
      await remoteDataSource.deleteClient(uid);
      
      // Limpa cache
      await localDataSource.clearClientCache();
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

