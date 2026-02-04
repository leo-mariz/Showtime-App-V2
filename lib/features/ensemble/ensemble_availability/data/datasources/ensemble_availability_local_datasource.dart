import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_availability_day_reference.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local para Availability do conjunto
///
/// Responsável por cache local usando ILocalCacheService
/// REGRAS:
/// - Retorna null se não existe no cache
/// - NÃO lança exceções (operações silenciosas)
/// - Cache organizado por ensembleId
abstract class IEnsembleAvailabilityLocalDataSource {
  /// Busca todas as disponibilidades cacheadas de um conjunto
  /// 
  /// [ensembleId]: ID do conjunto
  /// 
  /// Retorna lista de todos os dias cacheados
  Future<List<AvailabilityDayEntity>> getAvailabilities(String ensembleId);


  /// Busca uma disponibilidade cacheada de um conjunto
  /// 
  /// [ensembleId]: ID do conjunto
  /// [dayId]: ID do dia a buscar
  Future<AvailabilityDayEntity> getAvailability(String ensembleId, String dayId);
  

  /// Salva uma disponibilidade no cache
  /// 
  /// [ensembleId]: ID do conjunto
  /// [day]: Documento do dia a cachear
  Future<void> cacheAvailability(String ensembleId, AvailabilityDayEntity day);
  
  /// Remove uma disponibilidade do cache
  /// 
  /// [ensembleId]: ID do conjunto
  /// [dayId]: ID do dia a remover
  Future<void> removeAvailability(String ensembleId, String dayId);
  
  /// Limpa todo o cache de disponibilidade de um conjunto
  /// 
  /// [ensembleId]: ID do conjunto
  Future<void> clearCache(String ensembleId);
}

/// Implementação do DataSource local usando ILocalCacheService
class EnsembleAvailabilityLocalDataSourceImpl
    implements IEnsembleAvailabilityLocalDataSource {
  final ILocalCacheService localCacheService;
  
  EnsembleAvailabilityLocalDataSourceImpl({required this.localCacheService});
  
  /// Usa keys de cache do core (EnsembleAvailabilityDayReference)
  String _getCacheKey(String ensembleId) {
    return EnsembleAvailabilityDayReference.cacheKey(ensembleId);
  }
  
  /// Key para o array de dias dentro do JSON
  static const String _daysKey = 'days';
  
  @override
  Future<List<AvailabilityDayEntity>> getAvailabilities(String ensembleId) async {
    try {
      final key = _getCacheKey(ensembleId);
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
        await clearCache(ensembleId);
      }
      
      return [];
    }
  }

  @override
  Future<AvailabilityDayEntity> getAvailability(String ensembleId, String dayId) async {
    try {
      final availabilities = await getAvailabilities(ensembleId);
      if (availabilities.isEmpty) {
        throw NotFoundException('Disponibilidade não encontrada para o conjunto: $ensembleId');
      }
      print('[LocalDataSource] 🔍 Buscando disponibilidade. dayId: $dayId, total: ${availabilities.length}');
      
      final day = availabilities.firstWhere(
        (day) => day.documentId == dayId,
        orElse: () {
          print('[LocalDataSource] ❌ Dia não encontrado: $dayId');
          throw NotFoundException('Dia $dayId não encontrado');
        },
      );
      print('[LocalDataSource] ✅ Dia encontrado: $dayId');
      return day;
    } catch (e) {
      throw CacheException('Erro ao buscar disponibilidade: $e');
    }
  }
  
  @override
  Future<void> cacheAvailability(String ensembleId, AvailabilityDayEntity day) async {
    try {
      final allDays = await getAvailabilities(ensembleId);
      
      // Remover dia existente se houver
      allDays.removeWhere((d) => d.documentId == day.documentId);
      
      // Adicionar novo/atualizado
      allDays.add(day);
      
      // Salvar
      await _saveAllDays(ensembleId, allDays);
    } catch (e) {
      throw CacheException('Erro ao cachear disponibilidade: $e');
    }
  }
  
  @override
  Future<void> removeAvailability(String ensembleId, String dayId) async {
    try {
      final allDays = await getAvailabilities(ensembleId);
      allDays.removeWhere((day) => day.documentId == dayId);
      await _saveAllDays(ensembleId, allDays);
    } catch (e) {
      throw CacheException('Erro ao remover disponibilidade: $e');
    }
  }
  
  @override
  Future<void> clearCache(String ensembleId) async {
    try {
      final key = _getCacheKey(ensembleId);
      await localCacheService.deleteCachedDataString(key);
    } catch (e) {
      throw CacheException('Erro ao limpar cache: $e');
    }
  }
  
  // ==================== HELPERS ====================

  Future<void> _saveAllDays(String ensembleId, List<AvailabilityDayEntity> days) async {
    try {
      final key = _getCacheKey(ensembleId);
      final jsonList = days.map((day) => day.toMap()).toList();
      final cacheData = {_daysKey: jsonList};
      await localCacheService.cacheDataString(key, cacheData);
    } catch (e) {
      throw CacheException('Erro ao salvar dias: $e');
    }
  }
}
