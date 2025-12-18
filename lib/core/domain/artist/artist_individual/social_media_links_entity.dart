import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'social_media_links_entity.mapper.dart';

@MappableClass()
class SocialMediaLinksEntity with SocialMediaLinksEntityMappable {
  final String? instagram;
  final String? youtube;
  final String? tiktok;
  final String? spotify;

  const SocialMediaLinksEntity({
    this.instagram,
    this.youtube,
    this.tiktok,
    this.spotify,
  });
}

extension SocialMediaLinksEntityReference on SocialMediaLinksEntity {
  static CollectionReference firebaseUidReference(FirebaseFirestore firestore, String uid) {
    final artistCollectionRef = ArtistEntityReference.firebaseUidReference(firestore, uid);
    final socialMediaLinksDocRef = artistCollectionRef.collection('SocialMediaLinks');
    return socialMediaLinksDocRef;
  }

  static String cachedKey() {
    return 'CACHE_SOCIAL_MEDIA_LINKS';
  }
}



