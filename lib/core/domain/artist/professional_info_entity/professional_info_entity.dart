import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'professional_info_entity.mapper.dart';

@MappableClass()
class ProfessionalInfoEntity with ProfessionalInfoEntityMappable {
  final List<String>? specialty;
  final List<String>? genrePreferences;
  final int? minimumShowDuration;
  final int? preparationTime;
  final String? bio;
  final double? hourlyRate;

  const ProfessionalInfoEntity({
    this.specialty,
    this.genrePreferences,
    this.minimumShowDuration,
    this.preparationTime,
    this.bio,
    this.hourlyRate,
  });

}

extension ProfessionalInfoEntityReference on ProfessionalInfoEntity {
  static CollectionReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final artistCollectionRef = ArtistEntityReference.firebaseUidReference(firestore, uid);
    final professionalInfoDocRef = artistCollectionRef.collection('ProfessionalInfo');
    return professionalInfoDocRef;
  }

  static String cachedKey() {
    return 'CACHE_PROFESSIONAL_INFO';
  }
}

