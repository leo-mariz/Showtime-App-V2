import 'package:app/core/config/setup_locator.dart';
import 'package:app/core/services/app_notification_service.dart';
import 'package:app/core/enums/notification_type_enum.dart';
import 'package:flutter/material.dart';

/// Extensões para facilitar o uso de notificações via BuildContext
/// 
/// USO:
/// ```dart
/// context.showSuccess('Operação realizada com sucesso!');
/// context.showError('Erro ao processar solicitação');
/// context.showWarning('Atenção: dados incompletos');
/// context.showInfo('Nova atualização disponível');
/// ```
extension NotificationExtension on BuildContext {
  /// Exibe notificação de sucesso
  void showSuccess(String message, {Duration? duration}) {
    final service = getIt<IAppNotificationService>();
    service.show(
      context: this,
      message: message,
      type: NotificationType.success,
      duration: duration,
    );
  }

  /// Exibe notificação de erro
  void showError(String message, {Duration? duration}) {
    final service = getIt<IAppNotificationService>();
    service.show(
      context: this,
      message: message,
      type: NotificationType.error,
      duration: duration,
    );
  }

  /// Exibe notificação de aviso
  void showWarning(String message, {Duration? duration}) {
    final service = getIt<IAppNotificationService>();
    service.show(
      context: this,
      message: message,
      type: NotificationType.warning,
      duration: duration,
    );
  }

  /// Exibe notificação informativa
  void showInfo(String message, {Duration? duration}) {
    final service = getIt<IAppNotificationService>();
    service.show(
      context: this,
      message: message,
      type: NotificationType.info,
      duration: duration,
    );
  }
}

