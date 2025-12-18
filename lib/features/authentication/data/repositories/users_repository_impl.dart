import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/domain/user/cnpj/cnpj_user_entity.dart';
import 'package:app/core/domain/user/cpf/cpf_user_entity.dart';
import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/data/datasources/users_local_datasource.dart';
import 'package:app/features/authentication/data/datasources/users_remote_datasource.dart';
import 'package:app/features/authentication/domain/repositories/users_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Autenticação
/// 
/// RESPONSABILIDADES:
/// - Coordenar chamadas entre DataSources (Local e Remote)
/// - Converter exceções em Failures usando ErrorHandler
/// - NÃO faz validações de negócio (isso é responsabilidade dos UseCases)
/// 
/// REGRA: Este repository é SIMPLES e GENÉRICO
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
      required this.localDataSource,
    });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, String?>> getUserUid() async {
    try {
      final uid = await localDataSource.getUserUid();
      return Right(uid);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }  

  @override
  Future<Either<Failure, UserEntity>> getUserData(String uid) async {
    try {
      final user = await remoteDataSource.getFirestoreUserData(uid);
      await localDataSource.cacheUserInfo(user);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, ArtistEntity>> getArtistData(String uid) async {
    try {
      final artist = await remoteDataSource.getFirestoreArtistData(uid);
      if (artist != ArtistEntity()) {
          await localDataSource.cacheArtistInfo(artist);
      }
      return Right(artist);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
      }
  }
  
  @override
  Future<Either<Failure, ClientEntity>> getClientData(String uid) async {
    try {
      final client = await remoteDataSource.getFirestoreClientData(uid);
      if (client != ClientEntity()) {
        await localDataSource.cacheClientInfo(client);
      }
      return Right(client);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
      }
  }

  // ==================== SET OPERATIONS ====================

  @override
  Future<Either<Failure, void>> setUserData(UserEntity user) async {
    try {
      await remoteDataSource.setFirestoreUserData(user);
      await localDataSource.cacheUserInfo(user);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  } 
  
  @override
  Future<Either<Failure, void>> setCpfUserInfo(
    String uid,
    CpfUserEntity cpfUser,
  ) async {
    try {
      await remoteDataSource.setFirestoreCpfUserInfo(uid, cpfUser);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> setCnpjUserInfo(
    String uid,
    CnpjUserEntity cnpjUser,
  ) async {
    try {
      await remoteDataSource.setFirestoreCnpjUserInfo(uid, cnpjUser);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> setArtistData(
    String uid,
    ArtistEntity artist,
  ) async {
    try {
      await remoteDataSource.setFirestoreArtistData(uid, artist);
      await localDataSource.cacheArtistInfo(artist);
      return const Right(null);
      } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> setClientData(
    String uid,
    ClientEntity client,
  ) async {
    try {
      await remoteDataSource.setFirestoreClientData(uid, client);
      await localDataSource.cacheClientInfo(client);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
      }
  }

  // ==================== VERIFICATION OPERATIONS ====================

  @override
  Future<Either<Failure, bool>> cpfExists(String cpf) async {
    try {
      final exists = await remoteDataSource.cpfExists(cpf);
      return Right(exists);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> cnpjExists(String cnpj) async {
    try {
      final exists = await remoteDataSource.cnpjExists(cnpj);
      return Right(exists);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> emailExists(String email) async {
    try {
      final exists = await remoteDataSource.emailExists(email);
      return Right(exists);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== CACHE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
