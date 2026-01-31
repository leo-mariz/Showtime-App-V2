import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/member_documents/data/datasources/member_documents_local_datasource.dart';
import 'package:app/features/ensemble/member_documents/data/datasources/member_documents_remote_datasource.dart';
import 'package:app/features/ensemble/member_documents/domain/repositories/member_documents_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do repositório de MemberDocuments.
///
/// Orquestra remote e local. Estratégia: cache-first em get; save/delete
/// atualizam remote e em seguida o cache.
class MemberDocumentsRepositoryImpl implements IMemberDocumentsRepository {
  final IMemberDocumentsRemoteDataSource remoteDataSource;
  final IMemberDocumentsLocalDataSource localDataSource;

  MemberDocumentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<MemberDocumentEntity>>> getAllByMember({
    required String artistId,
    required String ensembleId,
    required String memberId,
    bool forceRemote = false,
  }) async {
    try {
      if (!forceRemote) {
        final cached = await localDataSource.getAllByMember(
          artistId,
          ensembleId,
          memberId,
        );
        if (cached.isNotEmpty) return Right(cached);
      }
      final list = await remoteDataSource.getAllByMember(
        artistId,
        ensembleId,
        memberId,
      );
      for (final doc in list) {
        await localDataSource.cacheDocument(artistId, doc);
      }
      return Right(list);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, MemberDocumentEntity?>> get({
    required String artistId,
    required String ensembleId,
    required String memberId,
    required String documentType,
  }) async {
    try {
      final cached = await localDataSource.get(
        artistId,
        ensembleId,
        memberId,
        documentType,
      );
      if (cached != null) return Right(cached);
      final entity = await remoteDataSource.get(
        artistId,
        ensembleId,
        memberId,
        documentType,
      );
      if (entity != null) {
        await localDataSource.cacheDocument(artistId, entity);
      }
      return Right(entity);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> save({
    required String artistId,
    required MemberDocumentEntity document,
  }) async {
    try {
      await remoteDataSource.save(artistId, document);
      await localDataSource.cacheDocument(artistId, document);
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
    required String documentType,
  }) async {
    try {
      await remoteDataSource.delete(
        artistId,
        ensembleId,
        memberId,
        documentType,
      );
      await localDataSource.removeDocument(
        artistId,
        ensembleId,
        memberId,
        documentType,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache({
    required String artistId,
    required String ensembleId,
    required String memberId,
  }) async {
    try {
      await localDataSource.clearCache(artistId, ensembleId, memberId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
