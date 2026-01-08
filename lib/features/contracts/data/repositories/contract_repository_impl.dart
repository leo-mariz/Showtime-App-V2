import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/data/datasources/contract_local_datasource.dart';
import 'package:app/features/contracts/data/datasources/contract_remote_datasource.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Contracts
/// 
/// REGRA: Este repository combina lógica de cache e remoto
/// - Primeiro busca do cache
/// - Se não encontrado, busca do remoto
/// - Em seguida salva no remoto e no cache
class ContractRepositoryImpl implements IContractRepository {
  final IContractRemoteDataSource remoteDataSource;
  final IContractLocalDataSource localDataSource;

  ContractRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, ContractEntity>> getContract(String contractUid) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedContract = await localDataSource.getCachedContract(contractUid);
        if (cachedContract != null) {
          return Right(cachedContract);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final contract = await remoteDataSource.getContract(contractUid);
      
      // Salva no cache após buscar do remoto
      await localDataSource.cacheContract(contract);
      
      return Right(contract);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<ContractEntity>>> getContractsByClient(String clientUid) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedContracts = await localDataSource.getCachedContractsByClient(clientUid);
        if (cachedContracts.isNotEmpty) {
          return Right(cachedContracts);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final contracts = await remoteDataSource.getContractsByClient(clientUid);
      
      // Salva no cache após buscar do remoto
      if (contracts.isNotEmpty) {
        await localDataSource.cacheContractsByClient(clientUid, contracts);
      }
      
      return Right(contracts);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<ContractEntity>>> getContractsByArtist(String artistUid) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedContracts = await localDataSource.getCachedContractsByArtist(artistUid);
        if (cachedContracts.isNotEmpty) {
          return Right(cachedContracts);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final contracts = await remoteDataSource.getContractsByArtist(artistUid);
      
      // Salva no cache após buscar do remoto
      if (contracts.isNotEmpty) {
        await localDataSource.cacheContractsByArtist(artistUid, contracts);
      }
      
      return Right(contracts);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<ContractEntity>>> getContractsByGroup(String groupUid) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedContracts = await localDataSource.getCachedContractsByGroup(groupUid);
        if (cachedContracts.isNotEmpty) {
          return Right(cachedContracts);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final contracts = await remoteDataSource.getContractsByGroup(groupUid);
      
      // Salva no cache após buscar do remoto
      if (contracts.isNotEmpty) {
        await localDataSource.cacheContractsByGroup(groupUid, contracts);
      }
      
      return Right(contracts);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== CREATE OPERATIONS ====================

  @override
  Future<Either<Failure, String>> addContract(ContractEntity contract) async {
    try {
      // Adiciona no remoto e obtém o UID criado
      final contractUid = await remoteDataSource.addContract(contract);
      
      // Busca contrato atualizado do remoto
      final updatedContract = await remoteDataSource.getContract(contractUid);
      
      // Atualiza cache com contrato atualizado
      await localDataSource.cacheContract(updatedContract);
      
      // Atualiza cache de listas se necessário
      if (updatedContract.refClient != null) {
        final clientContracts = await remoteDataSource.getContractsByClient(updatedContract.refClient!);
        await localDataSource.cacheContractsByClient(updatedContract.refClient!, clientContracts);
      }
      
      if (updatedContract.refArtist != null) {
        final artistContracts = await remoteDataSource.getContractsByArtist(updatedContract.refArtist!);
        await localDataSource.cacheContractsByArtist(updatedContract.refArtist!, artistContracts);
      }
      
      if (updatedContract.refGroup != null) {
        final groupContracts = await remoteDataSource.getContractsByGroup(updatedContract.refGroup!);
        await localDataSource.cacheContractsByGroup(updatedContract.refGroup!, groupContracts);
      }
      
      return Right(contractUid);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== UPDATE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> updateContract(ContractEntity contract) async {
    try {
      // Atualiza no remoto
      await remoteDataSource.updateContract(contract);
      
      // Atualiza cache com contrato atualizado
      await localDataSource.cacheContract(contract);
      
      // Atualiza cache de listas se necessário
      if (contract.refClient != null) {
        final clientContracts = await remoteDataSource.getContractsByClient(contract.refClient!);
        await localDataSource.cacheContractsByClient(contract.refClient!, clientContracts);
      }
      
      if (contract.refArtist != null) {
        final artistContracts = await remoteDataSource.getContractsByArtist(contract.refArtist!);
        await localDataSource.cacheContractsByArtist(contract.refArtist!, artistContracts);
      }
      
      if (contract.refGroup != null) {
        final groupContracts = await remoteDataSource.getContractsByGroup(contract.refGroup!);
        await localDataSource.cacheContractsByGroup(contract.refGroup!, groupContracts);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== DELETE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> deleteContract(String contractUid) async {
    try {
      // Buscar contrato antes de deletar para atualizar caches
      final contract = await remoteDataSource.getContract(contractUid);
      
      // Remove do remoto
      await remoteDataSource.deleteContract(contractUid);
      
      // Atualiza cache de listas removendo o contrato deletado
      if (contract.refClient != null) {
        final clientContracts = await remoteDataSource.getContractsByClient(contract.refClient!);
        await localDataSource.cacheContractsByClient(contract.refClient!, clientContracts);
      }
      
      if (contract.refArtist != null) {
        final artistContracts = await remoteDataSource.getContractsByArtist(contract.refArtist!);
        await localDataSource.cacheContractsByArtist(contract.refArtist!, artistContracts);
      }
      
      if (contract.refGroup != null) {
        final groupContracts = await remoteDataSource.getContractsByGroup(contract.refGroup!);
        await localDataSource.cacheContractsByGroup(contract.refGroup!, groupContracts);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

