import 'package:dart_mappable/dart_mappable.dart';
part 'show_rating_requested_entity.mapper.dart';

@MappableClass()
class ShowRatingRequestedEntity with ShowRatingRequestedEntityMappable {
  final bool showRatingRequested;
  final bool showRatingSkipped;
  final bool showRatingCompleted;
  final DateTime showRatingRequestedAt;
  final String showRatingRequestedFor;

  ShowRatingRequestedEntity({
    required this.showRatingRequested,
    required this.showRatingSkipped,
    required this.showRatingCompleted,
    required this.showRatingRequestedAt,
    required this.showRatingRequestedFor,
  });
}