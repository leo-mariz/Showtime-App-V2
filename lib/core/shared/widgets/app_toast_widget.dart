import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/enums/notification_type_enum.dart';
import 'package:flutter/material.dart';

/// Widget de toast personalizado para notificações in-app
/// 
/// Segue o design system do app e suporta diferentes tipos de notificação
class AppToastWidget extends StatelessWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const AppToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final notificationConfig = _getNotificationConfig(type, colorScheme);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
        padding: EdgeInsets.symmetric(horizontal: DSSize.width(16), vertical: DSSize.height(14)),
        decoration: BoxDecoration(
          color: notificationConfig.backgroundColor,
          borderRadius: BorderRadius.circular(DSSize.width(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: DSSize.width(12),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              notificationConfig.icon,
              color: notificationConfig.iconColor,
              size: DSSize.width(24),
            ),
            DSSizedBoxSpacing.horizontal(12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: notificationConfig.textColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DSSizedBoxSpacing.horizontal(8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: notificationConfig.iconColor,
                size: DSSize.width(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NotificationConfig _getNotificationConfig(
    NotificationType type,
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case NotificationType.success:
        return _NotificationConfig(
          backgroundColor: const Color(0xFF2E7D32), // Verde escuro
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.check_circle_rounded,
        );
      case NotificationType.error:
        return _NotificationConfig(
          backgroundColor: colorScheme.onError, // Vermelho do tema
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.error_rounded,
        );
      case NotificationType.warning:
        return _NotificationConfig(
          backgroundColor: const Color(0xFFF57C00), // Laranja
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.warning_rounded,
        );
      case NotificationType.info:
        return _NotificationConfig(
          backgroundColor: colorScheme.primaryContainer,
          textColor: colorScheme.onPrimaryContainer,
          iconColor: colorScheme.onPrimaryContainer,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _NotificationConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  _NotificationConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}

