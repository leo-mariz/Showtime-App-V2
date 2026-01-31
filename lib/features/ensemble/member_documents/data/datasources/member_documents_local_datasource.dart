import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local para MemberDocuments (documentos do integrante).
///
/// Cache local por artistId + ensembleId + memberId. REGRAS:
/// - Retorna null / lista vazia quando não há cache
/// - Lança [CacheException] em caso de erro de escrita/leitura
abstract class IMemberDocumentsLocalDataSource {
  /// Busca um documento cacheado por tipo (identity ou antecedents).
  Future<MemberDocumentEntity?> get(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  );

  /// Lista os documentos cacheados do integrante.
  Future<List<MemberDocumentEntity>> getAllByMember(
    String artistId,
    String ensembleId,
    String memberId,
  );

  /// Salva/atualiza um documento no cache.
  Future<void> cacheDocument(
    String artistId,
    MemberDocumentEntity document,
  );

  /// Remove um documento do cache.
  Future<void> removeDocument(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  );

  /// Limpa o cache de documentos do integrante.
  Future<void> clearCache(
    String artistId,
    String ensembleId,
    String memberId,
  );
}

/// Implementação usando [ILocalCacheService].
/// Chaves de cache: [MemberDocumentEntityReference.cacheMemberDocumentsKey].
class MemberDocumentsLocalDataSourceImpl
    implements IMemberDocumentsLocalDataSource {
  final ILocalCacheService localCacheService;

  MemberDocumentsLocalDataSourceImpl({required this.localCacheService});

  static const String _documentsKey = 'documents';

  String _cacheKey(String artistId, String ensembleId, String memberId) =>
      MemberDocumentEntityReference.cacheMemberDocumentsKey(memberId);

  @override
  Future<MemberDocumentEntity?> get(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  ) async {
    try {
      final list = await getAllByMember(artistId, ensembleId, memberId);
      try {
        return list.firstWhere((e) => e.documentType == documentType);
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw CacheException('Erro ao buscar documento no cache: $e');
    }
  }

  @override
  Future<List<MemberDocumentEntity>> getAllByMember(
    String artistId,
    String ensembleId,
    String memberId,
  ) async {
    try {
      final key = _cacheKey(artistId, ensembleId, memberId);
      final data = await localCacheService.getCachedDataString(key);
      if (data.isEmpty || !data.containsKey(_documentsKey)) return [];
      final list = data[_documentsKey] as List<dynamic>;
      return list
          .map((e) => MemberDocumentEntityMapper.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (_isMapperOrFormatError(e)) {
        await clearCache(artistId, ensembleId, memberId);
      }
      return [];
    }
  }

  @override
  Future<void> cacheDocument(
    String artistId,
    MemberDocumentEntity document,
  ) async {
    try {
      final list = await getAllByMember(
        document.artistId,
        document.ensembleId,
        document.memberId,
      );
      list.removeWhere((e) => e.documentType == document.documentType);
      list.add(document);
      await _saveAll(
        document.artistId,
        document.ensembleId,
        document.memberId,
        list,
      );
    } catch (e) {
      throw CacheException('Erro ao cachear documento: $e');
    }
  }

  @override
  Future<void> removeDocument(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  ) async {
    try {
      final list = await getAllByMember(artistId, ensembleId, memberId);
      list.removeWhere((e) => e.documentType == documentType);
      await _saveAll(artistId, ensembleId, memberId, list);
    } catch (e) {
      throw CacheException('Erro ao remover documento do cache: $e');
    }
  }

  @override
  Future<void> clearCache(
    String artistId,
    String ensembleId,
    String memberId,
  ) async {
    try {
      await localCacheService
          .deleteCachedDataString(_cacheKey(artistId, ensembleId, memberId));
    } catch (e) {
      throw CacheException('Erro ao limpar cache de documentos: $e');
    }
  }

  Future<void> _saveAll(
    String artistId,
    String ensembleId,
    String memberId,
    List<MemberDocumentEntity> documents,
  ) async {
    final key = _cacheKey(artistId, ensembleId, memberId);
    final jsonList = documents.map((e) => e.toMap()).toList();
    await localCacheService.cacheDataString(key, {_documentsKey: jsonList});
  }

  bool _isMapperOrFormatError(Object e) {
    final s = e.toString();
    return s.contains('MapperException') ||
        s.contains('Parameter') ||
        s.contains('missing');
  }
}
