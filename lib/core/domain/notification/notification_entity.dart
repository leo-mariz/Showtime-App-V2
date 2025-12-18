import 'package:app/core/enums/notification_type_enum.dart';

class NotificationEntity {
  final String id;
  final String message;
  final String? title;
  final NotificationType type;
  final Duration duration;
  final bool isDismissible;

  NotificationEntity({
    required this.id,
    required this.message,
    this.title,
    required this.type,
    this.duration = const Duration(seconds: 4),
    this.isDismissible = true,
  });
}
