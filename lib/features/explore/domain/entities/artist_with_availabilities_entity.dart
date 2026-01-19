// import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
// import 'package:app/core/domain/artist/availability/availability_entity.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dart_mappable/dart_mappable.dart';

// part 'artist_with_availabilities_entity.mapper.dart';

// /// Entidade que agrupa um artista com suas disponibilidades
// /// Usada na feature explore para representar artistas disponíveis para contratação
// @MappableClass()
// class ArtistWithAvailabilitiesEntity with ArtistWithAvailabilitiesEntityMappable {
//   final ArtistEntity artist;
//   final List<AvailabilityEntity> availabilities;
//   final bool isFavorite;

//   ArtistWithAvailabilitiesEntity({
//     required this.artist,
//     required this.availabilities,
//     this.isFavorite = false,
//   });

//   /// Factory para criar uma instância com lista vazia de disponibilidades
//   factory ArtistWithAvailabilitiesEntity.empty(ArtistEntity artist) {
//     return ArtistWithAvailabilitiesEntity(
//       artist: artist,
//       availabilities: [],
//       isFavorite: false,
//     );
//   }

//   /// Verifica se o artista tem disponibilidades
//   bool get hasAvailabilities => availabilities.isNotEmpty;
// }

// /// Extension para centralizar referências do Firestore relacionadas a explore
// extension ArtistWithAvailabilitiesEntityReference on ArtistWithAvailabilitiesEntity {
//   // ==================== CACHE KEYS (Constantes) ====================
  
//   /// Chave de cache para artistas no explore
//   static const String artistsCacheKey = 'explore_artists_cache';
  
//   /// Prefixo usado para criar chaves únicas de disponibilidades por artista
//   static const String availabilitiesCacheKeyPrefix = 'explore_availability_';

//   static const String favoritesCacheKey = 'favorites_cache';
  
//   // ==================== CACHE VALIDITY (Constantes) ====================
  
//   /// Validade do cache de artistas (2 horas)
//   static const Duration artistsCacheValidity = Duration(hours: 2);
  
//   /// Validade do cache de disponibilidades (2 horas)
//   static const Duration availabilitiesCacheValidity = Duration(hours: 2);
  
//   // ==================== FIRESTORE REFERENCES ====================
  
//   /// Referência à coleção de artistas no Firestore
//   /// Usado para buscar artistas aprovados e ativos
//   static CollectionReference artistsCollectionReference(FirebaseFirestore firestore) {
//     return ArtistEntityReference.firebaseCollectionReference(firestore);
//   }

//   /// Referência à subcoleção de disponibilidades de um artista
//   /// Usado para buscar disponibilidades de um artista específico
//   /// Path: Artists/{artistId}/Availability
//   static CollectionReference artistAvailabilitiesCollectionReference(
//     FirebaseFirestore firestore,
//     String artistId,
//   ) {
//     return ArtistAvailabilityEntityReference.firestoreUidReference(
//       firestore,
//       artistId,
//     );
//   }
  
//   // ==================== CACHE KEY HELPERS ====================
  
//   /// Gera chave de cache completa para disponibilidades de um artista
//   /// Usa o prefixo constante + artistId
//   static String artistAvailabilitiesCacheKey(String artistId) {
//     return '$availabilitiesCacheKeyPrefix$artistId';
//   }
  
//   /// Gera chave de cache para disponibilidades filtradas
//   /// Inclui artistId, data e geohash para criar chave única por filtro
//   /// 
//   /// [artistId]: ID do artista
//   /// [selectedDate]: Data selecionada (opcional)
//   /// [userGeohash]: Geohash do usuário (opcional)
//   static String artistAvailabilitiesFilteredCacheKey(
//     String artistId, {
//     DateTime? selectedDate,
//     String? userGeohash,
//   }) {
//     final dateKey = selectedDate != null 
//         ? '_${selectedDate.toIso8601String().split('T')[0]}' 
//         : '';
//     final geohashKey = userGeohash != null && userGeohash.isNotEmpty
//         ? '_$userGeohash'
//         : '';
//     return '$availabilitiesCacheKeyPrefix$artistId$dateKey$geohashKey';
//   }
// }

