import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/members/data/datasources/members_local_datasource.dart';
import 'package:app/features/ensemble/members/data/datasources/members_remote_datasource.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do repositório de Members.
///
/// Orquestra remote e local. Estratégia: cache-first em get; create/update/delete
/// atualizam remote e em seguida o cache.
class MembersRepositoryImpl implements IMembersRepository {
  final IMembersRemoteDataSource remoteDataSource;
  final IMembersLocalDataSource localDataSource;

  MembersRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<EnsembleMemberEntity>>> getAll({
    required String artistId,
    bool forceRemote = false,
  }) async {
    try {
      if (!forceRemote) {
        final cached = await localDataSource.getAll(artistId);
        if (cached.isNotEmpty) return Right(cached);
      }
      final list = await remoteDataSource.getAll(artistId);
      await localDataSource.clearCache(artistId);
      for (final m in list) {
        await localDataSource.cacheMember(artistId, m);
      }
      return Right(list);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, EnsembleMemberEntity?>> getById({
    required String artistId,
    required String memberId,
    bool forceRemote = false,
  }) async {
    try {
      if (!forceRemote) {
        final cached = await localDataSource.getById(
          artistId,
          memberId,
        );
        if (cached != null) return Right(cached);
      }
      final entity = await remoteDataSource.getById(
        artistId,
        memberId,
      );
      if (entity != null) {
        await localDataSource.cacheMember(artistId, entity);
      }
      return Right(entity);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, EnsembleMemberEntity>> create({
    required String artistId,
    required EnsembleMemberEntity member,
  }) async {
    try {
      final created = await remoteDataSource.create(
        artistId,
        member,
      );
      await localDataSource.cacheMember(artistId, created);
      return Right(created);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> update({
    required String artistId,
    required EnsembleMemberEntity member,
  }) async {
    try {
      await remoteDataSource.update(artistId, member);
      await localDataSource.cacheMember(artistId, member);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> delete({
    required String artistId,
    required String memberId,
  }) async {
    try {
      await remoteDataSource.delete(artistId, memberId);
      await localDataSource.removeMember(artistId, memberId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache({
    required String artistId,
  }) async {
    try {
      await localDataSource.clearCache(artistId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
