import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache) para Documents
/// Responsável APENAS por operações de cache
/// 
/// REGRAS:
/// - Lança [CacheException] em caso de erro
/// - NÃO faz validações de negócio
abstract class IDocumentsLocalDataSource {
  /// Busca lista de documentos do artista do cache
  /// Retorna lista vazia se não existir no cache
  Future<List<DocumentsEntity>> getCachedDocuments(String artistId);

  /// Salva lista de documentos do artista no cache
  Future<void> cacheDocuments(String artistId, List<DocumentsEntity> documents);
  
  /// Busca um documento específico do cache
  /// Lança [CacheException] se não encontrado
  Future<DocumentsEntity> getSingleCachedDocument(String artistId, String documentType);

  /// Salva um documento específico no cache
  Future<void> cacheSingleDocument(String artistId, DocumentsEntity document);
  
  /// Limpa cache de documentos do artista
  Future<void> clearDocumentsCache(String artistId);
  
  /// Limpa cache de todos os documentos
  Future<void> clearAllDocumentsCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class DocumentsLocalDataSourceImpl implements IDocumentsLocalDataSource {
  final ILocalCacheService autoCacheService;

  DocumentsLocalDataSourceImpl({required this.autoCacheService});

  /// Gera chave de cache para documentos de um artista
  String _getCacheKey(String artistId) {
    return '${DocumentsEntityReference.cachedKey()}_$artistId';
  }

  @override
  Future<List<DocumentsEntity>> getCachedDocuments(String artistId) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      final cacheKey = _getCacheKey(artistId);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      // Verificar se dados não são vazios
      if (cachedData.isEmpty) {
        return [];
      }

      List<DocumentsEntity> documentsList = [];
      for (var entry in cachedData.entries) {
        final documentMap = entry.value as Map<String, dynamic>;
        final documentEntity = DocumentsEntityMapper.fromMap(documentMap);
        documentsList.add(documentEntity);
      }
      return documentsList;
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao obter documentos do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheDocuments(String artistId, List<DocumentsEntity> documents) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      final cacheKey = _getCacheKey(artistId);
      final documentsMap = <String, dynamic>{};
      
      for (var document in documents) {
        if (document.documentType.isEmpty) {
          throw CacheException(
            'Documento sem documentType não pode ser salvo no cache. documentType: ${document.documentType}',
          );
        }
        documentsMap[document.documentType] = document.toMap();
      }

      await autoCacheService.cacheDataString(cacheKey, documentsMap);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar documentos no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<DocumentsEntity> getSingleCachedDocument(
    String artistId,
    String documentType,
  ) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      if (documentType.isEmpty) {
        throw const CacheException('Tipo de documento não pode ser vazio');
      }

      final cacheKey = _getCacheKey(artistId);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      if (cachedData.isEmpty || !cachedData.containsKey(documentType)) {
        throw CacheException('Documento não encontrado no cache: $documentType');
      }
      
      final documentMap = cachedData[documentType] as Map<String, dynamic>;
      final documentEntity = DocumentsEntityMapper.fromMap(documentMap);
      return documentEntity;
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao obter documento do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheSingleDocument(String artistId, DocumentsEntity document) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      if (document.documentType.isEmpty) {
        throw const CacheException('Documento deve ter um documentType válido para ser salvo no cache');
      }
      
      final cacheKey = _getCacheKey(artistId);
      // Busca cache existente para não sobrescrever outros documentos
      final existingCache = await autoCacheService.getCachedDataString(cacheKey);
      final documentMap = document.toMap();
      existingCache[document.documentType] = documentMap;
      await autoCacheService.cacheDataString(cacheKey, existingCache);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar documento no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  @override
  Future<void> clearDocumentsCache(String artistId) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      final cacheKey = _getCacheKey(artistId);
      await autoCacheService.deleteCachedDataString(cacheKey);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao limpar cache de documentos',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAllDocumentsCache() async {
    try {
      // Não há uma maneira fácil de limpar todos os caches de documentos
      // sem saber todos os artistIds. Esta implementação pode ser expandida
      // se necessário, mas por enquanto apenas logamos ou não fazemos nada.
      // Se precisar, podemos manter uma lista de artistIds em cache separado.
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de todos os documentos',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

