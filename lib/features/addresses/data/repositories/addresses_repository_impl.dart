import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/addresses/data/datasources/addresses_local_datasource.dart';
import 'package:app/features/addresses/data/datasources/addresses_remote_datasource.dart';
import 'package:app/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Addresses
/// 
/// REGRA: Este repository combina lógica de cache e remoto
/// - Primeiro busca do cache
/// - Se não encontrado, busca do remoto
/// - Em seguida salva no remoto e no cache
class AddressesRepositoryImpl implements IAddressesRepository {
  final IAddressesRemoteDataSource remoteDataSource;
  final IAddressesLocalDataSource localDataSource;

  AddressesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, List<AddressInfoEntity>>> getAddresses(String uid) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedAddresses = await localDataSource.getCachedAddresses();
        if (cachedAddresses.isNotEmpty) {
          return Right(cachedAddresses);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final addresses = await remoteDataSource.getAddresses(uid);
      
      // Salva no cache após buscar do remoto
      if (addresses.isNotEmpty) {
        await localDataSource.cacheAddresses(addresses);
      }
      
      return Right(addresses);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== CREATE OPERATIONS ====================

  @override
  Future<Either<Failure, String>> addAddress(
    String uid,
    AddressInfoEntity address,
  ) async {
    try {
      // Adiciona no remoto e obtém o ID criado
      final addressId = await remoteDataSource.addAddress(uid, address);
      
      // Busca lista atualizada do remoto
      final updatedAddresses = await remoteDataSource.getAddresses(uid);
      
      // Atualiza cache com lista atualizada
      await localDataSource.cacheAddresses(updatedAddresses);
      
      return Right(addressId);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== UPDATE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> updateAddress(
    String uid,
    String addressId,
    AddressInfoEntity address,
  ) async {
    try {
      // Atualiza no remoto
      await remoteDataSource.updateAddress(uid, addressId, address);
      
      // Busca lista atualizada do remoto
      final updatedAddresses = await remoteDataSource.getAddresses(uid);
      
      // Atualiza cache com lista atualizada
      await localDataSource.cacheAddresses(updatedAddresses);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== DELETE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> deleteAddress(String uid, String addressId) async {
    try {
      // Remove do remoto
      await remoteDataSource.deleteAddress(uid, addressId);
      
      // Busca lista atualizada do remoto
      final updatedAddresses = await remoteDataSource.getAddresses(uid);
      
      // Atualiza cache com lista atualizada
      await localDataSource.cacheAddresses(updatedAddresses);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== SET PRIMARY OPERATIONS ====================

  @override
  Future<Either<Failure, void>> setPrimaryAddress(String uid, String addressId) async {
    try {
      // Define primário no remoto
      await remoteDataSource.setPrimaryAddress(uid, addressId);
      
      // Busca lista atualizada do remoto
      final updatedAddresses = await remoteDataSource.getAddresses(uid);
      
      // Atualiza cache com lista atualizada
      await localDataSource.cacheAddresses(updatedAddresses);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

