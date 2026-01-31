import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local para Members (integrantes).
///
/// Cache local por artistId + ensembleId. REGRAS:
/// - Retorna lista vazia / null quando não há cache
/// - Lança [CacheException] em caso de erro de escrita/leitura
abstract class IMembersLocalDataSource {
  /// Lista integrantes cacheados do conjunto.
  Future<List<EnsembleMemberEntity>> getAllByEnsemble(
    String artistId,
    String ensembleId,
  );

  /// Busca um integrante cacheado por ID.
  Future<EnsembleMemberEntity?> getById(
    String artistId,
    String ensembleId,
    String memberId,
  );

  /// Salva/atualiza um integrante no cache.
  Future<void> cacheMember(
    String artistId,
    String ensembleId,
    EnsembleMemberEntity member,
  );

  /// Remove um integrante do cache.
  Future<void> removeMember(
    String artistId,
    String ensembleId,
    String memberId,
  );

  /// Limpa o cache de integrantes do conjunto.
  Future<void> clearCache(String artistId, String ensembleId);
}

/// Implementação usando [ILocalCacheService].
/// Chaves de cache: prefixo local (EnsembleMemberEntity não define cache keys).
class MembersLocalDataSourceImpl implements IMembersLocalDataSource {
  final ILocalCacheService localCacheService;

  MembersLocalDataSourceImpl({required this.localCacheService});

  static const String _cachePrefix = 'ensemble_members';
  static const String _membersKey = 'members';

  String _cacheKey(String artistId, String ensembleId) =>
      '${_cachePrefix}_${artistId}_$ensembleId';

  @override
  Future<List<EnsembleMemberEntity>> getAllByEnsemble(
    String artistId,
    String ensembleId,
  ) async {
    try {
      final key = _cacheKey(artistId, ensembleId);
      final data = await localCacheService.getCachedDataString(key);
      if (data.isEmpty || !data.containsKey(_membersKey)) return [];
      final list = data[_membersKey] as List<dynamic>;
      return list
          .map((e) => EnsembleMemberEntityMapper.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (_isMapperOrFormatError(e)) {
        await clearCache(artistId, ensembleId);
      }
      return [];
    }
  }

  @override
  Future<EnsembleMemberEntity?> getById(
    String artistId,
    String ensembleId,
    String memberId,
  ) async {
    try {
      final list = await getAllByEnsemble(artistId, ensembleId);
      try {
        return list.firstWhere((e) => e.id == memberId);
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw CacheException('Erro ao buscar integrante no cache: $e');
    }
  }

  @override
  Future<void> cacheMember(
    String artistId,
    String ensembleId,
    EnsembleMemberEntity member,
  ) async {
    try {
      final list = await getAllByEnsemble(artistId, ensembleId);
      list.removeWhere((e) => e.id == member.id);
      list.add(member);
      await _saveAll(artistId, ensembleId, list);
    } catch (e) {
      throw CacheException('Erro ao cachear integrante: $e');
    }
  }

  @override
  Future<void> removeMember(
    String artistId,
    String ensembleId,
    String memberId,
  ) async {
    try {
      final list = await getAllByEnsemble(artistId, ensembleId);
      list.removeWhere((e) => e.id == memberId);
      await _saveAll(artistId, ensembleId, list);
    } catch (e) {
      throw CacheException('Erro ao remover integrante do cache: $e');
    }
  }

  @override
  Future<void> clearCache(String artistId, String ensembleId) async {
    try {
      await localCacheService
          .deleteCachedDataString(_cacheKey(artistId, ensembleId));
    } catch (e) {
      throw CacheException('Erro ao limpar cache de integrantes: $e');
    }
  }

  Future<void> _saveAll(
    String artistId,
    String ensembleId,
    List<EnsembleMemberEntity> members,
  ) async {
    final key = _cacheKey(artistId, ensembleId);
    final jsonList = members.map((e) => e.toMap()).toList();
    await localCacheService.cacheDataString(key, {_membersKey: jsonList});
  }

  bool _isMapperOrFormatError(Object e) {
    final s = e.toString();
    return s.contains('MapperException') ||
        s.contains('Parameter') ||
        s.contains('missing');
  }
}
