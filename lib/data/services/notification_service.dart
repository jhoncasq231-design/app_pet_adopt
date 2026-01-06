// import 'package:firebase_messaging/firebase_messaging.dart';

/// DESACTIVADO POR AHORA - Se habilitará cuando Firebase esté configurado
/*
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // Callbacks para notificaciones
  static Function(Map<String, dynamic>)? onNotificationReceived;
  static Function(RemoteMessage)? onNotificationTapped;

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  /// Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    try {
      // Solicitar permisos
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        provisional: false,
        sound: true,
      );

      // Obtener token FCM
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      // Guardar token en base de datos (Supabase)
      if (token != null) {
        await _saveFCMToken(token);
      }

      // Escuchar cambios en el token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('Token FCM actualizado: $newToken');
        _saveFCMToken(newToken);
      });

      // Manejar mensajes en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
          'Mensaje recibido en primer plano: ${message.notification?.title}',
        );
        _handleForegroundMessage(message);
      });

      // Manejar cuando el usuario toca la notificación
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notificación tocada: ${message.notification?.title}');
        if (onNotificationTapped != null) {
          onNotificationTapped!(message);
        }
      });

      // Manejar mensajes cuando la app está terminada
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        print('Mensaje inicial: ${initialMessage.notification?.title}');
        if (onNotificationTapped != null) {
          onNotificationTapped!(initialMessage);
        }
      }

      print('Servicio de notificaciones inicializado correctamente');
    } catch (e) {
      print('Error al inicializar notificaciones: $e');
    }
  }

  /// Manejar mensaje en primer plano
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
    print('Datos: ${message.data}');

    // Callback personalizado
    if (onNotificationReceived != null) {
      onNotificationReceived!({
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': message.data,
      });
    }
  }

  /// Guardar token FCM en Supabase
  static Future<void> _saveFCMToken(String token) async {
    try {
      // Guardar en la base de datos usando el auth service
      await AuthService.saveFCMToken(token);
      print('Token FCM guardado correctamente');
    } catch (e) {
      print('Error al guardar token FCM: $e');
    }
  }

  /// Suscribirse a un tema (para notificaciones de grupo)
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Suscrito al tema: $topic');
    } catch (e) {
      print('Error al suscribirse al tema: $e');
    }
  }

  /// Desuscribirse de un tema
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Desuscrito del tema: $topic');
    } catch (e) {
      print('Error al desuscribirse del tema: $e');
    }
  }

  /// Obtener token FCM actual
  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error al obtener token FCM: $e');
      return null;
    }
  }
}

/// Handler para mensajes en segundo plano (debe ser una función de nivel superior)
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Manejando mensaje en segundo plano: ${message.notification?.title}');
// }
*/
