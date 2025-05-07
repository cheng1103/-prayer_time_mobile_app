import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prayer_time_mobile_app/app/provider/connection_provider.dart';
import 'package:prayer_time_mobile_app/app/provider/db_prayer_provider.dart';
import 'package:prayer_time_mobile_app/app/provider/prayer_provider.dart';
import 'package:prayer_time_mobile_app/services/noti_service.dart';
import 'package:provider/provider.dart';
import 'app/screen/login.dart';
import 'app/screen/register.dart';
import 'app/screen/compass_with_qiblah.dart';
import 'app/screen/homescreen.dart';
import 'app/screen/quran.dart';
import 'app/screen/dashboard.dart';
import 'app/screen/profile.dart';
import 'app/screen/setting.dart';
import 'app/screen/edit_profile.dart';
import 'app/screen/feedback.dart';
import 'app/screen/notifications.dart';
import 'app/screen/calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // init notification
  await NotiService().initNotification();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(
            create: (context) => DbPrayerProvider(
                Provider.of<PrayerProvider>(context, listen: false))),
      ],
      child: MaterialApp(
        title: 'Prayer Time Mobile App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/qiblah': (context) => const CompassScreen(),
          '/homepage': (context) => const HomeScreen(),
          '/quran': (context) => const QuranScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/feedback': (context) => const FeedbackScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/calendar': (context) => const CalendarScreen(),
        },
      ),
    );
  }
}
