import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alert_models.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class AlertService {
  final FlutterLocalNotificationsPlugin notifications;
  final List<WeatherAlert> _pendingAlerts = [];

  AlertService(this.notifications) {
    _initializeTimeZones();
  }

  Future<void> _initializeTimeZones() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Tunis'));
    } catch (e) {
      print("Erreur configuration timezone: $e");
    }
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Gestion du clic sur notification
      },
    );
  }

  void checkForAlerts(WeatherData weather) {
    for (final alert in weather.alerts) {
      if (!_pendingAlerts.any((a) => a.id == alert.id)) {
        _pendingAlerts.add(alert);
        _showAlertImmediately(alert);
        _scheduleAlertReminder(alert);
      }
    }
  }

  Future<void> _showAlertImmediately(WeatherAlert alert) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'weather_alerts_channel',
      'Alertes Météo Tunisie',
      channelDescription: 'Alertes météorologiques pour la Tunisie',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await notifications.show(
      alert.id.hashCode,
      '⚠ Alerte: ${alert.title}',
      alert.description,
      platformChannelSpecifics,
      payload: 'weather_alert|${alert.id}',
    );
  }

  Future<void> _scheduleAlertReminder(WeatherAlert alert) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(
      const Duration(hours: 3),
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'weather_reminders_channel',
      'Rappels Alertes Météo',
      channelDescription: 'Rappels pour les alertes météorologiques',
      importance: Importance.defaultImportance,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await notifications.zonedSchedule(
      alert.id.hashCode + 1,
      'Rappel: ${alert.title}',
      'Cette alerte est toujours active',
      scheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> clearAllAlerts() async {
    await notifications.cancelAll();
    _pendingAlerts.clear();
  }

  Future<void> syncPendingAlerts() async {
    try {
      // TODO: Ajouter la logique d'envoi au serveur
      _pendingAlerts.clear();
    } catch (e) {
      print("Erreur synchronisation alertes: $e");
    }
  }
}