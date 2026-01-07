import 'package:dart_geohash/dart_geohash.dart';

/// Helper para calcular Geohash usando o pacote dart_geohash
/// 
/// Wrapper em torno do pacote dart_geohash para manter a interface
/// consistente no projeto e facilitar futuras mudanças se necessário.
class GeohashHelper {
  static final _geoHasher = GeoHasher();

  /// Calcula Geohash a partir de latitude e longitude
  /// 
  /// [latitude]: Latitude (-90 a 90)
  /// [longitude]: Longitude (-180 a 180)
  /// [precision]: Número de caracteres no Geohash (padrão: 5 = ~4.9km de precisão)
  /// 
  /// NOTA: Para armazenar no banco, usar precisão 5 (~4.9km) é ideal
  /// Para buscar com raio de 40km, usar precisão 4 (~39km) no getRange
  /// 
  /// Retorna string Geohash
  static String encode(double latitude, double longitude, {int precision = 5}) {
    return _geoHasher.encode(latitude, longitude, precision: precision);
  }

  /// Calcula Geohashes vizinhos de um Geohash
  /// 
  /// Retorna um mapa com os 8 vizinhos (norte, sul, leste, oeste, etc.)
  /// Útil para buscar documentos próximos no Firestore
  static Map<String, String> neighbors(String geohash) {
    final neighborsMap = _geoHasher.neighbors(geohash);
    // O método neighbors retorna um Map<String, String> diretamente
    return neighborsMap;
  }

  /// Trunca um geohash para uma precisão específica
  /// 
  /// Se o geohash tiver mais caracteres que a precisão desejada, trunca.
  /// Se tiver menos, retorna como está.
  static String truncate(String geohash, int precision) {
    if (geohash.length <= precision) {
      return geohash;
    }
    return geohash.substring(0, precision);
  }

  /// Retorna o range mínimo e máximo de Geohashes para uma busca
  /// 
  /// Útil para queries no Firestore: buscar geohash >= min && geohash <= max
  /// Calcula baseado nos vizinhos do Geohash central
  /// 
  /// [centerGeohash]: Geohash central (pode ter qualquer precisão)
  /// [precision]: Precisão desejada para o range (padrão: 4 = ~39km, adequado para raio de 40km)
  /// 
  /// IMPORTANTE: Para raio de ~40km, usar precisão 4 (~39km x 19.5km)
  /// O geohash central será truncado para a precisão desejada antes de calcular os vizinhos
  static Map<String, String> getRange(String centerGeohash, {int precision = 4}) {
    // Truncar o geohash central para a precisão desejada
    final truncatedGeohash = truncate(centerGeohash, precision);
    
    print('🔹 [GEOHASH] getRange - Calculando range para geohash: $centerGeohash');
    print('🔹 [GEOHASH] Geohash truncado para precisão $precision: $truncatedGeohash');
    
    final neighborsMap = _geoHasher.neighbors(truncatedGeohash);
    print('🔹 [GEOHASH] Vizinhos calculados: $neighborsMap');
    
    // Coletar todos os Geohashes (central + 8 vizinhos)
    // O pacote dart_geohash retorna chaves em MAIÚSCULAS
    final allHashes = [
      truncatedGeohash,
      neighborsMap['NORTH'] ?? neighborsMap['n'] ?? '',
      neighborsMap['SOUTH'] ?? neighborsMap['s'] ?? '',
      neighborsMap['EAST'] ?? neighborsMap['e'] ?? '',
      neighborsMap['WEST'] ?? neighborsMap['w'] ?? '',
      neighborsMap['NORTHEAST'] ?? neighborsMap['ne'] ?? '',
      neighborsMap['NORTHWEST'] ?? neighborsMap['nw'] ?? '',
      neighborsMap['SOUTHEAST'] ?? neighborsMap['se'] ?? '',
      neighborsMap['SOUTHWEST'] ?? neighborsMap['sw'] ?? '',
    ].where((h) => h.isNotEmpty).toList();
    
    print('🔹 [GEOHASH] Todos os geohashes coletados: $allHashes');
    
    // Ordenar para encontrar min e max
    allHashes.sort();
    
    final min = allHashes.first;
    final max = allHashes.last;
    
    print('🔹 [GEOHASH] Range final: min=$min, max=$max');
    print('🔹 [GEOHASH] Geohash central truncado ($truncatedGeohash) está no range? ${truncatedGeohash.compareTo(min) >= 0 && truncatedGeohash.compareTo(max) <= 0}');
    
    return {
      'min': min,
      'max': max,
    };
  }
}

