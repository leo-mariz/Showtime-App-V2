import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local para Ensembles (conjuntos).
///
/// Cache local por artistId. REGRAS:
/// - Retorna lista vazia / null quando não há cache
/// - Lança [CacheException] em caso de erro de escrita/leitura
abstract class IEnsembleLocalDataSource {
  /// Lista conjuntos cacheados do artista.
  Future<List<EnsembleEntity>> getAllByArtist(String artistId);

  /// Busca um conjunto cacheado por ID.
  Future<EnsembleEntity?> getById(String artistId, String ensembleId);

  /// Salva/atualiza um conjunto no cache.
  Future<void> cacheEnsemble(String artistId, EnsembleEntity ensemble);

  /// Remove um conjunto do cache.
  Future<void> removeEnsemble(String artistId, String ensembleId);

  /// Limpa todo o cache de conjuntos do artista.
  Future<void> clearCache(String artistId);
}

/// Implementação usando [ILocalCacheService].
/// Chaves de cache: [EnsembleEntityReference.cacheKey] + artistId.
class EnsembleLocalDataSourceImpl implements IEnsembleLocalDataSource {
  final ILocalCacheService localCacheService;

  EnsembleLocalDataSourceImpl({required this.localCacheService});

  static const String _ensemblesKey = 'ensembles';

  String _cacheKey(String artistId) =>
      '${EnsembleEntityReference.cacheKey}_$artistId';

  @override
  Future<List<EnsembleEntity>> getAllByArtist(String artistId) async {
    try {
      final key = _cacheKey(artistId);
      final data = await localCacheService.getCachedDataString(key);
      if (data.isEmpty || !data.containsKey(_ensemblesKey)) return [];
      final list = data[_ensemblesKey] as List<dynamic>;
      return list
          .map((e) =>
              EnsembleEntityMapper.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (_isMapperOrFormatError(e)) {
        await clearCache(artistId);
      }
      return [];
    }
  }

  @override
  Future<EnsembleEntity?> getById(String artistId, String ensembleId) async {
    try {
      final list = await getAllByArtist(artistId);
      try {
        return list.firstWhere((e) => e.id == ensembleId);
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw CacheException('Erro ao buscar conjunto no cache: $e');
    }
  }

  @override
  Future<void> cacheEnsemble(String artistId, EnsembleEntity ensemble) async {
    try {
      final list = await getAllByArtist(artistId);
      list.removeWhere((e) => e.id == ensemble.id);
      list.add(ensemble);
      await _saveAll(artistId, list);
    } catch (e) {
      throw CacheException('Erro ao cachear conjunto: $e');
    }
  }

  @override
  Future<void> removeEnsemble(String artistId, String ensembleId) async {
    try {
      final list = await getAllByArtist(artistId);
      list.removeWhere((e) => e.id == ensembleId);
      await _saveAll(artistId, list);
    } catch (e) {
      throw CacheException('Erro ao remover conjunto do cache: $e');
    }
  }

  @override
  Future<void> clearCache(String artistId) async {
    try {
      await localCacheService.deleteCachedDataString(_cacheKey(artistId));
    } catch (e) {
      throw CacheException('Erro ao limpar cache de conjuntos: $e');
    }
  }

  Future<void> _saveAll(String artistId, List<EnsembleEntity> ensembles) async {
    final key = _cacheKey(artistId);
    final jsonList = ensembles.map((e) => e.toMap()).toList();
    await localCacheService.cacheDataString(key, {_ensemblesKey: jsonList});
  }

  bool _isMapperOrFormatError(Object e) {
    final s = e.toString();
    return s.contains('MapperException') ||
        s.contains('Parameter') ||
        s.contains('missing');
  }
}
