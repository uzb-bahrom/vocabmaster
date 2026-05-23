import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );
      await _scheduleDailyNotifications();
    } catch (e) {
      // Notification xatosi ilovani to'xtatmasin
    }
  }

  static Future<void> _scheduleDailyNotifications() async {
    await _plugin.cancelAll();
    await _schedule(id: 1, title: '📚 VocabMaster', body: "Bugun hali so'z qo'shmadingiz!", hour: 9);
    await _schedule(id: 2, title: '🔁 VocabMaster', body: 'Streak uzilmasin! Takrorlang.', hour: 20);
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required int hour,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'vocabmaster',
          'VocabMaster Eslatmalar',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
