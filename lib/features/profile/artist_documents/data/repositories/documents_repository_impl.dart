import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_documents/data/datasources/documents_local_datasource.dart';
import 'package:app/features/profile/artist_documents/data/datasources/documents_remote_datasource.dart';
import 'package:app/features/profile/artist_documents/domain/repositories/documents_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Documents
/// 
/// REGRA: Este repository combina lógica de cache e remoto
/// - Primeiro busca do cache
/// - Se não encontrado, busca do remoto
/// - Em seguida salva no remoto e no cache
class DocumentsRepositoryImpl implements IDocumentsRepository {
  final IDocumentsRemoteDataSource remoteDataSource;
  final IDocumentsLocalDataSource localDataSource;

  DocumentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, List<DocumentsEntity>>> getDocuments(
    String artistId,
  ) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedDocuments = await localDataSource.getCachedDocuments(artistId);
        if (cachedDocuments.isNotEmpty) {
          return Right(cachedDocuments);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final documents = await remoteDataSource.getDocuments(artistId);
      // Salva no cache após buscar do remoto
      if (documents.isNotEmpty) {
        await localDataSource.cacheDocuments(artistId, documents);
      }
      
      return Right(documents);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, DocumentsEntity?>> getDocument(
    String artistId,
    String documentType,
  ) async {
    try {
      // Busca diretamente do remoto para garantir que temos o documento mais atualizado
      final document = await remoteDataSource.getDocument(artistId, documentType);
      
      // Se encontrou, atualiza o cache
      if (document != null) {
        await localDataSource.cacheSingleDocument(artistId, document);
      }
      
      return Right(document);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== SET OPERATIONS ====================

  @override
  Future<Either<Failure, void>> setDocument(
    String artistId,
    DocumentsEntity document,
  ) async {
    try {
      // Salva no remoto
      await remoteDataSource.setDocument(artistId, document);
      
      // Atualiza o cache
      await localDataSource.cacheSingleDocument(artistId, document);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== DELETE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> deleteDocument(
    String artistId,
    String documentType,
  ) async {
    try {
      // Deleta do remoto
      await remoteDataSource.deleteDocument(artistId, documentType);
      
      // Limpa cache do documento específico (removendo do cache)
      // Para isso, buscamos todos os documentos do cache, removemos o específico e salvamos novamente
      try {
        final cachedDocuments = await localDataSource.getCachedDocuments(artistId);
        final updatedDocuments = cachedDocuments.where((doc) => doc.documentType != documentType).toList();
        await localDataSource.cacheDocuments(artistId, updatedDocuments);
      } catch (e) {
        // Se falhar ao atualizar cache, não falha a operação
        // Apenas loga se necessário
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

