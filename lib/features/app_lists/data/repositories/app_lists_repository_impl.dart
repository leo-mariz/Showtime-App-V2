import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/app_lists/data/datasources/app_lists_local_datasource.dart';
import 'package:app/features/app_lists/data/datasources/app_lists_remote_datasource.dart';
import 'package:app/features/app_lists/domain/entities/app_list_item_entity.dart';
import 'package:app/features/app_lists/domain/repositories/app_lists_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de AppLists
/// 
/// REGRA: Este repository combina lógica de cache e remoto
/// - Primeiro busca do cache
/// - Se não encontrado, busca do remoto
/// - Em seguida salva no cache
class AppListsRepositoryImpl implements IAppListsRepository {
  final IAppListsRemoteDataSource remoteDataSource;
  final IAppListsLocalDataSource localDataSource;

  AppListsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AppListItemEntity>>> getListItems(
    AppListType listType,
  ) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedItems = await localDataSource.getCachedListItems(listType);
        if (cachedItems.isNotEmpty) {
          return Right(cachedItems);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final items = await remoteDataSource.getListItems(listType);

      // Salva no cache após buscar do remoto
      if (items.isNotEmpty) {
        await localDataSource.cacheListItems(listType, items);
      }

      return Right(items);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

