import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local para Availability
/// 
/// Responsável por cache local usando ILocalCacheService
/// REGRAS:
/// - Retorna null se não existe no cache
/// - NÃO lança exceções (operações silenciosas)
/// - Cache organizado por artistId
abstract class IAvailabilityLocalDataSource {
  /// Busca todas as disponibilidades cacheadas de um artista
  /// 
  /// [artistId]: ID do artista
  /// 
  /// Retorna lista de todos os dias cacheados
  Future<List<AvailabilityDayEntity>> getAvailabilities(String artistId);


  /// Busca uma disponibilidade cacheada de um artista
  /// 
  /// [artistId]: ID do artista
  /// [dayId]: ID do dia a buscar
  Future<AvailabilityDayEntity> getAvailability(String artistId, String dayId);
  

  /// Salva uma disponibilidade no cache
  /// 
  /// [artistId]: ID do artista
  /// [day]: Documento do dia a cachear
  Future<void> cacheAvailability(String artistId, AvailabilityDayEntity day);
  
  /// Remove uma disponibilidade do cache
  /// 
  /// [artistId]: ID do artista
  /// [dayId]: ID do dia a remover
  Future<void> removeAvailability(String artistId, String dayId);
  
  /// Limpa todo o cache de disponibilidade de um artista
  /// 
  /// [artistId]: ID do artista
  Future<void> clearCache(String artistId);
}

/// Implementação do DataSource local usando ILocalCacheService
class AvailabilityLocalDataSourceImpl implements IAvailabilityLocalDataSource {
  final ILocalCacheService localCacheService;
  
  AvailabilityLocalDataSourceImpl({required this.localCacheService});
  
  /// Prefixo para todas as keys de cache
  static const String _cachePrefix = 'availability_days';
  
  /// Key para o array de dias dentro do JSON
  static const String _daysKey = 'days';
  
  @override
  Future<List<AvailabilityDayEntity>> getAvailabilities(String artistId) async {
    try {
      final key = _getCacheKey(artistId);
      final cachedData = await localCacheService.getCachedDataString(key);
      
      if (cachedData.isEmpty || !cachedData.containsKey(_daysKey)) {
        return [];
      }

      final jsonList = cachedData[_daysKey] as List<dynamic>;
      return jsonList
          .map((json) => AvailabilityDayEntityMapper.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      
      // Se for erro de mapeamento (cache no formato antigo), limpar cache
      if (e.toString().contains('MapperException') || 
          e.toString().contains('Parameter availabilities is missing') ||
          e.toString().contains('addresses')) {
        await clearCache(artistId);
      }
      
      return [];
    }
  }

  @override
  Future<AvailabilityDayEntity> getAvailability(String artistId, String dayId) async {
    try {
      final availabilities = await getAvailabilities(artistId);
      if (availabilities.isEmpty) {
        throw NotFoundException('Disponibilidade não encontrada para o artista: $artistId');
      }
      final day = availabilities.firstWhere((day) => day.documentId == dayId);
      return day;
    } catch (e) {
      throw CacheException('Erro ao buscar disponibilidade: $e');
    }
  }
  
  @override
  Future<void> cacheAvailability(String artistId, AvailabilityDayEntity day) async {
    try {
      final allDays = await getAvailabilities(artistId);
      
      // Remover dia existente se houver
      allDays.removeWhere((d) => d.documentId == day.documentId);
      
      // Adicionar novo/atualizado
      allDays.add(day);
      
      // Salvar
      await _saveAllDays(artistId, allDays);
    } catch (e) {
      throw CacheException('Erro ao cachear disponibilidade: $e');
    }
  }
  
  @override
  Future<void> removeAvailability(String artistId, String dayId) async {
    try {
      final allDays = await getAvailabilities(artistId);
      allDays.removeWhere((day) => day.documentId == dayId);
      await _saveAllDays(artistId, allDays);
    } catch (e) {
      throw CacheException('Erro ao remover disponibilidade: $e');
    }
  }
  
  @override
  Future<void> clearCache(String artistId) async {
    try {
      final key = _getCacheKey(artistId);
      await localCacheService.deleteCachedDataString(key);
    } catch (e) {
      throw CacheException('Erro ao limpar cache: $e');
    }
  }
  
  // ==================== HELPERS ====================
  
  String _getCacheKey(String artistId) {
    return '${_cachePrefix}_$artistId';
  }
  
  Future<void> _saveAllDays(String artistId, List<AvailabilityDayEntity> days) async {
    try {
      final key = _getCacheKey(artistId);
      final jsonList = days.map((day) => day.toMap()).toList();
      final cacheData = {_daysKey: jsonList};
      await localCacheService.cacheDataString(key, cacheData);
    } catch (e) {
      throw CacheException('Erro ao salvar dias: $e');
    }
  }
}
