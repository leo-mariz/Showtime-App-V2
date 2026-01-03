import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artists/groups/data/datasources/groups_local_datasource.dart';
import 'package:app/features/profile/artists/groups/data/datasources/groups_remote_datasource.dart';
import 'package:app/features/profile/artists/groups/domain/repositories/groups_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Groups
/// 
/// RESPONSABILIDADES:
/// - Coordenar chamadas entre DataSources (Local e Remote)
/// - Converter exceções em Failures usando ErrorHandler
/// - NÃO faz validações de negócio (isso é responsabilidade dos UseCases)
/// 
/// REGRA: Este repository é SIMPLES e GENÉRICO
class GroupsRepositoryImpl implements IGroupsRepository {
  final IGroupsRemoteDataSource remoteDataSource;
  final IGroupsLocalDataSource localDataSource;

  GroupsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, GroupEntity>> getGroup(String uid) async {
    try {
      final group = await remoteDataSource.getGroup(uid);
      if (group.uid != null && group.uid!.isNotEmpty) {
        await localDataSource.cacheGroup(group);
      }
      return Right(group);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> getGroups() async {
    try {
      final groups = await remoteDataSource.getGroups();
      if (groups.isNotEmpty) {
        await localDataSource.cacheGroupsList(groups);
      }
      return Right(groups);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== ADD OPERATIONS ====================

  @override
  Future<Either<Failure, void>> addGroup(
    String uid,
    GroupEntity group,
  ) async {
    try {
      await remoteDataSource.addGroup(uid, group);
      final groupWithUid = group.copyWith(uid: uid);
      await localDataSource.cacheGroup(groupWithUid);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== UPDATE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> updateGroup(
    String uid,
    GroupEntity group,
  ) async {
    try {
      // Atualiza no remoto
      await remoteDataSource.updateGroup(uid, group);
      
      // Atualiza cache com o grupo atualizado
      final groupWithUid = group.copyWith(uid: uid);
      await localDataSource.cacheGroup(groupWithUid);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== DELETE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> deleteGroup(String uid) async {
    try {
      await remoteDataSource.deleteGroup(uid);
      await localDataSource.clearGroupCache(uid);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== VERIFICATION OPERATIONS ====================

  @override
  Future<Either<Failure, bool>> groupNameExists(String groupName) async {
    try {
      final exists = await remoteDataSource.groupNameExists(groupName);
      return Right(exists);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

