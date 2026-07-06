import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/configuracion_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de notificaciones basado puramente en Supabase.
///
/// Usa Supabase Realtime para escuchar INSERTS en la tabla `publications`
/// y muestra notificaciones locales via flutter_local_notifications.
///
/// Funciona cuando la app esta abierta o en background (Android).
/// Para pushes remotas cuando la app esta cerrada se necesita FCM,
/// pero es funcional asi para el alcance actual del proyecto.
class ServicioNotificaciones {
  static final ServicioNotificaciones _instance =
      ServicioNotificaciones._internal();
  factory ServicioNotificaciones() => _instance;
  ServicioNotificaciones._internal();

  bool _inicializado = false;
  StreamSubscription? _realtimeSubscription;
  String? _ultimaPublicacionIdNotificada;

  final FlutterLocalNotificationsPlugin _notificacionesLocales =
      FlutterLocalNotificationsPlugin();

  bool get estaInicializado => _inicializado;

  // -------------------------------------------------------------------------
  //  INICIALIZACION
  // -------------------------------------------------------------------------
  Future<void> inicializar() async {
    if (_inicializado) return;

    await _configurarCanalesLocales();
    _suscribirseANuevasPublicaciones();

    _inicializado = true;
    debugPrint('ServicioNotificaciones inicializado (modo Supabase Realtime).');
  }

  // -------------------------------------------------------------------------
  //  CONFIGURACION LOCAL NOTIFICATIONS
  // -------------------------------------------------------------------------
  Future<void> _configurarCanalesLocales() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notificacionesLocales.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notificacion tocada: ${response.payload}');
        // TODO: Navegar al detalle de la publicacion
        // usar response.payload que contiene el publication_id
      },
    );

    // Canal Android 8+
    try {
      await _notificacionesLocales
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'publicaciones',
              'Nuevas Publicaciones',
              description:
                  'Notificaciones cuando se publica nuevo contenido',
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  //  REALTIME: DETECTAR NUEVAS PUBLICACIONES
  // -------------------------------------------------------------------------
  void _suscribirseANuevasPublicaciones() {
    if (!ConfiguracionSupabase.estaConfigurado) {
      debugPrint(
        'Supabase no configurado. Notificaciones Realtime desactivadas.',
      );
      return;
    }

    try {
      _realtimeSubscription?.cancel();

      // ignore: unused_local_variable
      final canal = Supabase.instance.client
          .channel('publicaciones-realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'publications',
            callback: (cambio) {
              final nuevaFila = cambio.newRecord;
              final id = nuevaFila['id'] as String?;
              final titulo = nuevaFila['title'] as String? ?? '';

              // Evitar duplicados
              if (id == null || id == _ultimaPublicacionIdNotificada) return;
              _ultimaPublicacionIdNotificada = id;

              _mostrarNotificacionLocal(
                id: id.hashCode,
                titulo: 'Nueva publicacion',
                cuerpo: titulo,
                payload: id,
              );
            },
          )
          .subscribe();

      debugPrint('Suscrito a nuevas publicaciones via Supabase Realtime.');
    } catch (error) {
      debugPrint('Error suscribiendo a Realtime: $error');
    }
  }

  // -------------------------------------------------------------------------
  //  MOSTRAR NOTIFICACION LOCAL
  // -------------------------------------------------------------------------
  Future<void> _mostrarNotificacionLocal({
    required int id,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    try {
      await _notificacionesLocales.show(
        id,
        titulo,
        cuerpo,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'publicaciones',
            'Nuevas Publicaciones',
            channelDescription:
                'Notificaciones cuando se publica nuevo contenido',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (error) {
      debugPrint('Error mostrando notificacion local: $error');
    }
  }

  // -------------------------------------------------------------------------
  //  LIMPIEZA
  // -------------------------------------------------------------------------
  Future<void> dispose() async {
    _realtimeSubscription?.cancel();
    _inicializado = false;
  }
}
