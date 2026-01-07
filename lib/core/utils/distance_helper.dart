import 'dart:math';

/// Helper para cálculos de distância geográfica
/// 
/// Implementa fórmulas para calcular distâncias entre coordenadas geográficas,
/// útil para filtrar artistas por raio de atuação.
class DistanceHelper {
  /// Raio médio da Terra em quilômetros
  static const double earthRadiusKm = 6371.0;

  /// Calcula distância entre duas coordenadas usando a fórmula de Haversine
  /// 
  /// [lat1]: Latitude do ponto 1 (em graus)
  /// [lon1]: Longitude do ponto 1 (em graus)
  /// [lat2]: Latitude do ponto 2 (em graus)
  /// [lon2]: Longitude do ponto 2 (em graus)
  /// 
  /// Retorna distância em quilômetros
  static double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Converter graus para radianos
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    // Fórmula de Haversine
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;

    return distance;
  }

  /// Converte graus para radianos
  static double _toRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// Verifica se uma coordenada está dentro do raio de atuação
  /// 
  /// [userLat]: Latitude do usuário
  /// [userLon]: Longitude do usuário
  /// [targetLat]: Latitude do alvo (artista/disponibilidade)
  /// [targetLon]: Longitude do alvo (artista/disponibilidade)
  /// [radiusKm]: Raio máximo em quilômetros
  /// 
  /// Retorna true se a distância for menor ou igual ao raio
  static bool isWithinRadius(
    double userLat,
    double userLon,
    double targetLat,
    double targetLon,
    double radiusKm,
  ) {
    final distance = calculateHaversineDistance(
      userLat,
      userLon,
      targetLat,
      targetLon,
    );
    return distance <= radiusKm;
  }
}

