import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prayer_time_mobile_app/services/location_service.dart';
import 'package:prayer_time_mobile_app/services/noti_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:async';

class NotificationScheduleScreen extends StatefulWidget {
  @override
  _NotificationScheduleScreenState createState() =>
      _NotificationScheduleScreenState();
}

class _NotificationScheduleScreenState
    extends State<NotificationScheduleScreen> {
  // Store the selected notification time for each prayer
  int fajrNotifyBefore = 30;
  int dhuhrNotifyBefore = 30;
  int asrNotifyBefore = 30;
  int maghribNotifyBefore = 30;
  int ishaNotifyBefore = 30;

  // Dropdown items for notification time options
  final List<int> notifyOptions = [30, 60]; // 30 mins, 1 hour

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  // Load saved settings from shared preferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      fajrNotifyBefore = prefs.getInt('fajr_notify') ?? 30;
      dhuhrNotifyBefore = prefs.getInt('dhuhr_notify') ?? 30;
      asrNotifyBefore = prefs.getInt('asr_notify') ?? 30;
      maghribNotifyBefore = prefs.getInt('maghrib_notify') ?? 30;
      ishaNotifyBefore = prefs.getInt('isha_notify') ?? 30;
    });
  }

  // Save the settings to shared preferences
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('fajr_notify', fajrNotifyBefore);
    prefs.setInt('dhuhr_notify', dhuhrNotifyBefore);
    prefs.setInt('asr_notify', asrNotifyBefore);
    prefs.setInt('maghrib_notify', maghribNotifyBefore);
    prefs.setInt('isha_notify', ishaNotifyBefore);

    print("Settings saved!");
  }

  Future<void> handleSave() async {
    // Request notification permission (Android 13+)
    final status = await Permission.notification.request();

    if (status.isGranted) {
      await saveSettings();

      Position position = await LocationService.getCoordinates();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.karachi.getParameters();
      final prayerTimes = PrayerTimes.today(coordinates, params);

      final List<Map<String, dynamic>> notifications = [
        {
          'id': 1,
          'title': 'Fajr Prayer',
          'body': 'Time for Fajr prayer.',
          'time': prayerTimes.fajr,
          'offset': fajrNotifyBefore,
        },
        {
          'id': 2,
          'title': 'Dhuhr Prayer',
          'body': 'Time for Dhuhr prayer.',
          'time': prayerTimes.dhuhr,
          'offset': dhuhrNotifyBefore,
        },
        {
          'id': 3,
          'title': 'Asr Prayer',
          'body': 'Time for Asr prayer.',
          'time': prayerTimes.asr,
          'offset': asrNotifyBefore,
        },
        {
          'id': 4,
          'title': 'Maghrib Prayer',
          'body': 'Time for Maghrib prayer.',
          'time': prayerTimes.maghrib,
          'offset': maghribNotifyBefore,
        },
        {
          'id': 5,
          'title': 'Isha Prayer',
          'body': 'Time for Isha prayer.',
          'time': prayerTimes.isha,
          'offset': ishaNotifyBefore,
        },
      ];

       for (final notify in notifications) {
        final DateTime adjustedTime = notify['time'].subtract(Duration(minutes: notify['offset']));

        await NotiService().schedulePrayerNotification(
          id: notify['id'],
          title: notify['title'],
          body: notify['body'],
          hour: adjustedTime.hour,
          minute: adjustedTime.minute,
        );
      }

      showSuccessDialog();
    } else {
      // Show an error or alert if permission was denied
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Notification permission is required to schedule reminders.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Your prayer notifications have been scheduled successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // UI components for each prayer time setting
  Widget buildPrayerSetting(String title, int currentValue, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        DropdownButton<int>(
          value: currentValue,
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                onChanged(newValue);
              });
            }
          },
          items: notifyOptions.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value minutes'),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildPrayerSetting(
              'Fajr',
              fajrNotifyBefore,
              (value) => fajrNotifyBefore = value,
            ),
            buildPrayerSetting(
              'Dhuhr',
              dhuhrNotifyBefore,
              (value) => dhuhrNotifyBefore = value,
            ),
            buildPrayerSetting(
              'Asr',
              asrNotifyBefore,
              (value) => asrNotifyBefore = value,
            ),
            buildPrayerSetting(
              'Maghrib',
              maghribNotifyBefore,
              (value) => maghribNotifyBefore = value,
            ),
            buildPrayerSetting(
              'Isha',
              ishaNotifyBefore,
              (value) => ishaNotifyBefore = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await handleSave();
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
