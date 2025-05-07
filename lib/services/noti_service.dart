import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;
  NotiService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize notification service and time zone settings
  Future<void> initNotification() async {
    if (_isInitialized) return;

    try {
      // Initialize time zones
      tz.initializeTimeZones();
      
      // Get the local timezone of the device
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      
      // Set the local timezone for TZDateTime
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      await AwesomeNotifications().initialize(
        'resource://drawable/ic_launcher',
        [
          NotificationChannel(
            channelKey: 'prayer_channel',
            channelName: 'Prayer Notifications',
            channelDescription: 'Notifications for prayer times',
            defaultColor: Colors.green,
            importance: NotificationImportance.High,
            channelShowBadge: true,
          )
        ],
      );
      
      // 请求通知权限
      await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });

      _isInitialized = true;

      print("Notification Plugin Initialized Successfully.");
    } catch (e) {
      print("Error during notification initialization: $e");
    }
  }

  // 移除 NotificationDetails 方法，替换为 awesome_notifications 版本
  // 显示即时通知
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    try {
      if (!_isInitialized) {
        await initNotification();
      }
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'prayer_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  // 使用 awesome_notifications 调度祈祷通知
  Future<void> schedulePrayerNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      if (!_isInitialized) {
        await initNotification();
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

      // If the scheduled time is in the past, move to the next day
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      print("Current time: $now");
      print("Scheduling notification at: $scheduledDate");
      print("Is initialized: $_isInitialized");

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'prayer_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate),
      );

      print('Notification scheduled successfully for $scheduledDate');
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  // Function to cancel scheduled notifications
  Future<void> cancelNotification(int notificationId) async {
    try {
      if (!_isInitialized) {
        await initNotification();
      }
      await AwesomeNotifications().cancel(notificationId);
      print("Notification $notificationId cancelled.");
    } catch (e) {
      print("Error cancelling notification $notificationId: $e");
    }
  }
}