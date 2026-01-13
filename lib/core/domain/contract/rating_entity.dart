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

  RatingEntity({
    this.comment,
    required this.rating,
    required this.isClientRating,
    required this.skippedRating,
    this.ratedAt,
  }) : createdAt = DateTime.now();
}