import 'package:app/core/errors/exceptions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class INotificationService {
  Future<void> initialize();
  Future<String?> getToken();
  Future<void> requestPermission();
  Future<void> onMessageReceived(RemoteMessage message);
  Future<void> onMessageOpenedApp(RemoteMessage message);
  Future<void> onBackgroundMessage(RemoteMessage message);
}

class NotificationService implements INotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    try {
      // Configurar notificações locais
      await _initializeLocalNotifications();
      if (kDebugMode) {
        print('🔔 NotificationService: Notificações locais configuradas');
      }

      // Configurar handlers para diferentes estados do app
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // Configurar handler para quando o app está em background
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

      // Solicitar permissões
      await requestPermission();
    } catch (e, stackTrace) {
      // Notificações são features não-críticas, não devemos travar o app
      if (kDebugMode) {
        print('⚠️ NotificationService: Erro ao inicializar notificações: $e');
      }
      throw ServerException(
        'Erro ao inicializar sistema de notificações',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro ao configurar notificações locais',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('🔑 FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao obter token FCM: $e');
      }
      // Não lançar exceção - token pode não estar disponível e tudo bem
      return null;
    }
  }

  @override
  Future<void> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print(
            '🔔 Permissão de notificação: ${settings.authorizationStatus}');
      }

      // Tratar diferentes status de permissão
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          if (kDebugMode) {
            print('✅ Notificações autorizadas!');
          }
          break;
        case AuthorizationStatus.denied:
          if (kDebugMode) {
            print('❌ Notificações negadas pelo usuário');
          }
          throw const PermissionException(
            'Usuário negou permissão para notificações',
          );
        case AuthorizationStatus.notDetermined:
          if (kDebugMode) {
            print('⚠️ Usuário ainda não decidiu sobre notificações');
          }
          break;
        case AuthorizationStatus.provisional:
          if (kDebugMode) {
            print('✅ Notificações provisórias autorizadas');
          }
          break;
      }
    } catch (e, stackTrace) {
      if (e is PermissionException) rethrow;

      if (kDebugMode) {
        print('⚠️ Erro ao solicitar permissão de notificação: $e');
      }
      throw ServerException(
        'Erro ao solicitar permissão de notificação',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> onMessageReceived(RemoteMessage message) async {
    if (kDebugMode) {
      print('📬 Mensagem recebida: ${message.data}');
    }

    // Mostrar notificação local
    await _showLocalNotification(message);
  }

  @override
  Future<void> onMessageOpenedApp(RemoteMessage message) async {
    if (kDebugMode) {
      print('📱 App aberto através da notificação: ${message.data}');
    }

    // Aqui você pode navegar para uma tela específica baseada nos dados da notificação
    _handleNotificationNavigation(message);
  }

  @override
  Future<void> onBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📦 Mensagem em background: ${message.data}');
    }

    // Processar mensagem em background
    _handleBackgroundMessage(message);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    try {
      await onMessageReceived(message);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao processar mensagem em foreground: $e');
      }
      // Não lançar exceção - notificações não devem travar o app
    }
  }

  Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    try {
      await onMessageOpenedApp(message);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao processar abertura de notificação: $e');
      }
      // Não lançar exceção
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'high_importance_channel',
        'Notificações Importantes',
        channelDescription: 'Canal para notificações importantes',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'Nova notificação',
        message.notification?.body ?? '',
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('⚠️ Erro ao mostrar notificação local: $e');
      }
      throw ServerException(
        'Erro ao mostrar notificação',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('👆 Notificação tocada: ${response.payload}');
    }

    // Aqui você pode navegar para uma tela específica
    _handleNotificationNavigationFromPayload(response.payload);
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    // Implementar navegação baseada nos dados da notificação
    // Exemplo: se message.data['screen'] == 'profile', navegar para perfil
    if (kDebugMode) {
      print('🧭 Navegando para: ${message.data}');
    }
  }

  void _handleNotificationNavigationFromPayload(String? payload) {
    // Implementar navegação baseada no payload
    if (kDebugMode) {
      print('🧭 Navegando do payload: $payload');
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Implementar lógica para mensagens em background
    if (kDebugMode) {
      print('🔄 Processando mensagem em background: ${message.data}');
    }
  }
}

// Função global para background messages (deve estar fora da classe)
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Esta função deve ser global e não pode ser um método de classe
  if (kDebugMode) {
    print('📦 Background message: ${message.data}');
  }
}
