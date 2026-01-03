import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:app/features/authentication/domain/repositories/auth_repository.dart';
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
  final IAuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
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

  @override
  Future<Either<Failure, void>> printCache(String key) async {
    try {
      await localDataSource.printCache(key);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
