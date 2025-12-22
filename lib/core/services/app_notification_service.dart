import 'package:app/core/enums/notification_type_enum.dart';
import 'package:app/core/shared/widgets/app_toast_widget.dart';
import 'package:flutter/material.dart';

/// Interface do serviço de notificações in-app
/// 
/// RESPONSABILIDADES:
/// - Exibir notificações toast personalizadas
/// - Gerenciar ciclo de vida das notificações
/// - Suportar diferentes tipos de notificação
abstract class IAppNotificationService {
  /// Exibe uma notificação toast
  /// 
  /// [context] - BuildContext necessário para acessar Overlay
  /// [message] - Mensagem a ser exibida
  /// [type] - Tipo da notificação (success, error, warning, info)
  /// [duration] - Duração que a notificação ficará visível
  void show({
    required BuildContext context,
    required String message,
    required NotificationType type,
    Duration? duration,
  });

  /// Esconde a notificação atual (se houver)
  void hide();
}

class AppNotificationServiceImpl implements IAppNotificationService {
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;
  OverlayState? _overlayState;

  @override
  void show({
    required BuildContext context,
    required String message,
    required NotificationType type,
    Duration? duration,
  }) {
    // Se já houver uma notificação visível, remove antes de mostrar nova
    if (_isVisible) {
      hide();
    }

    _overlayState = Overlay.of(context);
    if (_overlayState == null) return;

    final effectiveDuration = duration ?? _getDefaultDuration(type);

    _overlayEntry = _createOverlayEntry(
      context: context,
      message: message,
      type: type,
      duration: effectiveDuration,
    );

    _overlayState!.insert(_overlayEntry!);
    _isVisible = true;

    // Auto-dismiss após a duração especificada
    Future.delayed(effectiveDuration, () {
      if (_isVisible) {
        hide();
      }
    });
  }

  @override
  void hide() {
    if (!_isVisible || _overlayEntry == null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
    _overlayState = null;
  }

  OverlayEntry _createOverlayEntry({
    required BuildContext context,
    required String message,
    required NotificationType type,
    required Duration duration,
  }) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: AppToastWidget(
            message: message,
            type: type,
            onDismiss: hide,
          ),
        ),
      ),
    );
  }

  Duration _getDefaultDuration(NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return const Duration(seconds: 4); // Erros precisam mais tempo
      case NotificationType.warning:
        return const Duration(seconds: 3);
      case NotificationType.success:
        return const Duration(seconds: 2); // Sucesso pode ser mais rápido
      case NotificationType.info:
        return const Duration(seconds: 3);
    }
  }
}