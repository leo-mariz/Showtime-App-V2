import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/app_content/data/datasources/app_content_local_datasource.dart';
import 'package:app/features/app_content/data/datasources/app_content_remote_datasource.dart';
import 'package:app/features/app_content/domain/entities/app_content_entity.dart';
import 'package:app/features/app_content/domain/repositories/app_content_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do repositório: cache primeiro, depois remoto, depois persiste no cache.
class AppContentRepositoryImpl implements IAppContentRepository {
  final IAppContentRemoteDataSource remoteDataSource;
  final IAppContentLocalDataSource localDataSource;

  AppContentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AppContentEntity>> getContent(
    AppContentType type,
  ) async {
    try {
      try {
        final cached = await localDataSource.getCachedContent(type);
        if (cached != null && cached.content.isNotEmpty) {
          return Right(cached);
        }
      } catch (_) {}

      final entity = await remoteDataSource.getContent(type);
      if (entity.content.isNotEmpty) {
        await localDataSource.cacheContent(type, entity);
      }
      return Right(entity);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
