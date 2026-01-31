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
  Future<Either<Failure, List<EnsembleMemberEntity>>> getAllByEnsemble({
    required String artistId,
    required String ensembleId,
    bool forceRemote = false,
  }) async {
    try {
      if (!forceRemote) {
        final cached = await localDataSource.getAllByEnsemble(
          artistId,
          ensembleId,
        );
        if (cached.isNotEmpty) return Right(cached);
      }
      final list = await remoteDataSource.getAllByEnsemble(
        artistId,
        ensembleId,
      );
      for (final m in list) {
        await localDataSource.cacheMember(artistId, ensembleId, m);
      }
      return Right(list);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, EnsembleMemberEntity?>> getById({
    required String artistId,
    required String ensembleId,
    required String memberId,
  }) async {
    try {
      final cached = await localDataSource.getById(
        artistId,
        ensembleId,
        memberId,
      );
      if (cached != null) return Right(cached);
      final entity = await remoteDataSource.getById(
        artistId,
        ensembleId,
        memberId,
      );
      if (entity != null) {
        await localDataSource.cacheMember(artistId, ensembleId, entity);
      }
      return Right(entity);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, EnsembleMemberEntity>> create({
    required String artistId,
    required String ensembleId,
    required EnsembleMemberEntity member,
  }) async {
    try {
      final created = await remoteDataSource.create(
        artistId,
        ensembleId,
        member,
      );
      await localDataSource.cacheMember(artistId, ensembleId, created);
      return Right(created);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> update({
    required String artistId,
    required String ensembleId,
    required EnsembleMemberEntity member,
  }) async {
    try {
      await remoteDataSource.update(artistId, ensembleId, member);
      await localDataSource.cacheMember(artistId, ensembleId, member);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> delete({
    required String artistId,
    required String ensembleId,
    required String memberId,
  }) async {
    try {
      await remoteDataSource.delete(artistId, ensembleId, memberId);
      await localDataSource.removeMember(artistId, ensembleId, memberId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache({
    required String artistId,
    required String ensembleId,
  }) async {
    try {
      await localDataSource.clearCache(artistId, ensembleId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
