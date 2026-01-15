import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';

/// Extension para filtrar artistas por busca
/// 
/// Busca em: nome do artista, talentos (specialty) e bio
extension ArtistSearchExtension on List<ArtistWithAvailabilitiesEntity> {
  /// Filtra a lista de artistas baseado na query de busca
  /// 
  /// Busca case-insensitive em:
  /// - Nome do artista (artistName)
  /// - Talentos (professionalInfo.specialty)
  /// - Bio (professionalInfo.bio)
  List<ArtistWithAvailabilitiesEntity> filterBySearch(String query) {
    if (query.isEmpty) {
      return this;
    }

    final lowerQuery = query.trim().toLowerCase();

    return where((artistWithAvailabilities) {
      final artist = artistWithAvailabilities.artist;

      // Buscar no nome do artista
      final artistName = (artist.artistName ?? '').toLowerCase();
      if (artistName.contains(lowerQuery)) {
        return true;
      }

      // Buscar nos talentos (specialty)
      final specialty = artist.professionalInfo?.specialty ?? [];
      final hasMatchingSpecialty = specialty.any(
        (talent) => talent.toLowerCase().contains(lowerQuery),
      );
      if (hasMatchingSpecialty) {
        return true;
      }

      // Buscar na bio
      final bio = (artist.professionalInfo?.bio ?? '').toLowerCase();
      if (bio.contains(lowerQuery)) {
        return true;
      }

      return false;
    }).toList();
  }
}

