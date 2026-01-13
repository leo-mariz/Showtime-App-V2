import 'package:dart_mappable/dart_mappable.dart';
part 'rating_entity.mapper.dart';

@MappableClass()
class RatingEntity with RatingEntityMappable {
  final String? comment;
  final double rating;
  final bool isClientRating;
  final bool skippedRating;
  final DateTime createdAt;
  final DateTime? ratedAt;
  final bool isPublic;  // NOVO: se já pode ser exibida publicamente
  final String? artistResponse;  // NOVO: resposta do artista (se cliente avaliou)
  final DateTime? artistResponseAt;

  RatingEntity({
    this.comment,
    required this.rating,
    required this.isClientRating,
    required this.skippedRating,
    this.ratedAt,
    this.isPublic = false,
    this.artistResponse,
    this.artistResponseAt,
  }) : createdAt = DateTime.now();
}